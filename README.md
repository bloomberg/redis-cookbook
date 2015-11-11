# Redis Server Cookbook
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

[Application cookbook][0] which installs and configures the [redis-server][1] monitoring daemon. Currently it defaults to ubuntu. 

## Usage
### Supports
- Ubuntu

### Dependencies
| Name | Description |
|------|-------------|
| [poise][2] | [Library cookbook][4] built to aide in writing reusable cookbooks. |
| [poise-service][3] | [Library cookbook][4] built to abstract service management. |

### Attributes
All attributes are built directly into the resource and most if not all have default settings attached(same that come packaged with redi    s). You can view all default attributes here [Attributes][5]. I did this attributes this way to give the user full range of tuning and tweaking every setting that redis comes with. IMO it is a better approach for this service over using a gigantic hash.

### Resources/Providers

#### redis_instance
The most basic approach to get all of the default redis settings is here:

```ruby
redis_instance "redis"
```

You have the ability to tune everything and anything redis. You simply have to pass the attribute name like so:

```ruby
redis_instance "redis" do
  bind "172.16.10.10"
end
```

You have the ability to enable sentinel with the below block.
```ruby
redis_instance "redis" do
  sentinel true
end
```

License & Authors
-----------------
- Author:: Anthony Caiafa (<acaiafa1@bloomberg.net>)

```text
Copyright 2015 Bloomberg Finance L.P.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern#theapplicationcookbook
[1]: http://redis.io/
[2]: https://github.com/poise/poise
[3]: https://github.com/poise/poise-service
[4]: http://blog.vialstudios.com/the-environment-cookbook-pattern#thelibrarycookbook
[5]: libraries/redis_instance.rb
