require 'net/http'

# uri = URI("http://192.168.62.128:8888/riak.test")

def run(n, uri)
  (0..n).each do |i|
    json = "{\"hoge\":\"valueoooooooo ???? special? \",\"id\":#{i}}"
    res = Net::HTTP.post_form(uri, 'json' => json)
    if (i % 1000) == 0 then
      print "#{i}: #{res.code}\n"
    end
  end
end

uri = URI("http://192.168.100.128:8888/riak.test")
n = 1024*1024
start = Time.now
run(n, uri)
duration = (Time.now - start).to_i
mps = n * 1.0 / duration
print "#{n} messages in #{duration} secs: #{mps} mps.\n"
