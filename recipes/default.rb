#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
poise_service_user node['redis']['service_user'] do
  shell '/bin/bash'
  group node['redis']['service_group']
end

redis_installation node['redis']['service_name'] do
  version ''
end

redis_instance node['redis']['service_name'] do
  user node['redis']['service_user']
  group node['redis']['service_group']
end

redis_config node['redis']['config']['path'] do
  owner node['redis']['service_owner']
  group node['redis']['service_group']
  node['redis']['config'].each_pair { |k, v| send(k, v) }
end
