# Redis Cookbook
[![Build Status](https://img.shields.io/travis/bloomberg/redis-cookbook.svg)](https://travis-ci.org/bloomberg/redis-cookbook)
[![Code Quality](https://img.shields.io/codeclimate/github/bloomberg/redis-cookbook.svg)](https://codeclimate.com/github/bloomberg/redis-cookbook)
[![Test Coverage](https://codeclimate.com/github/bloomberg/redis-cookbook/badges/coverage.svg)](https://codeclimate.com/github/bloomberg/redis-cookbook/coverage)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

[Application cookbook][0] which installs and configures the [Redis][1]
key-value database and [Redis Sentinel][2] which provides
high-availability for the database.

## Platforms
The following platforms are tested using [Test Kitchen][5]:

- Ubuntu 12.04/14.04/16.04
- CentOS (RHEL) 5/6/7

## Basic Usage
The [default recipe](recipes/default.rb) installs and configures the
Redis database. The
[install resource](libraries/redis_installation.rb) will use the
[package install provider](libraries/redis_installation_package.rb)
for the node's operating system. The configuration of the database is
managed through the [config resource](libraries/redis_config.rb) which
can be tuned with node attributes.

Additionally, there is a [sentinel recipe](recipes/sentinel.rb) which
installs and configures Redis Sentinel. It installs Sentinel using the
same installation provider mechanism as the default resource.

## Advanced Usage
The [installation resource](libraries/redis_installation.rb)
attributes are able to be tuned easily; for deployments we suggest
using [Chef Policyfiles][3]. An [example policyfile](Policyfile.rb) is
used for configuring Test Kitchen.

Let's consider a common need for enterprise networks to mirror files
internally because they are unable to go out to the Internet. Using
the [archive provider](libraries/redis_installation_archive.rb) the
Redis database will be built from source.

``` ruby
name 'redis'
default_source :community
run_list 'blp-redis::default'

default['blp-redis']['provider'] = 'archive'
default['blp-redis']['options']['version'] = '3.2.3'
default['blp-redis']['options']['artifact_url'] = 'http://mirror.corporate.com/redis/redis-%{version}.tar.gz'
```

In addition, you may find it useful to use the following Policyfile.rb
for production deployment purposes. This follows a
[post about how to tune Redis][4] and implements these settings using
different (external) cookbooks. This policy can be deployed to the
Chef Server using the `chef push production` command.

``` ruby
name 'redis'
default_source :community
run_list 'ulimit::default', 'sysctl::params', 'blp-redis::default'

# @see http://shokunin.co/blog/2014/11/11/operational_redis.html
# @see https://github.com/ziyasal/redisetup#system-side-settings
override['blp-redis']['config']['tcp_backlog'] = 65_535
override['blp-redis']['config']['maxclients'] = 10_000
override['ulimit']['users']['redis']['filehandle_limit'] = 65_535
override['sysctl']['params']['vm.overcommit_memory'] = 1
override['sysctl']['params']['vm.swappiness'] = 0
override['sysctl']['params']['net.ipv4.tcp_sack'] = 1
override['sysctl']['params']['net.ipv4.tcp_timestamps'] = 1
override['sysctl']['params']['net.ipv4.tcp_window_scaling'] = 1
override['sysctl']['params']['net.ipv4.tcp_congestion_control'] = 'cubic'
override['sysctl']['params']['net.ipv4.tcp_syncookies'] = 1
override['sysctl']['params']['net.ipv4.tcp_tw_recycle'] = 1
override['sysctl']['params']['net.ipv4.tcp_max_syn_backlog'] = 65_535
override['sysctl']['params']['net.core.somaxconn'] = 65_535
override['sysctl']['params']['net.core.rmem_max'] = 65_535
override['sysctl']['params']['net.core.wmem_max'] = 65_535
override['sysctl']['params']['fs.file-max'] = 65_535
```

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern#theapplicationcookbook
[1]: http://redis.io/
[2]: http://redis.io/topics/sentinel
[3]: https://docs.chef.io/config_rb_policyfile.html
[4]: http://shokunin.co/blog/2014/11/11/operational_redis.html
[5]: http://kitchen.ci/
