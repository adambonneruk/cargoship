# Update the Pi
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove && sudo apt-get autoclean

# Custom htop with temp
wget https://github.com/wbenny/htop/files/573914/htop_2.0.2-2_armhf.deb.zip
unzip htop_2.0.2-2_armhf.deb.zip
sudo dpkg -i htop_2.0.2-2_armhf.deb
rm -rf ~/.config/htop/htoprc

# Install Docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo reboot

# Install docker-compose
sudo apt-get install -y libffi-dev libssl-dev
sudo apt-get install -y python3 python3-pip
sudo pip3 -v install docker-compose

# Install Vim
sudo apt-get install vim -y

#Install Git
sudo apt-get install git -y
ssh-keygen

# Bash Aliases
vim ~/.bash_aliases
alias temp='/opt/vc/bin/vcgencmd measure_temp'
alias cls=clear