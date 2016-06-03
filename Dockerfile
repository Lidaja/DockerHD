FROM opensuse:13.2
RUN mkdir /coprhd
RUN zypper --non-interactive install java-1_8_0-openjdk telnet openssh
RUN groupadd storageos && useradd -d /opt/storageos -g storageos storageos
COPY scripts/configure.sh /coprhd 
RUN /coprhd/configure.sh installRepositories
RUN /coprhd/configure.sh installPackages
RUN /coprhd/configure.sh installNginx
RUN /coprhd/configure.sh installStorageOS
RUN zypper --non-interactive install hostname
COPY files/storageos-3.5.0.0.83e3acf-1.x86_64.rpm /coprhd
RUN DO_NOT_START="yes" rpm -iv coprhd/storageos-*.x86_64.rpm && \
    rm -f /coprhd/storageos-*.x86_64.rpm
CMD ["/sbin/init"]
