# Redis Cookbook
[![Build Status](https://img.shields.io/travis/bloomberg/redis-cookbook.svg)](https://travis-ci.org/bloomberg/redis-cookbook)
[![Code Quality](https://img.shields.io/codeclimate/github/bloomberg/redis-cookbook.svg)](https://codeclimate.com/github/bloomberg/redis-cookbook)
[![Test Coverage](https://codeclimate.com/github/bloomberg/redis-cookbook/badges/coverage.svg)](https://codeclimate.com/github/bloomberg/redis-cookbook/coverage)
[![Cookbook Version](https://img.shields.io/cookbook/v/nrpe-ng.svg)](https://supermarket.chef.io/cookbooks/nrpe-ng)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

[Application cookbook][0] which installs and configures the [Redis][1]
key-value database and [Redis Sentinel][2] which provides
high-availability for the database.

## Platforms
The following platforms are tested using [Test Kitchen][1]:

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
cookbook 'redis', path: '.'
run_list 'redis::default'

override['redis']['install']['provider'] = :archive
override['redis']['redis']['artifact_url'] = "http://mirror.corporate.com/redis/redis-%{version}.tar.gz"
```

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern#theapplicationcookbook
[1]: http://redis.io/
[2]: http://redis.io/topics/sentinel
