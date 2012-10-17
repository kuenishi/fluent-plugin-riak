fluent-plugin-riak
==================

fluent-plugin-riak is a alternative for people who are not sufficient with mongo or webhdfs. Riak ( http://github.com/basho/riak ) is an open-source distributed KVS focused on availability. It also has a strong query system with secondary index (2i): see docs ( http://docs.basho.com/riak/latest/tutorials/querying/ ) for details.

Current status is still proof-of-concept: index setting and its configuration are to be decided. Also performance optimization is required. Another idea is in_tail_riak by using riak post-commit.

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
