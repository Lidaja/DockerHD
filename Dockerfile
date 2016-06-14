FROM coprhd
MAINTAINER Liam Jackson Lijax@hotmail.com
RUN mkdir files
RUN zypper --non-interactive install git vim
ADD files/RPMS/liam-storageos-3.5.0.0.6366ca0-1.x86_64.rpm /files
ADD files/execTest.java /files
ADD files/generateData.py /files
ADD files/dataGetter.java /files
ADD files/runData.java /files
CMD ["/sbin/init"]
