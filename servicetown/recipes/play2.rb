#
# Cookbook Name:: servicetown
# Recipe:: play2
#
# Copyright (C) 2013 Originate, Inc
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java"

url     = node[:play2][:url]
version = node[:play2][:version]

artifact_deploy "play2" do
  version node[:play2][:version]
  artifact_location "#{url}/#{version}/play-#{version}.zip"

  deploy_to "/opt/play"
  shared_directories []

  owner "root"
  group "root"

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