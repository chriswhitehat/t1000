#
# Cookbook:: t1000
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


include_recipe 't1000::deps'
#include_recipe 't1000::sshd'


python_runtime '2'


package 'install_deps' do
  package_name ['python-dev', 'build-essential', 'libssl-dev', 'libffi-dev', 'syslog-ng-core', 'libpcap-dev', 'nmap', 'git' ]
  action :install
end

python_package 'install_python_deps' do
  package_name ['scapy', 'rdpy']
end

python_package 'upgrade_python_deps' do
  package_name ['pyopenssl']
  action :upgrade
end

python_package 'install_python_deps2' do 
  package_name ['pcapy', 'python-nmap']
end

python_package 'upgrade_python_deps2' do
  package_name ['twisted']
  action :upgrade
end


directories = ['/etc/opencanaryd', '/etc/opencanaryd/ssl', '/etc/smb/']

directories.each do |directory|

  directory "#{directory}" do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

directory '/var/log/opencanary/' do
  owner 'root'
  group 'root'
  mode '0766'
  action :create
end


user 'canary' do
  action :create
  comment 'Canary User'
  gid 'users'
  home '/home/canary'
  shell '/bin/bash'
  password '$1$JJsvHslV$szsCjVEroftprNn4JHtDi.'
end


remote_file '/tmp/mitmproxy-2.0.2-linux.tar.gz' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'https://github.com/mitmproxy/mitmproxy/releases/download/v2.0.2/mitmproxy-2.0.2-linux.tar.gz'
  checksum '6da28a8fa67de25c3d753b34524b8a49156e82a5f25f23989b1ebb386f29574f'
  not_if do ::File.exists?('/usr/local/bin/mitmproxy') end
  notifies :run, 'execute[extract_mitmproxy]', :immediately
end

execute 'extract_mitmproxy' do
  command 'tar -xzf /tmp/mitmproxy-2.0.2-linux.tar.gz -C /usr/local/bin'
  action :nothing
end



git "#{Chef::Config[:file_cache_path]}/opencanary" do
  repository 'https://github.com/chriswhitehat/opencanary.git'
  reference 'master'
  action :sync
  notifies :run, 'bash[install_opencanary]'
end

bash 'install_opencanary' do
  cwd "#{Chef::Config[:file_cache_path]}/opencanary"
  user 'root'
  group 'root'
  code <<-EOH
    python setup.py install
    EOH
  action :nothing
end

# execute 'install_opencanary_t1000' do
#   command 'cd tmp; git clone https://github.com/chriswhitehat/opencanary.git; cd opencanary; python setup.py install'
#   action :run
#   not_if do ::File.exists?('/usr/local/bin/opencanaryd') end  
#end


# Fix to overcome egg run script bug in setup.py
# https://github.com/thinkst/opencanary/issues/34
execute 'replace_opencanary_tac' do
  command 'mv /tmp/opencanary/bin/opencanary.tac /usr/local/bin/opencanary.tac; mv /tmp/opencanary/bin/t1000.py /usr/local/bin/t1000.py; rm -rf /tmp/opencanary'
  only_if do ::File.exists?('/tmp/opencanary/bin/opencanary.tac') end  
  action :run
end


template '/etc/opencanaryd/default.json' do
  source 'opencanary/default.json.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


template '/etc/opencanaryd/t1000.target' do
  source 't1000.target.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[scan_target]', :immediately
end

execute 'scan_target' do
  command "/usr/bin/python /usr/local/bin/t1000.py --scan --target '#{node[:t1000][:target]}'"
  action :nothing
end

cron 't1000_patrol' do
  minute '*/5'
  path "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
  command '/usr/bin/python /usr/local/bin/t1000.py --patrol --conf /etc/opencanaryd/t1000.conf'
end

cron 't1000_scan' do
  minute '0'
  hour '8'
  weekday '1'
  path "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
  command "/usr/bin/python /usr/local/bin/t1000.py --scan --target '#{node[:t1000][:target]}'"
end



# template '/etc/smb/smb.conf' do
#   source 'smb/smb.conf.erb'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end


# template '/etc/syslog-ng/conf.d/smb.conf' do
#   source 'syslog-ng/smb.conf.erb'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end


