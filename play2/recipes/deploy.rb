#
# Cookbook Name:: play2
# Recipe:: deploy
#

node[:deploy].each do |application, deploy|
  opsworks_play2 do
    app application
    deploy_data deploy
  end
end