#
# Cookbook Name:: servicetown
# Recipe:: deploy
#
# Copyright (C) 2013 Originate, Inc
#
# All rights reserved - Do Not Redistribute
#

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  opsworks_deploy_dir do
    user  deploy[:user]
    group deploy[:group]
    path  deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end