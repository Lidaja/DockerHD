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
##COPY files/jre-8u91-linux-x64.rpm /coprhd
COPY files/ifconfig /bin
COPY files/route /sbin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
##COPY files/javac /usr/lib64/jvm/java-1.8.0-openjdk/bin/javac
RUN /coprhd/configure.sh installJava
RUN /coprhd/configure.sh installNginx
RUN /coprhd/configure.sh installStorageOS
#RUN /coprhd/configure.sh installNetwork
RUN /coprhd/configure.sh installXorg
##RUN /coprhd/configure.sh disableStorageOS
RUN zypper --non-interactive install hostname iproute2 vim
COPY files/storageos-3.5.0.0.7e73abc-1.x86_64.rpm /coprhd
#RUN DO_NOT_START="yes" rpm -iv coprhd/storageos-*.x86_64.rpm && \
#    rm -f /coprhd/storageos-*.x86_64.rpm
CMD ["/sbin/init"]
