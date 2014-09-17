define :opsworks_play2 do
    application = params[:app]
    deploy = params[:deploy_data]

    app_dir    = File.expand_path(File.join(deploy[:deploy_to], "current", deploy[:scm][:app_dir] || '.'))
    shared_dir = File.join(deploy[:deploy_to], "shared")

    # Create deploy user and group if needed
    group deploy[:group]

    user deploy[:user] do
      action :create
      comment "deploy user for #{application}"
      gid deploy[:group]

      not_if do
        existing_usernames = []
        Etc.passwd {|user| existing_usernames << user['name']}
        existing_usernames.include?(deploy[:user])
      end
    end

    if deploy[:scm][:ssh_key] != nil
        directory "/home/#{deploy[:user]}/.ssh" do
          recursive true
          owner deploy[:user]
          action :create
        end

        file "/home/#{deploy[:user]}/.ssh/id_deploy" do
          owner deploy[:user]
          mode 0400
          content deploy[:scm][:ssh_key]
          action :create_if_missing
        end

        template "/home/#{deploy[:user]}/.ssh/wrap-ssh4git.sh" do
          source "wrap-ssh4git.sh"
          cookbook "play2"
          owner deploy[:user]
          mode 0700
          variables({
            :private_key => "/home/#{deploy[:user]}/.ssh/id_deploy"
          })
          action :create_if_missing
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
      ssh_wrapper deploy[:scm][:ssh_key] != nil ? "/home/#{deploy[:user]}/.ssh/wrap-ssh4git.sh" : nil

      user deploy[:user]
      group deploy[:group]

      symlink_before_migrate.clear
      purge_before_symlink(%w{logs})
      create_dirs_before_symlink.clear
      symlinks({"logs" => "#{deploy[:scm][:app_dir]}/logs"})

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
          cookbook "play2"
          owner deploy[:user]
          group deploy[:group]
          mode  "0644"
          backup false
          variables({
            :flat_conf => play_flat_config(node[:play2][:conf] || {})
          })
          only_if do
            node[:play2][:conf] != nil
          end
        end

        # Create the logging configuration file
        template ::File.join(app_dir, "conf/logger.xml") do
          source "app_logging.erb"
          cookbook "play2"
          owner deploy[:user]
          group deploy[:group]
          mode  "0644"
          backup false
        end

        template "/etc/logrotate.d/opsworks_#{application}" do
          source "app_logrotate.erb"
          cookbook "play2"
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
          cookbook "play2"
          owner "root"
          group "root"
          mode  "0755"
          backup false
          variables({
            :name => application,
            :path => app_dir,
            :deploy_to => deploy[:deploy_to],
            :options => play_options(),
            :command => "target/start",
            :url => play_url()
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