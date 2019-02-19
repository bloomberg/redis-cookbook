default_source :community
default_source :chef_repo, '..'
cookbook 'blp-redis', path: '../../..'
named_run_list :centos, 'yum::default', 'yum-epel::default', run_list
named_run_list :debian, 'apt::default', run_list
named_run_list :freebsd, 'freebsd::default', run_list
