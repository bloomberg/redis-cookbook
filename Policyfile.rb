name 'redis'
default_source :community
cookbook 'redis', path: '.'
named_run_list :freebsd, 'freebsd::default', 'redis::default'
named_run_list :redhat, 'redhat::default', 'redis::default'
named_run_list :ubuntu, 'ubuntu::default', 'redis::default'
