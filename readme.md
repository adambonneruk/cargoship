# Configuring the Raspberry Pi with Docker (+More)

## Manual Certificate Refresh (using ```certbot```)
Steps to follow to updated the unifi certificate, put it in correct docker compose folder, (re)pull the newest docker images and restart the services

```bash
# run certbot to get the new certificate
sudo certbot certonly --manual --update --preferred-challenges dns

# put yourself in the right directory
cd docker/unifi/cert/

# copy the new certificate files into the correct (docker-compose image) folder
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/cert.pem .
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/chain.pem .
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/fullchain.pem .
sudo cp /etc/letsencrypt/live/unifi.bonner.uk/privkey.pem .

#put yourself in the right directory
cd ../..

# pull the latest docker images, stop the service and start it as a daemon
docker-compose pull
docker-compose down
docker-compose up -d --build
```

## Install _Docker_ and _Docker Compose_
```bash
# docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo reboot

# docker-compose
sudo apt-get install -y libffi-dev libssl-dev
sudo apt-get install -y python3 python3-pip
sudo pip3 -v install docker-compose
```

## Configure Terminal/Bash Aliases
Open the bash_aliases file in Vim
```bash
vim ~/.bash_aliases
```

Append the following two lines and quit Vim saving the file
```bash
alias temp='/opt/vc/bin/vcgencmd measure_temp'
alias cls=clear
```

## Change Pihole password
The Web interface password needs to be reset via the command line on your Pi-hole. This can be done locally or over SSH. You will use the pihole command to do this:

```bash
pihole -a -p
```

You will be prompted for the new password. If you enter an empty password, the password requirement will be removed from the web interface.

## Custom ```htop``` build with RasPi Temperature
Using [this github](https://github.com/wbenny/htop) project/fork of htop

```bash
cd ~
wget https://github.com/wbenny/htop/files/573914/htop_2.0.2-2_armhf.deb.zip
unzip htop_2.0.2-2_armhf.deb.zip
sudo dpkg -i htop_2.0.2-2_armhf.deb
rm -rf ~/.config/htop/htoprc
```

![](.screenshots/htop-temp.png)

## Backup your Unifi Controller to Dropbox (using ```rclone```)
Using the Linux terminal, follow the process defined below
```bash
# install rclone
curl https://rclone.org/install.sh | sudo bash

# configure rclone
rclone configure
N
dropbox
9
enter key (client id = blank)
enter key (client secret = blank)
N
N
```

Now switch to Windows to complete the authorisation
```ps
# install rclone
choco install rclone -y

# authorise dropbox
rclone authorize dropbox

# web browser will open, follow the steps

# copy the authorisation code to he clipboard
```

Switching back to Linux, complete the setup and start the copy/clone
```bash
# paste the token

# finish and save the config
Y

# go configure a dropbox folder location online

# setup folder permissions on Linux for backup folder access by rclone
sudo usermod -a -G unifi pi

# setup a copy or clone from directory structure to dropbox directory
rclone copy /home/pi/docker/unifi/data/backup/ dropbox:Rclone/dropbox-raspi-unifi
```

Create a scheduled job to keep running the copy/clone
```bash
crontab -e
```

Append the following line to the crontab configuration (this launches with vim)
```cron
0 5 * * * rclone copy /home/pi/docker/unifi/data/backup/ dropbox:Rclone/dropbox-raspi-unifi
```

## Configure ```certbot``` for first-time use
Using the Linux terminal follow the steps using a DNS-based challenge mechanism
```bash
sudo certbot certonly --manual --preferred-challenges dns
```