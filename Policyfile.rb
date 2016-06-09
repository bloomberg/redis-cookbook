name 'redis'
default_source :community
cookbook 'redis', path: '.'
run_list 'redis::default'
named_run_list :redhat, 'redhat::default', run_list
named_run_list :ubuntu, 'ubuntu::default', run_list
default['redhat']['enable_epel'] = true
