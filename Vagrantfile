# -*- mode: ruby -*-

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install make -y
      sudo apt-get install gcc -y
      sudo apt-get install xorriso -y
      sudo apt-get install git -y
      sudo apt-get install vim -y
      sudo apt-get install qemu -y
      curl -sf https://raw.githubusercontent.com/brson/multirust/master/blastoff.sh | sh -s -- --yes
      multirust default nightly
  SHELL

  config.ssh.forward_x11 = true
end
