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

    @nodes = conf['nodes'].split(',').map{ |s|
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
  end
  def shutdown
    super
  end

  def format(tag, time, record)
    [time, record].to_msgpack
  end

  def emit(tag, es, chain)
# #    $log.debug "#{@buffer} #{es}"
    #es.to_msgpack
#   end
    chain.next
    es.each { |time, record|
      key = tag + "|" + time.to_s + "|" + @buf.size.to_s
      @buf[key] = record
    }

    if @buf.size > @buffer.queue_limit then # FIXME: hand-made buffer
      n = @buf.size
      k = put_now(@buf)
      @buf = {}
      $log.debug "#{n} objects inserted with key=#{k}"
    end
  end

  def write(chunk)
    $log.warn " <<<<<===========\n"
    # records  = []
    # chunk.msgpack_each { |record|
    #   records << record
    # }
    # $log.debug "#{records}"
  end

  private

  # TODO: add index for some analysis
  def put_now(obj)
    key = Time.now.to_i.to_s
    obj = Riak::RObject.new(@bucket, key)
    obj.raw_data = obj.to_json
    obj.content_type = 'text/json'
    obj.store
    key
  end

end

end
