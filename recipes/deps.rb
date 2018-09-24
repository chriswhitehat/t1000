#
# Cookbook:: t1000
# Recipe:: deps
#
# Copyright:: 2017, The Authors, All Rights Reserved.


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