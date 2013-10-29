#
# Cookbook Name:: play2
# Recipe:: deploy
#
# Copyright (C) 2013 Originate, Inc
#
# All rights reserved - Do Not Redistribute
#

node[:deploy].each do |application, deploy|
  directory ::File.join(deploy[:deploy_to], "shared") do
    recursive true
    action :create
  end

  deploy_revision "#{deploy[:deploy_to]}" do
    repo     deploy[:scm][:repository]
    revision deploy[:scm][:revision] || "master"

    symlink_before_migrate.clear
    create_dirs_before_symlink.clear
    purge_before_symlink.clear
    symlinks.clear

    restart_command "sudo service #{application} restart"
    before_restart do
      # Create the application template
      template ::File.join(release_path, "conf/application.conf") do
        source "app_conf.erb"
        owner "root"
        group "root"
        mode  "0755"
        variables({
          :flat_conf => play_flat_config(node[:play2][:conf])
        })
      end

      execute "package the application" do
        cwd release_path
        user "root"
        command "play clean stage"
      end

      # Update the service template
      template "/etc/init.d/#{application}" do
        source "app_service.erb"
        owner "root"
        group "root"
        mode  "0755"
        variables({
          :name => application,
          :path => release_path,
          :options => play_options(),
          :command => "target/start"
        })
      end

      service application do
        supports :status => true, :start => true, :stop => true, :restart => true
        action :enable
      end
    end

    action :force_deploy
  end
end