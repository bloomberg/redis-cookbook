require 'spec_helper'

describe service('redis') do
  it { should be_enabled }
  it { should be_running }
end
