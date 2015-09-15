#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015, Bloomberg Finance L.P.
#
poise_service_user node['redis']['service_user'] do
  group node['redis']['service_group']
end

redis_instance node['redis']['service_name'] do |r|
  user node['redis']['service_user']
  group node['redis']['service_group']

  node['redis']['config'].each_pair { |k,v| r.send(k, v) }
end
