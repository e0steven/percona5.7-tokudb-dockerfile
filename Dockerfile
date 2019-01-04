FROM centos:6.8
MAINTAINER Eric Stevens <e0steven@gmail.com>

RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
RUN yum -y install Percona-Server-server-57 Percona-Server-tokudb-57

RUN yum clean all
RUN rm -rf /var/cache/yum /var/lib/mysql

RUN printf '[mysqld]\nskip-host-cache\nskip-name-resolve\n' > /etc/my.cnf.d/docker.cnf
RUN /usr/bin/install -m 0664 -o mysql -g root /dev/null /etc/sysconfig/mysql \
	&& echo "LD_PRELOAD=/usr/lib64/libjemalloc.so.1" >> /etc/sysconfig/mysql \
	&& echo "THP_SETTING=never" >> /etc/sysconfig/mysql 

VOLUME ["/var/lib/mysql", "/var/log/mysql"]

COPY ps-entry.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD [""]
