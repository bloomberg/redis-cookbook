#
# Cookbook: blp-redis
# License: Apache 2.0
#
# Copyright 2015-2017, Bloomberg Finance L.P.
#
poise_service_user node['blp-redis']['service_user'] do
  shell '/bin/bash'
  group node['blp-redis']['service_group']
end

redis_installation node['blp-redis']['sentinel']['service_name']

redis_sentinel node['blp-redis']['sentinel']['service_name'] do
  owner node['blp-redis']['service_owner']
  group node['blp-redis']['service_group']
  node['blp-redis']['sentinel']['config'].each_pair { |k, v| send(k, v) }
end
