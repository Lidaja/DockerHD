FROM opensuse:13.2
RUN mkdir /coprhd
COPY files/rc.status /etc
COPY scripts/configure.sh /coprhd 
RUN /coprhd/configure.sh installRepositories
RUN /coprhd/configure.sh installPackages
RUN zypper install -y man
RUN zypper --non-interactive install telnet openssh java-1_8_0-openjdk java-1_8_0-openjdk-devel curl
ADD http://download.opensuse.org/repositories/home:/seife:/testing/openSUSE_13.2/x86_64/sipcalc-1.1.6-5.1.x86_64.rpm /
RUN rpm -Uvh --nodeps sipcalc-1.1.6-5.1.x86_64.rpm && \
    rm -f sipcalc-1.1.6-5.1.x86_64.rpm
RUN groupadd storageos && useradd -d /opt/storageos -g storageos storageos
COPY files/ifconfig /bin
COPY files/route /sbin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /coprhd/configure.sh installJava
RUN /coprhd/configure.sh installNginx
RUN /coprhd/configure.sh installStorageOS
##RUN /coprhd/configure.sh installNetwork
RUN /coprhd/configure.sh installXorg
#RUN /coprhd/configure.sh disableStorageOS
RUN zypper --non-interactive install hostname iproute2 vim wget tar libopenssl-devel gcc ndisc6
RUN cd ~ && wget http://www.keepalived.org/software/keepalived-1.2.19.tar.gz && tar xzvf keepalived* && cd keepalived* && ./configure
COPY files/RPMS/clean-storageos-3.5.0.0.6366ca0-1.x86_64.rpm /coprhd
CMD ["/sbin/init"]
