fluent-plugin-riak
==================

fluent-plugin-riak is a alternative for people who are not sufficient with mongo or webhdfs. Riak ( http://github.com/basho/riak ) is an open-source distributed KVS focused on availability. It also has a strong query system with secondary index (2i): see docs ( http://docs.basho.com/riak/latest/tutorials/querying/ ) for details.

Current status is still proof-of-concept: index setting and its configuration are to be decided. Also performance optimization is required. Another idea is in_tail_riak by using riak post-commit.


fluent.conf example
-------------------

```
<match riak.**>
  type riak

  buffer_type memory
  flush_interval 10s
  retry_limit 5
  retry_wait 1s
  buffer_chunk_limit 256m
  buffer_queue_limit 8096

  # pb port
  nodes 127.0.0.1:8087
  #for cluster, define multiple machines
  #nodes 192.168.100.128:10018 129.168.100.128:10028 
</match>

```

key format -> 2013-02-<uuid>
value format -> [records] in JSON
index:
  year_int -> year
  month_bin -> <year>-<month>
  tag_bin -> tags

Pros
----

- easy operations
- high availability
- horizontal scalability (esp. write performance)
- good night sleep

Cons
----

- no capped table, TTL objects


License
=======

Apache 2.0

Copyright Kota UENISHI

Many Thanks to fluent-plugin-mongo
