#! /bin/sh

# install core packages, nginx and mysql
sudo yum install -y epel-release policycoreutils-python python-pip nginx mariadb

# open ports and allow server access to network resources
sudo semanage port -m -t http_port_t -p tcp 81
sudo semanage port -a -t http_port_t -p tcp 8001
sudo setsebool -P httpd_can_network_connect_db=1
sudo setsebool -P httpd_can_network_connect=1
sudo setsebool -P httpd_setrlimit 1

# add the archivematica repositories
sudo -u root bash -c 'cat << EOF > /etc/yum.repos.d/archivematica.repo
[archivematica]
name=archivematica
baseurl=https://packages.archivematica.org/1.10.x/centos
gpgcheck=1
gpgkey=https://packages.archivematica.org/1.10.x/key.asc
enabled=1
EOF'

sudo -u root bash -c 'cat << EOF > /etc/yum.repos.d/archivematica-extras.repo
[archivematica-extras]
name=archivematica-extras
baseurl=https://packages.archivematica.org/1.10.x/centos-extras
gpgcheck=1
gpgkey=https://packages.archivematica.org/1.10.x/key.asc
enabled=1
EOF'

# install the archivematica storage service
sudo yum install -y archivematica-storage-service

sudo -u root systemctl enable archivematica-storage-service
sudo -u root systemctl enable nginx
sudo -u root systemctl enable rngd
