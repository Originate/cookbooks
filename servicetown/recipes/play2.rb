#
# Cookbook Name:: servicetown
# Recipe:: play2
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java"

base = node[:play2][:url]
version = node[:play2][:version]

artifact_deploy "play2" do
  version node[:play2][:version]
  artifact_location "#{base}/#{version}/play-#{version}.zip"

  deploy_to "/opt/play"
  shared_directories []

  owner node[:servicetown][:user]
  group node[:servicetown][:group]

  after_extract Proc.new {
    execute "move files into place" do
      cwd release_path
      command "mv play-#{version}/* ."
    end

    directory "#{release_path}/play-#{version}" do
      action :delete
    end
  }

  after_deploy Proc.new {
    link "/usr/bin/play" do
      to "#{release_path}/play"
    end
  }

  action :deploy
end