VAGRANTFILE_API_VERSION = "2"

$script = <<ENDSCRIPT
  sudo apt update -y
  sudo apt install openjdk-17-jdk -y
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  wget http://ftp.kr.debian.org/debian/pool/main/i/init-system-helpers/init-system-helpers_1.60_all.deb
  sudo apt install ./init-system-helpers_1.60_all.deb
  sudo apt-get install -y ca-certificates
  sudo apt-get update -y
  sudo apt-get install jenkins -y
  sudo systemctl enable jenkins
  sudo systemctl start jenkins
ENDSCRIPT

$sonar_script = <<SCRIPT
  sudo apt update -y
  sudo apt-get install ca-certificates curl gnupg -y
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update -y
  sudo apt-get install docker-ce -y
  sudo usermod -aG docker vagrant
  sudo docker run -d --name sonarqube -p 9000:9000 sonarqube
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "jenkinsserver" do |jenkinsserver|
    jenkinsserver.vm.box_download_insecure = true
    jenkinsserver.vm.box = "bento/ubuntu-24.04"
    jenkinsserver.vm..box_version = "202404.26.0"
    jenkinsserver.vm.network "forwarded_port", guest: 8080, host: 8080
    jenkinsserver.vm.network "private_network", ip: "100.0.0.2"
    jenkinsserver.vm.hostname = "jenkinsserver"
    jenkinsserver.vm.provider "virtualbox" do |v|
      v.name = "jenkinsserver"
      v.memory = 2048
      v.cpus = 2
    end
    jenkinsserver.vm.provision "shell", inline: $script
  end
  
    config.vm.define "sonarserver" do |sonarserver|
      sonarserver.vm.box_download_insecure = true
      jenkinsserver.vm.box = "bento/ubuntu-24.04"
      jenkinsserver.vm..box_version = "202404.26.0"
      sonarserver.vm.network "forwarded_port", guest: 9000, host: 9000
      sonarserver.vm.network "private_network", ip: "100.0.0.3"
      sonarserver.vm.hostname = "sonarserver"
      sonarserver.vm.provider "virtualbox" do |v|
        v.name = "sonarserver"
        v.memory = 2048
        v.cpus = 2
      end
      sonarserver.vm.provision "shell", inline: $sonar_script
    end
end
