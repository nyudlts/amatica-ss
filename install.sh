#! /bin/sh

# install core packages, nginx and mysql
sudo yum install -y epel-release policycoreutils-python python-pip yum-utils mariadb

# open ports and allow server access to network resources
#semanage port -a -t http_port_t -p tcp 8000
#setsebool -P httpd_can_network_connect_db=1
#setsebool -P httpd_can_network_connect=1
#setsebool -P httpd_setrlimit 1

#intsall nginx repository
bash -c 'cat << EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/7/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF'

# add the archivematica repositories
bash -c 'cat << EOF > /etc/yum.repos.d/archivematica.repo
[archivematica]
name=archivematica
baseurl=https://packages.archivematica.org/1.10.x/centos
gpgcheck=1
gpgkey=https://packages.archivematica.org/1.10.x/key.asc
enabled=1
EOF'

bash -c 'cat << EOF > /etc/yum.repos.d/archivematica-extras.repo
[archivematica-extras]
name=archivematica-extras
baseurl=https://packages.archivematica.org/1.10.x/centos-extras
gpgcheck=1
gpgkey=https://packages.archivematica.org/1.10.x/key.asc
enabled=1
EOF'

# install the archivematica storage service
yum install -y archivematica-storage-service

#enable the services
systemctl enable archivematica-storage-service
systemctl start archivematica-storage-service
systemctl enable rngd
systemctl start rngd

# init the sqlite base
sudo -u archivematica bash -c " \
set -a -e -x
source /etc/sysconfig/archivematica-storage-service
cd /usr/lib/archivematica/storage-service
/usr/share/archivematica/virtualenvs/archivematica-storage-service/bin/python manage.py migrate";

#config and start nginx
cp /tmp/nginx.conf /etc/nginx/nginx.conf

sed -i -e 's/listen 8001 default_server/listen 80 default_server/' /etc/nginx/conf.d/archivematica-storage-service.conf

systemctl enable nginx

systemctl start nginx