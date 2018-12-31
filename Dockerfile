FROM centos:6.8
MAINTAINER Eric Stevens <e0steven@gmail.com>

RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
RUN yum -y install Percona-Server-server-57 Percona-Server-tokudb-57

VOLUME ["/var/lib/mysql", "/var/log/mysql"]

COPY ps-entry.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD [""]
