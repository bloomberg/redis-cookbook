name 'redis'
default_source :community
cookbook 'redis', path: '.'
run_list 'redis::default'
named_run_list :redhat, 'redhat::default', 'redis::default'
named_run_list :ubuntu, 'ubuntu::default', 'redis::default'
