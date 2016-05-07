#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module RedisCookbook
  module Resource
    # @provides redis_config
    # @action create
    # @action remove
    # @since 2.0
    class RedisConfig < Chef::Resource
      include Poise(fused: true)
      provides(:redis_config)

      attribute(:path, kind_of: String)
      attribute(:owner, kind_of: String, default: 'redis')
      attribute(:group, kind_of: String, default: 'redis')
      attribute(:mode, kind_of: String, default: '0440')

      # @see: https://raw.githubusercontent.com/antirez/redis/2.8/redis.conf
      attribute(:port, kind_of: Integer, default: 6_379)
      attribute(:bind, kind_of: String, default: '0.0.0.0')
      attribute(:unixsocket, kind_of: [String, NilClass], default: nil)
      attribute(:unixsocketperm, kind_of: [String, NilClass], default: nil)
      attribute(:timeout, kind_of: Integer, default: 0)
      attribute(:loglevel, kind_of: String, default: 'notice')
      attribute(:syslog_enabled, kind_of: [String, NilClass], default: nil)
      attribute(:syslog_ident, kind_of: [String, NilClass], default: nil)
      attribute(:syslog_facility, kind_of: [String, NilClass], default: nil)
      attribute(:logfile, kind_of: String, default: lazy { ::File.join(log_dir, "#{instance_name}.log") })
      attribute(:databases, kind_of: Integer, default: 16)
      attribute(:save, kind_of: [String, Array], default: ['900 1', '300 10', '60 10000'])
      attribute(:stop_writes_on_bgsave_error, equal_to: %w{yes no}, default: 'yes')
      attribute(:rdbcompression, equal_to: %w{yes no}, default: 'yes')
      attribute(:rdbchecksum, equal_to: %w{yes no}, default: 'yes')
      attribute(:dir, kind_of: String, default: lazy { "/var/lib/redis/#{instance_name}" })
      attribute(:slaveof, kind_of: [String, Array, NilClass], default: nil)
      attribute(:masterauth, kind_of: [String, NilClass], default: nil)
      attribute(:slave_serve_stale_data, equal_to: %w{yes no}, default: 'yes')
      attribute(:slave_read_only, equal_to: %w{yes no}, default: 'yes')
      attribute(:repl_ping_slave_period, kind_of: [String, NilClass], default: nil)
      attribute(:repl_timeout, kind_of: [String, NilClass], default: nil)
      attribute(:slave_priority, kind_of: Integer, default: 100)
      attribute(:requirepass, kind_of: [String, NilClass], default: nil)
      attribute(:maxclients, kind_of: [String, NilClass], default: nil)
      attribute(:maxmemory, kind_of: [String, NilClass], default: nil)
      attribute(:maxmemory_policy, kind_of: [String, NilClass], default: nil)
      attribute(:memory_samples, kind_of: [String, NilClass], default: nil)
      attribute(:dbfilename, kind_of: String, default: 'dump.rdb')
      attribute(:appendonly, equal_to: %w{yes no}, default: 'no')
      attribute(:appendfilename, kind_of: String, default: 'appendonly.aof')
      attribute(:appendfsync, kind_of: String, default: 'everysec')
      attribute(:no_appendfsync_on_rewrite, equal_to: %w{yes no}, default: 'no')
      attribute(:auto_aof_rewrite_percentage, kind_of: Integer, default: 100)
      attribute(:auto_aof_rewrite_min_size, kind_of: Integer, default: '64mb')
      attribute(:lua_time_limit, kind_of: Integer, default: 5_000)
      attribute(:slowlog_log_slower_than, kind_of: Integer, default: 10_000)
      attribute(:slowlog_max_len, kind_of: Integer, default: 128)
      attribute(:hash_max_ziplist_entries, kind_of: Integer, default: 512)
      attribute(:hash_max_ziplist_value, kind_of: Integer, default: 64)
      attribute(:list_max_ziplist_entries, kind_of: Integer, default: 512)
      attribute(:list_max_ziplist_value, kind_of: Integer, default: 64)
      attribute(:set_max_intset_entries, kind_of: Integer, default: 512)
      attribute(:zset_max_ziplist_entries, kind_of: Integer, default: 128)
      attribute(:zet_max_ziplist_value, kind_of: Integer, default: 64)
      attribute(:activerehashing, equal_to: %w{yes no}, default: 'yes')
      attribute(:client_output_buffer_limit, kind_of: [String, Array], default: ['normal 0 0 0', 'slave 256mb 64mb 60', 'pubsub 32mb 8mb 60'])

      # @see: https://github.com/antirez/redis/blob/unstable/sentinel.conf
      attribute(:sentinel_port, kind_of: Integer, default: 26_379)
      attribute(:sentinel_master_name, kind_of: String, default: 'mymaster')
      attribute(:sentinel_monitor, kind_of: String, default: '127.0.0.1 6379 2')
      attribute(:sentinel_auth, kind_of: String, default: 'notneverthatsecureYOLO')
      attribute(:sentinel_down, kind_of: Integer, default: '30000')
      attribute(:sentinel_parallel, kind_of: Integer, default: 1)
      attribute(:sentinel_failover, kind_of: Integer, default: 180_000)
      attribute(:sentinel_notification, kind_of: [String, NilClass], default: nil)
      attribute(:sentinel_client_reconfig, kind_of: [String, NilClass], default: nil)

      action(:create) do

      end

      action(:remove) do

      end
    end
  end
end
