FROM coprhd

MAINTAINER Liam Jackson Lijax@hotmail.com
RUN mkdir coprhd
ADD files/RPMS/liam-storageos-3.5.0.0.6366ca0-1.x86_64.rpm /coprhd

CMD ["/sbin/init"]
