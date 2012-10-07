require 'riak'

nodes = [{ :host => "192.168.62.129",
           :pb_port => 8081 }]


c = Riak::Client.new( :nodes => nodes, :protocol => "pbc" )
#c.list_buckets
b = c.bucket("fluentlog")

def put(bucket)
  o = Riak::RObject.new(bucket, "hoge")
  o.content_type = "text/plain"
  o.raw_data = "hogehoge"
  o.store
end

def get(bucket)
  o = bucket.get("hoge")
  p o.content_type
  p o.raw_data
end

def keys(bucket)
  bucket.keys { |ks|
    ks.each { |k|
      o = bucket.get(k)
      print "#{o.bucket.name}/#{o.key} (#{o.content_type})\n"
      print " =>  #{o.raw_data}\n"
    }
  }
end

#put b
#get b
keys b
