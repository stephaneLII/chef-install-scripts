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


if node['chef-install-scripts']['databag']['encrypted'] == true
  secret = Chef::EncryptedDataBagItem.load_secret(node['chef-install-scripts']['databag']['secret_path'])
  item =  Chef::EncryptedDataBagItem.load(node['chef-install-scripts']['databag']['name'], node['chef-install-scripts']['databag']['item'], secret)
else
  item = data_bag_item(node['chef-install-scripts']['databag']['name'], node['chef-install-scripts']['databag']['item'])
end

item["#{node['fqdn']}"].each do |depot|
 puts depot

 directory depot['directory_replication'] do
   owner "#{depot['user']}"
   group "#{depot['group']}"
   mode "#{depot['mode']}"
   action :create
   recursive true
 end

 subversion "replication" do
    repository "#{depot['replication_svn_link']}"
    revision "HEAD"
    destination "#{depot['directory_replication']}"
    svn_username "#{depot['user_svn']}"
    svn_password "#{depot['passwd_svn']}"
    action :sync
 end

 chmod = "chown -R #{depot['user']}:#{depot['group']} #{depot['directory_replication']}"

 bash 'chown_replication_directory' do
   user 'root'
   cwd "#{depot['directory_replication']}"
   code <<-EOH
      #{chmod}
   EOH
 end

end
