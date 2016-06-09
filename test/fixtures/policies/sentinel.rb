name 'sentinel'
default_source :community
cookbook 'redis', path: File.expand_path('../../../..', __FILE__)
run_list 'redis::sentinel'
named_run_list :redhat, 'redhat::default', run_list
named_run_list :ubuntu, 'ubuntu::default', run_list
default['redhat']['enable_epel'] = true
