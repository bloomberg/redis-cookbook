require 'serverspec'
set :backend, :exec

describe service('redis') do
  it { should exist }
  it { should be_enabled }
  it { should be_running }
end

describe service('redis-sentinel') do
  it { should exist }
  it { should be_enabled }
  it { should be_running }
end
