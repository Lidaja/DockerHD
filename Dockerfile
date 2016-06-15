FROM coprhd
MAINTAINER Liam Jackson Lijax@hotmail.com
RUN mkdir files
RUN zypper --non-interactive install git vim
ADD files/RPMS/liam-storageos-3.5.0.0.6366ca0-1.x86_64.rpm /files
CMD ["/sbin/init"]
