#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
default['redis']['provider'] = 'auto'

default['redis']['service_name'] = 'redis'
default['redis']['service_user'] = 'redis'
default['redis']['service_group'] = 'redis'

default['redis']['config']['path'] = '/etc/redis.conf'

default['redis']['sentinel']['service_name'] = 'redis-sentinel'
default['redis']['sentinel']['config']['path'] = '/etc/redis-sentinel.conf'
