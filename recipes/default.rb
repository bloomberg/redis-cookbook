#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
poise_service_user node['redis']['service_user'] do
  group node['redis']['service_group']
end

install = redis_installation node['redis']['service_name'] do |r|
  node['redis']['install'].each_pair { |k, v| r.send(k, v) } if node['redis']['install']
end

config = redis_config node['redis']['service_name'] do |r|
  owner node['redis']['service_owner']
  group node['redis']['service_group']
  node['redis']['config'].each_pair { |k, v| r.send(k, v) }
end

redis_instance node['redis']['service_name'] do
  directory config.directory
  config_file config.path
  program install.redis_program

  user node['redis']['service_user']
  group node['redis']['service_group']
end
