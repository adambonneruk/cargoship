# cargoship
_hosting unifi, pihole, gitea etc. using docker-compose and nginx_

Running on a x86-64 micro server, this configuration uses docker-compose to serve several useful network appliances via https. Each appliance is served as a unique fqdn through the nginx reverse proxy which also manages the tls certificates.

<img align="right" src=".images/cargoship-icon.png" />

#### Components
Each service runs inside the ```cargonet``` docker network and is exposed via the nginx reverse proxy. Using pihole to serve memorable domain names "example.bonner.uk" results in a clean setup and few ports shared wtih the host (current a Dell OptiPlex 7040 micro PC).

##### Infrastructure
- Unifi Controller ([docker](https://hub.docker.com/r/jacobalberty/unifi/)): Control all of my Ubiquiti/Unifi devices
- [PiHole](https://pi-hole.net/) ([docker](https://hub.docker.com/u/pihole/)): DNS-based adblocking
- [NGM](https://nginxproxymanager.com/) ([docker](https://hub.docker.com/r/jc21/nginx-proxy-manager/)): Nginx Reverse-Proxy with TSL/SSL Management

##### Web Apps
- Gitea ([docker](https://hub.docker.com/r/gitea/gitea)): Self-Hosted Source Forge (like GitHub)
- OpenSpeedTest ([docker](https://hub.docker.com/r/openspeedtest/latest)): SpeedTest the network via HTML5
- NTP Server ([docker](https://hub.docker.com/r/cturra/ntp/dockerfile/)): Simple NTP server running on port 123

Useful Links / Further Reading:
- [Dropbox + Rclone auto-backup of unifi-controller](https://lazyadmin.nl/home-network/backup-unifi-controller-to-cloud/?unapproved=2920&moderation-hash=877022b0e9d44011245705e6e37a472f#comment-2920) from _lazyadmin.nl_
- [Cloudflare DNS (1.1.1.1)](https://blog.cloudflare.com/announcing-1111/)
- [Configure L2TP VPN in Unifi](https://vninja.net/2019/04/10/ubiquiti-usg-remote-user-vpn-using-l2tp/)
- [Generate a Secure PSK](https://cloud.google.com/network-connectivity/docs/vpn/how-to/generating-pre-shared-key)
- [Firebog Block Lists](https://firebog.net/): collection of adblock lists

## System Setup
### Update, upgrade and install software
```sh
sudo apt update
sudo apt upgrade
sudo apt install htop
sudo apt install tmux
sudo apt install vim
sudo apt install git
sudo apt install docker-compose
sudo apt install rclone
sudo apt install smartmontools
```
### Hostfile and Network configuration

edits to ```/etc/hostname```
   ```
   cargoship
   ```

edits to ```/etc/hosts```
   ```
   127.0.0.1       localhost
   10.10.10.100    cargoship.bonner.uk cargoship

   # allow this server to see git hosting
   10.10.10.10     code.bonner.uk
   ```

edits to ```/etc/network/interfaces```
   ```
   iface XXXXXXXXX inet static
      address 10.10.10.100
      netmask 255.255.255.0
      gateway 10.10.10.1
      dns-nameservers 1.1.1.1
   ```

restart network after configuration edits
   ```sh
   sudo service networking restart
   ```

### Profile configuration
```.bashrc``` profile additions
```bash
# alias
alias ll='ls -lah'
alias cls='clear'
alias dc='docker-compose'

# functions
temp() {
        paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'
}

ctop() {
   docker run --rm -ti --name=ctop -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest
}

# other
if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@$(hostname -f)\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
        PS1='${debian_chroot:+($debian_chroot)}\u@$(hostname -f):\w\$ '
fi
```

### Hardware monitoring and configuration

HDD S.M.A.R.T charcateristics

   ```sh
   sudo smartctl -i /dev/sda -a
   ```

Check a NTP time server
   ```sh
   sudo ntpdate -q time.google.com
   ```

Check disk usage
   ```sh
   df -h
   ```
## Docker configuration
give user (adam) permission to run docker
   ```sh
   sudo usermod -aG docker adam
   ```

create the netwrok used by _cargoship_, we'll call this cargonet
   ```sh
   docker network create cargonet
   ```

### gitea folders
create the data and config folders
   ```sh
   mkdir -p gitea/{data,config}
   ```

assign permissions
   ```sh
   sudo chown 1000:1000 config/ data/
   ```

### pihole admin password
execute command inside the docker container
   ```sh
   pihole -a -p CorrectHorseBatteryStaple
   ```

### docker-compose reference
start up service xxxxx
   ```sh
   dc up -d xxxxx
   ```

spin down service xxxxx
   ```sh
   dc down xxxxx
   ```

view docker processes
   ```sh
   dc ps
   ```

## Rclone and Cron configuration
### Rclone
setup rclone
   ```sh
   rclone config
   ```

simple config steps
   ```
   N
   dropbox
   13
   enter key (client id = blank)
   enter key (client secret = blank)
   N
   N
   ```

switch to wintows and [install](https://rclone.org/downloads/) command line version
   ```cmd
   rclone authorize dropbox
   ```

switch back to linux and complete install
   ```
   Paste the key
   Y
   ```

### cron
copy command for unifi

   ```shell
   rclone copy /home/adam/cargo/unifi/data/backup/ dropbox:Rclone/optiplex-unifi
   ```

sync command for gitea
   ```shell
   rclone sync /home/adam/cargo/gitea/data/git/ dropbox:Rclone/optiplex-gitea
   ```

#### configure backup jobs for gitea and unifi
   with ```crontab -e```, configure...
   ```crontab
   0 5 * * * rclone copy /home/adam/cargo/unifi/data/backup/ dropbox:Rclone/optiplex-unifi
   0 4 * * 0 rclone sync /home/adam/cargo/gitea/data/git/ dropbox:Rclone/optiplex-gitea
   ```
