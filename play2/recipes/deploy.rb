#
# Cookbook Name:: play2
# Recipe:: deploy
#

node[:deploy].each do |application, deploy|
  app_dir    = ::File::expand_path(::File.join(deploy[:deploy_to], "current", deploy[:scm][:app_dir] || '.'))
  shared_dir = ::File.join(deploy[:deploy_to], "shared")

  # Create deploy user and group if needed
  group deploy[:group]

  user deploy[:user] do
    action :create
    gid deploy[:group]
    not_if do
      existing_usernames = []
      Etc.passwd {|user| existing_usernames << user['name']}
      existing_usernames.include?(deploy[:user])
    end
  end

  # Seems to be needed or else deploy_revision crashes
  directory shared_dir do
    recursive true
    owner deploy[:user]
    group deploy[:group]
    action :create
  end

  timestamped_deploy "#{deploy[:deploy_to]}" do
    repo     deploy[:scm][:repository]
    revision deploy[:scm][:revision] || "master"

    user deploy[:user]
    group deploy[:group]

    symlink_before_migrate.clear
    purge_before_symlink(%w{logs})
    create_dirs_before_symlink.clear
    symlinks({"logs" => "logs"})

    before_symlink do
      directory ::File.join(shared_dir, "logs") do
        action :create
      end
    end

    # restart_command "echo whoami && sudo service #{application} restart"
    before_restart do
      # Create the application configuration file
      template ::File.join(app_dir, "conf/application.conf") do
        source "app_conf.erb"
        owner deploy[:user]
        group deploy[:group]
        mode  "0644"
        backup false
        variables({
          :flat_conf => play_flat_config(node[:play2][:conf])
        })
        only_if do
          node[:play2][:conf] != nil
        end
      end

      # Create the logging configuration file
      template ::File.join(app_dir, "conf/logger.xml") do
        source "app_logging.erb"
        owner deploy[:user]
        group deploy[:group]
        mode  "0644"
        backup false
      end

      template "/etc/logrotate.d/opsworks_#{application}" do
        source "app_logrotate.erb"
        owner "root"
        group "root"
        mode "0644"
        backup false
        variables( :log_dirs => [ ::File.join(shared_dir, "logs") ] )
      end

      execute "package #{application}" do
        cwd app_dir
        user "root"
        command "play clean stage"
      end

      # Create the service for the application
      template "/etc/init.d/#{application}" do
        source "app_initd.erb"
        owner "root"
        group "root"
        mode  "0755"
        backup false
        variables({
          :name => application,
          :path => app_dir,
          :options => play_options(),
          :command => "target/start"
        })
      end

      service application do
        supports :status => true, :start => true, :stop => true, :restart => true
        action :enable
      end
    end

    action :deploy
  end

  execute "restart #{application}" do
    user "root"
    command "sudo service #{application} restart"
  end
end