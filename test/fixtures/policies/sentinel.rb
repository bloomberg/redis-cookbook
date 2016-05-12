name 'sentinel'
default_source :community
cookbook 'redis', path: '.'
run_list 'redis::sentinel'
named_run_list :redhat, 'redhat::default', 'redis::sentinel'
named_run_list :ubuntu, 'ubuntu::default', 'redis::sentinel'
