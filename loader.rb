require 'net/http'

uri = URI("http://192.168.62.128:8888/riak.test")

(1..1024*1024).each do |i|
  json = "{\"hoge\":\"value\",\"id\":#{i}}"
  res = Net::HTTP.post_form(uri, 'json' => json)
  print "#{i}: #{res.code}\n"
end
