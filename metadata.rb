name 'redis'
maintainer 'Anthony Caiafa'
maintainer_email '2600.ac@gmail.com'
description 'Application cookbook which installs and configures Redis.'
long_description 'Application cookbook which installs and configures Redis.'
version '1.0.0'

supports 'redhat', '>= 5.8'
supports 'centos', '>= 5.8'
supports 'ubuntu', '>= 12.04'

depends 'poise', '~> 2.2'
depends 'poise-service', '~> 1.0'
