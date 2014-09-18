Vagrant.configure("2") do |config|
  config.vm.hostname = "play2-berkshelf"

  config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"

  config.vm.network :private_network, ip: "33.33.33.10"
  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.omnibus.chef_version = "11.4.4"

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :play2 => {
        :version => '2.1.3',
        :http_port => 80
      },
      :deploy => {
        :sample => {
          :user => "sample",
          :group => "sample",
          :deploy_to => "/opt/sample",
          :scm => {
            :repository => "git://github.com/Bowbaq/sample-play-app.git",
          }
        }
      }
    }

    chef.run_list = [
      "recipe[play2::setup]",
      "recipe[play2::deploy]"
    ]
  end
end
