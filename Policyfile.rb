name 'redis'
default_source :community
cookbook 'redis', path: '.'
run_list 'redis::default'
