#
# Cookbook Name:: chef-install-scripts
# Recipe:: default
#
# Copyright (C) 2015 Stephane LII
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apt::default'

package 'subversion' do
   action :install
end

directory node['chef-install-scripts']['directory_replication'] do
   owner "#{node['chef-install-scripts']['user']}"
   group "#{node['chef-install-scripts']['group']}"
   mode "#{node['chef-install-scripts']['mode']}"
   action :create
   recursive true
end

subversion "replication" do
    repository "#{node['chef-install-scripts']['replication_svn_link']}"
    revision "HEAD"
    destination "#{node['chef-install-scripts']['directory_replication']}"
    svn_username "#{node['chef-install-scripts']['user_svn']}"
    svn_password "#{node['chef-install-scripts']['passwd_svn']}"
    action :sync
end

chmod = "chown -R #{node['chef-install-scripts']['user']}:#{node['chef-install-scripts']['group']} #{node['chef-install-scripts']['directory_replication']}"

bash 'chown_replication_directory' do
   user 'root'
   cwd "#{node['chef-install-scripts']['directory_replication']}"
   code <<-EOH
      #{chmod}
   EOH
end
