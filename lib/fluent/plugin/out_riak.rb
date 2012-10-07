
class RiakOutput < Fluent::BufferedOutput

  Fluent::Plugin.register_output('riak', self)

  config_param :nodes

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
    @queue = []
  end

  def start
    @conn = Riak::Client.new(:nodes => @nodes,
                             :protocol => "pbc")
    @bucket = @conn.bucket("fluentlog")
  end
  def shutdown
    super
  end
  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def emit(tag, es, chain)
    chain.next
    es.each { |time, record|
      @queue << {time => record}
    }

    now = Time.now.to_i.to_s
    object = Riak::RObject.new(@bucket, now)
    object.raw_data = @queue.to_json
    object.content_type = 'text/json'
    object.store
    @queue = []
  end

  def write(chunk)
    data = chunk.read
    print data
  end

end
