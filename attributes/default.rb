#
# Cookbook: blp-redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
default['blp-redis']['provider'] = 'auto'

default['blp-redis']['service_name'] = 'redis'
default['blp-redis']['service_user'] = 'redis'
default['blp-redis']['service_group'] = 'redis'

default['blp-redis']['sentinel']['service_name'] = 'redis-sentinel'

default['blp-redis']['config'] = {}
default['blp-redis']['sentinel']['config'] = {}
