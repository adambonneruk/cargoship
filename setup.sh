# Update the Pi
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove && sudo apt-get autoclean

# Custom htop with temp
wget https://github.com/wbenny/htop/files/573914/htop_2.0.2-2_armhf.deb.zip
unzip htop_2.0.2-2_armhf.deb.zip
sudo dpkg -i htop_2.0.2-2_armhf.deb
rm -rf ~/.config/htop/htoprc

# Install Vim
sudo apt-get install vim -y

#INstall Git
sudo apt-get install git -y