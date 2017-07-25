#
# Cookbook:: t1000
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


user 'canary' do
  action :create
  comment 'Canary User'
  gid 'users'
  home '/home/canary'
  shell '/bin/bash'
  password '$1$JJsvHslV$szsCjVEroftprNn4JHtDi.'
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


package 'install_python_general_deps' do
  package_name ['python-dev', 'python-pip', 'python-virtualenv','build-essential', 'libssl-dev', 'libffi-dev', 'samba', 'syslog-ng-core', 'libpcap-dev' ]
  action :install
end

package 'install_opencanary_t1000_deps' do
#  package_name ['nmap', 'nginx', 'git']
  package_name ['nmap', 'git']
  action :install
end


file '/etc/nginx/sites-enabled/default' do
  action :delete
end


execute 'pip_opencanary_deps' do
  command 'pip install scapy; pip install rdpy; pip install --upgrade pyopenssl; pip install pcapy; pip install python-nmap'
  action :run
  not_if do ::File.exists?('/usr/local/bin/opencanaryd') end
end

execute 'install_opencanary_t1000' do
  command 'cd tmp; git clone https://github.com/chriswhitehat/opencanary.git; cd opencanary; python setup.py install'
  action :run
  not_if do ::File.exists?('/usr/local/bin/opencanaryd') end  
end


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



template '/etc/smb/smb.conf' do
  source 'smb/smb.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


template '/etc/syslog-ng/conf.d/smb.conf' do
  source 'syslog-ng/smb.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


