module Fluent

class RiakOutput < BufferedOutput

  Fluent::Plugin.register_output('riak', self)
  include SetTimeKeyMixin
  config_set_default :include_tag_key, false
  include SetTagKeyMixin
  config_set_default :include_time_key, true

  config_param :nodes, :string, :default => "localhost:8081"

  def initialize
    super
    require 'riak'
    require 'msgpack'
  end

  def configure(conf)
    super

    @nodes = @nodes.split(',').map{ |s|
      ip,port = s.split(':')
      {:host => ip, :pb_port => port.to_i}
    }
    $log.debug "@nodes = #{@nodes}"
  end

  def start
    $log.debug " => #{@buffer.chunk_limit} #{@buffer.queue_limit} "
    @conn = Riak::Client.new(:nodes => @nodes, :protocol => "pbc")
    @bucket = @conn.bucket("fluentlog")
    @buf = {}

    super
  end

  def format(tag, time, record)
    [time, record].to_msgpack
  end

  def write(chunk)
    $log.warn " <<<<<===========\n"

    records  = []
    chunk.msgpack_each { |time, record|
      # TODO: time processing and tag processing
      records << record
    }
    $log.debug "#{records}"

    put_now(records)
  end

  private

  # TODO: add index for some analysis
  def put_now(obj)
    key = Time.now.to_i.to_s
    robj = Riak::RObject.new(@bucket, key)
    robj.raw_data = obj.to_json
    robj.content_type = 'text/json'
    robj.store
    key
  end

end

end
