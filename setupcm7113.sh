#! /bin/bash
# useage: ./setup719.sh aws templates/base.json "your download userID" "your download password
# Current version of this script is based on centos7.  With mods it should work for later RHEL versions.  Wouldn't need the python 3.8 buid section 
start_dir=$PWD
echo "-- Start dir is ${start_dir}"
echo "-- Configure and optimize the OS"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.d/rc.local
# add tuned optimization https://www.cloudera.com/documentation/enterprise/6/6.2/topics/cdh_admin_performance.html
echo  "vm.swappiness = 1" >> /etc/sysctl.conf
sysctl vm.swappiness=1
timedatectl set-timezone UTC

echo "-- Install Java OpenJDK8 and other tools"
yum install -y java-1.8.0-openjdk-devel vim wget curl git bind-utils rng-tools
yum install -y epel-release
yum install -y python-pip

# Install python 3.8 for needed for Hue in 7.1.9 on Centos7 - more recent Linux will have python 3.8+ options
yum install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel
yum install -y gcc-c++ make
yum install -y libffi-devel
cd /opt
curl -O https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
tar -zxvf Python-3.8.12.tgz
cd Python-3.8.12*
./configure --enable-shared
make
make install
cp --no-clobber ./libpython3.8.so* /lib64/
chmod 755 /lib64/libpython3.8.so*
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/
echo $PATH
chmod -R 755 /usr/local/lib/python3.8

echo "Environment="PYTHONBIN=/usr/local/bin/python3.8"" >> /usr/lib/systemd/system/cloudera-scm-supervisord.service
echo "Environment="PYTHONBIN=/usr/local/bin/python3.8"" >> /usr/lib/systemd/system/cloudera-scm-agent.service

pip3.8 install psycopg2-binary

cd /root/Sin*

cp /usr/lib/systemd/system/rngd.service /etc/systemd/system/
systemctl daemon-reload
systemctl start rngd
systemctl enable rngd


# Check input parameters
case "$1" in
        aws)
            echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
            systemctl restart chronyd
            ;;
        azure)
# default root disk in most Azure Centos images is often small so second disk may be needed for /opt
# if you are already using /opt before the CDH install you may need to adjust this step as appropriate
# the temp disk used in the Cloudera Centos image on Azure on /mnt/resource may be an option if not persisting image
#            umount /mnt/resource
#            mount /dev/sdb1 /opt
            echo "server time.windows.com prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
            systemctl restart chronyd
            ;;
        gcp)
            ;;
        *)
            echo $"Usage: $0 {aws|azure|gcp} template-file [docker-device]"
            echo $"example: ./setup.sh azure templates/essential.json"
            echo $"example: ./setup.sh aws template/cml.json /dev/xvdb"
            exit 1
esac

TEMPLATE=$2
DOWNLOADUSER=$3
DOWNLOADPASS=$4

echo "-- Configure networking"
PUBLIC_IP=`curl https://api.ipify.org/`
hostnamectl set-hostname `hostname -f`
echo "`hostname -I` `hostname`" >> /etc/hosts
sed -i "s/HOSTNAME=.*/HOSTNAME=`hostname`/" /etc/sysconfig/network
systemctl disable firewalld
systemctl stop firewalld
setenforce 0
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config


echo "-- Install CM and MariaDB"

## CM 7
wget https://$DOWNLOADUSER:$DOWNLOADPASS@archive.cloudera.com/p/cm7/7.11.3.0/redhat7/yum/cloudera-manager-trial.repo -P /etc/yum.repos.d/
sed -i "s/archive\.cloudera\.com/$DOWNLOADUSER:$DOWNLOADPASS@archive\.cloudera.com\/p/" /etc/yum.repos.d/cloudera-manager-trial.repo

## MariaDB
cat - >/etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF


yum clean all
rm -rf /var/cache/yum/
yum repolist

## CM
yum install -y cloudera-manager-agent cloudera-manager-daemons cloudera-manager-server

## MariaDB
yum install -y MariaDB-server MariaDB-client
cat conf/mariadb.config > /etc/my.cnf

echo "--Enable and start MariaDB"
systemctl enable mariadb
systemctl start mariadb

echo "-- Install JDBC connector"
wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-5.1.49.tar.gz -P ~
tar zxf ~/mysql-connector-java-5.1.49.tar.gz -C ~
mkdir -p /usr/share/java/
cp ~/mysql-connector-java-5.1.49/mysql-connector-java-5.1.49-bin.jar /usr/share/java/mysql-connector-java.jar
rm -rf ~/mysql-connector-java-5.1.49*

# Install the MySQL Client
yum install -y xmlsec1  xmlsec1-openssl
export PATH=/usr/local/bin:$PATH
yum -y install mariadb-devel
pip3.8 install mysqlclient

echo "-- Create DBs required by CM"
mysql -u root < scripts/create_db.sql

echo "-- Secure MariaDB"
mysql -u root < scripts/secure_mariadb.sql

echo "-- Prepare CM database 'scm'"
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm cloudera


## PostgreSQL see: https://www.postgresql.org/download/linux/redhat/
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

#yum install -y postgresql
sudo yum install -y postgresql11-server

pip install psycopg2==2.7.5 --ignore-installed
#pip install psycopg2==2.9.5 --ignore-installed - got some erros to fix yet on this version install needed for later CDP Base versions

echo 'LC_ALL="en_US.UTF-8"' >> /etc/locale.conf

/usr/pgsql-11/bin/postgresql-11-setup initdb

cat conf/pg_hba.conf > /var/lib/pgsql/11/data/pg_hba.conf
cat conf/postgresql.conf > /var/lib/pgsql/11/data/postgresql.conf

echo "--Enable and start pgsql"
#systemctl enable postgresql-9.6
#systemctl start postgresql-9.6
sudo systemctl enable postgresql-11
sudo systemctl start postgresql-11

echo "-- Create DBs required by CM"
sudo -u postgres psql <<EOF 
CREATE DATABASE ranger;
CREATE USER ranger WITH PASSWORD 'cloudera';
GRANT ALL PRIVILEGES ON DATABASE ranger TO ranger;
CREATE DATABASE das;
CREATE USER das WITH PASSWORD 'cloudera';
GRANT ALL PRIVILEGES ON DATABASE das TO das;
EOF


echo "-- Install additional CSDs if using any in addition to the CDP Base parcel. These can also be installed later if desired from the Cloudera site directly or local copy as below"


# install local CSDs
mv ~/*.jar /opt/cloudera/csd/
mv /home/centos/*.jar /opt/cloudera/csd/
chown cloudera-scm:cloudera-scm /opt/cloudera/csd/* 
chmod 644 /opt/cloudera/csd/*

echo "-- Install local parcels"
mv ~/*.parcel ~/*.parcel.sha /opt/cloudera/parcel-repo/
mv /home/centos/*.parcel /home/centos/*.parcel.sha /opt/cloudera/parcel-repo/
chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo/*


echo "-- Enable passwordless root login via rsa key"
ssh-keygen -f ~/myRSAkey -t rsa -N ""
mkdir ~/.ssh
cat ~/myRSAkey.pub >> ~/.ssh/authorized_keys
chmod 400 ~/.ssh/authorized_keys
ssh-keyscan -H `hostname` >> ~/.ssh/known_hosts
sed -i 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config
systemctl restart sshd

echo "-- Start CM, it takes about 2 minutes to be ready"
systemctl start cloudera-scm-server

while [ `curl -s -X GET -u "admin:admin"  http://localhost:7180/api/version` -z ] ;
    do
    echo "waiting 10s for CM to come up..";
    sleep 10;
done

echo "-- Now CM is started and the next step is to automate using the CM API"

wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python ./get-pip.py
pip install --upgrade cm_client
#pip install --upgrade pip cm_client
echo "-- Kicking off install from ${start_dir}"
cd ${start_dir}
sed -i "s/YourHostname/`hostname -f`/g" $TEMPLATE
#sed -i "s/YourCDSWDomain/cdsw.$PUBLIC_IP.nip.io/g" $TEMPLATE
sed -i "s/YourPrivateIP/`hostname -I | tr -d '[:space:]'`/g" $TEMPLATE
#sed -i "s#YourDockerDevice#$DOCKERDEVICE#g" $TEMPLATE

sed -i "s/DOWNLOADUSER/$DOWNLOADUSER/g" $TEMPLATE
sed -i "s/DOWNLOADPASS/$DOWNLOADPASS/g" $TEMPLATE

# Still need to fix the create_cluster.py to use archive CM repo URL with the download user:pass and latest CM API vseion v54
# That would start the CM agent with the template. Until then just starting CM agent manually in this script
# Will get one error that can be ignored when it creates the cluster on adding a host since we are doing that manually currently by starting a CM Agent
#sed -i "s/archive\.cloudera\.com\/cm7\/7.4.4/$DOWNLOADUSER:$DOWNLOADPASS@archive\.cloudera\.com\/p\/cm7\/7.11.3.0/" scripts/create_cluster.py
#sed -i "s/v40/v54/" scripts/create_cluster.py

# start the CM Agent
systemctl start cloudera-scm-agent
echo "waiting 120s for CM Agent to come up..";
sleep 120;
systemctl status cloudera-scm-agent

# Way to involve create_cluster with a download user:pass added in the json cluster template
# 719 is behind the paywall and requires a download user pass so required for that version
sed -i "s/archive\.cloudera\.com/$DOWNLOADUSER:$DOWNLOADPASS@archive\.cloudera.com/" templates/719base.json
python scripts/create_cluster.py $TEMPLATE




