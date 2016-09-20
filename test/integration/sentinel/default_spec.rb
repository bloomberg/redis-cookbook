describe service('redis-sentinel') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

describe processes('redis-sentinel') do
  its('list.length') { should eq 1 }
  its('users') { should eq %w[redis] }
end

describe group('redis') do
  it { should exist }
end

describe user('redis') do
  it { should exist }
  its('group') { should eq 'redis' }
end

describe file('/usr/bin/redis-sentinel') do
  it { should exist }
  it { should be_file }
  it { should be_executable.by_user 'redis' }
end

describe file('/etc/redis-sentinel.conf') do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'redis' }
  it { should be_grouped_into 'redis' }
  it { should be_mode 640 }
end
