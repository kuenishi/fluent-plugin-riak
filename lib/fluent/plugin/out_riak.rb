module Fluent

class RiakOutput < BufferedOutput

  Fluent::Plugin.register_output('riak', self)
  include SetTimeKeyMixin
  config_set_default :include_tag_key, true
  include SetTagKeyMixin
  config_set_default :include_time_key, true

  config_param :nodes, :string, :default => "localhost:8087"

  def initialize
    super
    require 'riak'
    require 'msgpack'
    require 'uuidtools'
  end

  def configure(conf)
    super

    @nodes = @nodes.split(',').map{ |s|
      ip,port = s.split(':')
      {:host => ip, :pb_port => port.to_i}
    }
    $log.info "riak nodes=#{@nodes}"
  end

  def start
    $log.debug " => #{@buffer.chunk_limit} #{@buffer.queue_limit} "
    @conn = Riak::Client.new(:nodes => @nodes, :protocol => "pbc")
    @bucket = @conn.bucket("fluentlog")
    @buf = {}

    super
  end

  def format(tag, time, record)
    [time, tag, record].to_msgpack
  end

  def write(chunk)
    $log.debug " <<<<<===========\n"

    records  = []
    tags = []
    chunk.msgpack_each { |time, tag, record|
      record[@tag_key] = tag
      tags << tag
      records << record
      $log.debug record
    }
    put_now(records, tags)
  end

  private

  # TODO: add index for some analysis
  def put_now(records, tags)
    today = Date.today
    key = "#{today.to_s}-#{UUIDTools::UUID.random_create.to_s}"
    robj = Riak::RObject.new(@bucket, key)
    robj.raw_data = records.to_json
    robj.indexes['year_int'] << today.year
    robj.indexes['month_bin'] << "#{today.year}-#{today.month}"
    tags.each do |tag|
      robj.indexes['tag_bin'] << tag
    end
    robj.content_type = 'application/json'
    robj.store
    robj
  end

end

end
