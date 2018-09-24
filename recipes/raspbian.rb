#
# Cookbook:: t1000
# Recipe:: raspbian
#
# Copyright:: 2018, The Authors, All Rights Reserved.

node.default[:kp_env][:PATH] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"


include_recipe 't1000::deps'


package 'dnsutils' do
  action :install
end


gem_package 'ruby-shadow'

file '/etc/systemd/system/pibakery.service' do
  action :delete
end


file '/etc/systemd/system/multi-user.target.wants/pibakery.service' do
  action :delete
end

execute 'remove PiBakery' do
  command 'rm -rf /opt/PiBakery /boot/PiBakery'
  creates '/tmp/something'
  only_if do ::File.exists?('/opt/PiBakery') end
  action :run
end
        
execute 'remove_raspbian_bootstrap' do
  command 'rm -rf /boot/raspbian_bootstrap*'
  creates '/tmp/something'
  only_if do ::File.exists?('/boot/raspbian_bootstrap.py') end
  action :run
end

template '/etc/default/keyboard' do
  source 'raspbian/keyboard.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/boot/config.txt' do
  source 'raspbian/config.txt.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
