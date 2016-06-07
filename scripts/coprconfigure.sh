#!/bin/bash

#Copyright
# All Rights Reserved
#

function installRepositories
{
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-oss \
         --no-gpgcheck http://download.opensuse.org/distribution/13.2/repo/oss/suse suse-13.2-oss
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-oss-update \
         --no-gpgcheck http://download.opensuse.org/repositories/openSUSE:/13.2:/Update/standard suse-13.2-oss-update
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-non-oss \
         --no-gpgcheck http://download.opensuse.org/distribution/13.2/repo/non-oss/suse suse-13.2-non-oss
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-monitoring \
         --no-gpgcheck http://download.opensuse.org/repositories/server:/monitoring/openSUSE_13.2 suse-13.2-monitoring
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-seife \
         --no-gpgcheck http://download.opensuse.org/repositories/home:/seife:/testing/openSUSE_13.2 suse-13.2-seife
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-python \
         --no-gpgcheck http://download.opensuse.org/repositories/devel:/languages:/python/openSUSE_13.2 suse-13.2-python
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-network \
         --no-gpgcheck http://download.opensuse.org/repositories/network:/utilities/openSUSE_13.2 suse-13.2-network
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-building \
         --no-gpgcheck http://download.opensuse.org/repositories/devel:/tools:/building/openSUSE_13.2 suse-13.2-building
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-appliances \
         --no-gpgcheck http://download.opensuse.org/repositories/Virtualization:/Appliances/openSUSE_13.2 suse-13.2-appliances
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-containers \
         --no-gpgcheck http://download.opensuse.org/repositories/Virtualization:/containers/openSUSE_13.2 suse-13.2-containers
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-filesystems-ceph \
         --no-gpgcheck http://download.opensuse.org/repositories/filesystems:/ceph:/Unstable/openSUSE_13.2 suse-13.2-filesystems-ceph
  zypper --non-interactive --no-gpg-checks addrepo --no-check --name suse-13.2-electronics \
         --no-gpgcheck http://download.opensuse.org/repositories/electronics/openSUSE_13.2 suse-13.2-electronics

  zypper --non-interactive --no-gpg-checks modifyrepo --priority  3 suse-13.2-oss
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  3 suse-13.2-oss-update
  zypper --non-interactive --no-gpg-checks modifyrepo --priority 99 suse-13.2-non-oss
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  1 suse-13.2-monitoring
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  1 suse-13.2-seife
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  4 suse-13.2-python
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  4 suse-13.2-network
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  5 suse-13.2-building
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  1 suse-13.2-appliances
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  1 suse-13.2-containers
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  1 suse-13.2-filesystems-ceph
  zypper --non-interactive --no-gpg-checks modifyrepo --priority  1 suse-13.2-electronics

  return 0
}

function installPackages
{
  # distribution updates and security fixes
  mkdir -p /tmp/coprhd.d
  cp -f /etc/zypp/repos.d/*.repo /tmp/coprhd.d/

  zypper --reposd-dir=/tmp/coprhd.d --non-interactive --no-gpg-checks refresh
  # package updates from the repo above (suse-13.2-oss-update)
  zypper --reposd-dir=/tmp/coprhd.d --non-interactive --non-interactive-include-reboot-patches --no-gpg-checks patch -g security --no-recommends
  rm -fr /tmp/coprhd.d

  zypper --non-interactive clean
}

function installJava
{
  java=$2
  [ ! -z "${java}" ] || java=8

  update-alternatives --set java /usr/lib64/jvm/jre-1.${java}.0-openjdk/bin/java
  update-alternatives --set javac /usr/lib64/jvm/java-1.${java}.0-openjdk/bin/javac
}

function installNginx
{
  if [ -d /nginx-1.6.2 -a -d /nginx_upstream_check_module-0.3.0 -a -d /headers-more-nginx-module-0.25 ]; then
    mkdir -p /tmp/nginx
    mv /nginx-1.6.2 /tmp/nginx/
    mv /nginx_upstream_check_module-0.3.0 /tmp/nginx/
    mv /headers-more-nginx-module-0.25 /tmp/nginx/
    patch --directory=/tmp/nginx/nginx-1.6.2 -p1 < /tmp/nginx/nginx_upstream_check_module-0.3.0/check_1.5.12+.patch
    bash -c "cd /tmp/nginx/nginx-1.6.2; ./configure --add-module=/tmp/nginx/nginx_upstream_check_module-0.3.0 --add-module=/tmp/nginx/headers-more-nginx-module-0.25 --with-http_ssl_module --prefix=/usr --conf-path=/etc/nginx/nginx.conf"
    make --directory=/tmp/nginx/nginx-1.6.2
    make --directory=/tmp/nginx/nginx-1.6.2 install
    rm -fr /tmp/nginx
  fi
}

function installStorageOS
{
  getent group storageos || groupadd -g 444 storageos
  getent passwd storageos || useradd -r -d /opt/storageos -c "StorageOS" -g 444 -u 444 -s /bin/bash storageos
  [ ! -d /opt/storageos ] || chown -R storageos:storageos /opt/storageos
  [ ! -d /data ] || chown -R storageos:storageos /data
}

function enableStorageOS
{
  systemctl enable keepalived
  systemctl enable boot-ovfenv
  systemctl enable nginx
  systemctl enable storageos-installer
  /etc/storageos/storageos enable
  systemctl stop SuSEfirewall2_init
  systemctl stop SuSEfirewall2
  /etc/storageos/boot-ovfenv start
  systemctl start keepalived
  systemctl start nginx 
  /etc/storageos/storageos start
}

function disableStorageOS
{
  if [ -f /etc/storageos/storageos ]; then
    /etc/storageos/storageos stop
    /etc/storageos/storageos disable
  fi
  systemctl stop boot-ovfenv
  systemctl disable boot-ovfenv
  systemctl stop nginx
  systemctl disable nginx
  systemctl stop syncntp
  systemctl disable syncntp
  systemctl stop keepalived
  systemctl disable keepalived
  systemctl stop SuSEfirewall2
  systemctl stop SuSEfirewall2_init
}

function waitStorageOS
{
  source /etc/ovfenv.properties
  while [ ! -f /opt/storageos/logs/coordinatorsvc.log ]; do
    echo "Warning: coordinatorsvc unavailable. Waiting..."
    sleep 1
  done
  while [ ! -f /opt/storageos/logs/apisvc.log ]; do
    echo "Warning: apisvc unavailable. Waiting..."
    sleep 35
  done
  until $(curl --silent --insecure https://${network_1_ipaddr}:4443/formlogin | grep --quiet "Authorized Users Only" &>/dev/null); do
    echo "Warning: service unavailable. Waiting..."
    echo network_1_ipaddr=${network_1_ipaddr}
    sleep 25
  done
  echo "UI ready on: https://${network_1_ipaddr}"
}

function installDockerEnv
{
  workspace=$2
  node_count=$3
  [ ! -z "${workspace}" ] || workspace="${PWD}"
  [ ! -z "${node_count}" ] || node_count=1

  cat > ${workspace}/docker-env.service <<EOF
[Unit]
Description=StorageOS docker-env service
Wants=network.service ipchecktool.service ipsec.service
After=network.service ipchecktool.service sshd.service ntpd.service ipsec.service

[Service]
Type=simple
WorkingDirectory=/
ExecStart=-/bin/bash -c "/opt/ADG/conf/configure.sh enableStorageOS"

[Install]
WantedBy=multi-user.target
EOF

  for i in $(seq 1 ${node_count}); do
    mkdir -p ${workspace}/data.$i
    chmod 777 ${workspace}/data.$i
  done

  network_vip=(172.17.0.100)
  network_vip6=(2001:0db8:0001:0000:0000:0242:ac11:0064)
  vip=${network_vip[0]}
  vip6=${network_vip6[0]}
  echo 1
  for i in $(seq 1 ${node_count}); do
    echo "Starting vipr$i..."
    docker stop vipr$i &> /dev/null
    echo 2
    docker rm vipr$i &> /dev/null
    docker run --privileged -d -e "HOSTNAME=vipr$i" -v ${workspace}/data.$i:/data -v ${workspace}/docker-env.service:/etc/systemd/system/multi-user.target.wants/docker-env.service --name=vipr$i coprhd /sbin/init
    echo 3
    #NAME=$(docker exec vipr$i rpm -qa | grep storageos)
    #docker exec vipr$i rpm -e $NAME
    #docker exec vipr$i rpm -Uvh /tmp/*.rpm
    echo 4
    docker exec vipr$i /bin/bash -c "sed /$(docker inspect -f {{.Config.Hostname}} vipr$i)/d /etc/hosts > /etc/hosts.new"
    docker exec vipr$i /bin/bash -c "cat /etc/hosts.new > /etc/hosts"
    docker exec vipr$i /bin/bash -c "rm /etc/hosts.new"
    docker exec vipr$i /bin/bash -c "echo \"vipr$i\" > /etc/HOSTNAME"
    docker exec vipr$i /bin/bash -c "echo \"${network_vip[0]}	coordinator\" >> /etc/hosts"
    docker exec vipr$i /bin/bash -c "echo \"${network_vip[0]}	coordinator.bridge\" >> /etc/hosts"
    docker exec vipr$i hostname vipr$i
    echo 5
    network_vip+=($(docker inspect -f {{.NetworkSettings.IPAddress}} vipr$i))
    network_vip6+=($(docker inspect -f {{.NetworkSettings.GlobalIPv6Address}} vipr$i))
  done
  echo 6
  for i in $(seq 1 ${node_count}); do
    echo "#!/bin/bash" > ${workspace}/data.$i/dockerenv.sh
    echo "network_prefix_length=$(docker inspect -f {{.NetworkSettings.IPPrefixLen}} vipr$i)" >> ${workspace}/data.$i/dockerenv.sh
    echo "network_prefix_length6=$(docker inspect -f {{.NetworkSettings.GlobalIPv6PrefixLen}} vipr$i)" >> ${workspace}/data.$i/dockerenv.sh
    for j in $(seq 1 ${node_count}); do
      echo "network_${j}_ipaddr=${network_vip[$j]}" >> ${workspace}/data.$i/dockerenv.sh
      echo "network_${j}_ipaddr6=${network_vip6[$j]}" >> ${workspace}/data.$i/dockerenv.sh
    done

    echo 7   

    echo "network_gateway=$(docker inspect -f {{.NetworkSettings.Gateway}} vipr$i)" >> ${workspace}/data.$i/dockerenv.sh
    echo "network_gateway6=$(docker inspect -f {{.NetworkSettings.IPv6Gateway}} vipr$i)" >> ${workspace}/data.$i/dockerenv.sh
    echo "sed -i s/network_netmask=.*/network_netmask=255.255.0.0/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    echo "sed -i s/node_count=.*/node_count=$node_count/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    echo "sed -i s/node_id=.*/node_id=vipr$i/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    echo "sed -i s/network_1_ipaddr=.*/network_1_ipaddr=\${network_1_ipaddr}/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    echo "sed -i s/network_gateway=.*/network_gateway=\${network_gateway}/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    # echo "sed -i s/network_1_ipaddr6=.*/network_1_ipaddr6=\${network_1_ipaddr6}/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    # echo "sed -i s/network_gateway6=.*/network_gateway6=\${network_gateway6}/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh

    echo 8

    echo "sed -i s/network_prefix_length=.*/network_prefix_length=\${network_prefix_length}/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    echo "sed -i s/network_vip=.*/network_vip=${vip}/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    # echo "sed -i s/network_vip6=.*/network_vip6=${vip6}/g /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    for j in $(seq 2 ${node_count}); do
      echo "echo \"network_${j}_ipaddr=\${network_${j}_ipaddr}\" >> /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
      # echo "echo \"network_${j}_ipaddr6=\${network_${j}_ipaddr6}\" >> /etc/ovfenv.properties" >> ${workspace}/data.$i/dockerenv.sh
    done
    echo "exit 0" >> ${workspace}/data.$i/dockerenv.sh
    chmod a+x ${workspace}/data.$i/dockerenv.sh
    echo 9
    docker exec vipr$i chown -R storageos:storageos /data
    docker exec vipr$i /opt/ADG/conf/configure.sh installNetworkConfigurationFile
    docker exec vipr$i /data/dockerenv.sh
  done
  echo 10
  iptables -t nat -A DOCKER -p tcp --dport 443 -j DNAT --to-destination ${vip}:443
  iptables -t nat -A DOCKER -p tcp --dport 4443 -j DNAT --to-destination ${vip}:4443
  iptables -t nat -A DOCKER -p tcp --dport 8080 -j DNAT --to-destination ${vip}:8080
  iptables -t nat -A DOCKER -p tcp --dport 8443 -j DNAT --to-destination ${vip}:8443
  echo 11
  addCustomCoprHD

}

function addCustomCoprHD
{

    docker cp /home/liamjackson/DockerHD/files/RPMS/liam-storageos-3.5.0.0.6366ca0-1.x86_64.rpm vipr1:/tmp
    NAME=$(docker exec vipr$i rpm -qa | grep storageos)
    docker exec vipr1 rpm -e $NAME
    docker exec vipr1 rpm -Uvh /tmp/liam-storageos-3.5.0.0.6366ca0-1.x86_64.rpm
    docker exec -it vipr1 /opt/ADG/conf/configure.sh waitStorageOS
}
function uninstallDockerEnv
{
  workspace=$2
  node_count=$3
  [ ! -z "${workspace}" ] || workspace="${PWD}"
  [ ! -z "${node_count}" ] || node_count=1
  for i in $(seq 1 ${node_count}); do
    echo "Stopping vipr$i..."
    docker stop vipr$i &> /dev/null
    docker rm vipr$i &> /dev/null
    rm -fr ${workspace}/data.$i
  done
  rm -fr ${workspace}/docker-env.service
  iptables -F DOCKER -t nat
}


function installNetwork
{
  echo "BOOTPROTO='dhcp'"  > /etc/sysconfig/network/ifcfg-eth0
  echo "STARTMODE='auto'" >> /etc/sysconfig/network/ifcfg-eth0
  echo "USERCONTROL='no'" >> /etc/sysconfig/network/ifcfg-eth0
  ln -fs /dev/null /etc/udev/rules.d/80-net-name-slot.rules
  ln -fs /dev/null /etc/udev/rules.d/80-net-setup-link.rules
}

function installNetworkConfigurationFile
{
  eth=$2
  gateway=$3
  netmask=$4
  [ ! -z "${eth}" ] || eth=1
  [ ! -z "${gateway}" ] || gateway=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
  [ ! -z "${netmask}" ] || netmask='255.255.255.0'
  ipaddr=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | head -n ${eth} | tail -n 1)
  cat > /etc/ovfenv.properties <<EOF
network_1_ipaddr6=::0
network_1_ipaddr=${ipaddr}
network_gateway6=::0
network_gateway=${gateway}
network_netmask=${netmask}
network_prefix_length=64
network_vip6=::0
network_vip=${ipaddr}
node_count=1
node_id=vipr1
EOF
}

function installXorg
{
  cat > /etc/X11/xorg.conf <<EOF
Section "ServerLayout"
        Identifier     "X.org Configured"
        Screen      0  "Screen0" 0 0
        InputDevice    "Mouse0" "CorePointer"
        InputDevice    "Keyboard0" "CoreKeyboard"
EndSection

Section "Files"
        ModulePath   "/usr/lib64/xorg/modules"
        FontPath     "/usr/share/fonts/misc:unscaled"
        FontPath     "/usr/share/fonts/Type1/"
        FontPath     "/usr/share/fonts/100dpi:unscaled"
        FontPath     "/usr/share/fonts/75dpi:unscaled"
        FontPath     "/usr/share/fonts/ghostscript/"
        FontPath     "/usr/share/fonts/cyrillic:unscaled"
        FontPath     "/usr/share/fonts/misc/sgi:unscaled"
        FontPath     "/usr/share/fonts/truetype/"
        FontPath     "built-ins"
EndSection

Section "Module"
        Load  "glx"
EndSection

Section "InputDevice"
        Identifier  "Keyboard0"
        Driver      "kbd"
EndSection

Section "InputDevice"
        Identifier  "Mouse0"
        Driver      "mouse"
        Option      "Protocol" "auto"
        Option      "Device" "/dev/input/mice"
        Option      "ZAxisMapping" "4 5 6 7"
EndSection

Section "Monitor"
        Identifier   "Monitor0"
        VendorName   "Monitor Vendor"
        ModelName    "Monitor Model"
EndSection

Section "Device"
        Identifier  "Card0"
        Driver      "vmware"
        BusID       "PCI:0:15:0"
EndSection

Section "Screen"
        Identifier "Screen0"
        Device     "Card0"
        Monitor    "Monitor0"
        SubSection "Display"
                Viewport   0 0
                Depth     1
        EndSubSection
        SubSection "Display"
                Viewport   0 0
                Depth     4
        EndSubSection
        SubSection "Display"
                Viewport   0 0
                Depth     8
        EndSubSection
        SubSection "Display"
                Viewport   0 0
                Depth     15
        EndSubSection
        SubSection "Display"
                Viewport   0 0
                Depth     16
        EndSubSection
        SubSection "Display"
                Viewport   0 0
                Depth     24
        EndSubSection
EndSection
EOF
}



$1 "$@"

