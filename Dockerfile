FROM debian:jessie

RUN mkdir /docker-entrypoint-initdb.d

# FATAL ERROR: please install the following Perl modules before executing /usr/local/mysql/scripts/mysql_install_db:
# File::Basename
# File::Copy
# Sys::Hostname
# Data::Dumper
RUN apt-get update && apt-get install -y perl --no-install-recommends && rm -rf /var/lib/apt/lists/*

# mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file: No such file or directory
RUN apt-get update && apt-get install -y libaio1 && rm -rf /var/lib/apt/lists/*

# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5

ENV MYSQL_MAJOR 5.5
ENV MYSQL_VERSION 5.5.45
ENV WORKDIR /workdir

RUN mkdir /workdir && chmod -R 777 /workdir

# note: we're pulling the *.asc file from mysql.he.net instead of dev.mysql.com because the official mirror 404s that file for whatever reason - maybe it's at a different path?
RUN apt-get update && apt-get install -y curl --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& curl -SL "http://dev.mysql.com/get/Downloads/MySQL-$MYSQL_MAJOR/mysql-$MYSQL_VERSION-linux2.6-x86_64.tar.gz" -o mysql.tar.gz \
	&& apt-get purge -y --auto-remove curl \
	&& mkdir /usr/local/mysql \
	&& tar -xzf mysql.tar.gz -C /usr/local/mysql --strip-components=1 \
	&& rm mysql.tar.gz* \
	&& rm -rf /usr/local/mysql/mysql-test /usr/local/mysql/sql-bench \
	&& rm -rf /usr/local/mysql/bin/*-debug /usr/local/mysql/bin/*_embedded \
	&& find /usr/local/mysql -type f -name "*.a" -delete \
	&& apt-get update && apt-get install -y binutils && rm -rf /var/lib/apt/lists/* \
	&& { find /usr/local/mysql -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& apt-get purge -y --auto-remove binutils
ENV PATH $PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts

# replicate some of the way the APT package configuration works
# this is only for 5.5 since it doesn't have an APT repo, and will go away when 5.5 does
RUN mkdir -p /etc/mysql/conf.d \
	&& { \
		echo '[mysqld]'; \
		echo 'skip-host-cache'; \
		echo 'skip-name-resolve'; \
		echo 'user = mysql'; \
		echo 'datadir = /var/lib/mysql'; \
		echo '!includedir /etc/mysql/conf.d/'; \
	} > /etc/mysql/my.cnf

# install supervisord
RUN apt-get update && apt-get install -y supervisor gettext

# install nss-wrapper from unstable
ADD ./apt/unstable.pref /etc/apt/preferences.d/unstable.pref
ADD ./apt/unstable.list /etc/apt/sources.list.d/unstable.list
RUN apt-get update && apt-get install -y -t unstable libnss-wrapper

# change the data directory
RUN sed -i '/^datadir*/ s|/var/lib/mysql|/volume/mysql_data|' /etc/mysql/my.cnf

# add backups
COPY backup.sh ${WORKDIR}/backup.sh

# copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor

VOLUME /var/lib/mysql
WORKDIR /workdir

ADD passwd.template ${WORKDIR}/passwd.template
ADD docker-entrypoint.sh /entrypoint.sh

RUN mkdir -p /volume && chmod -R 777 /volume
RUN mkdir ${WORKDIR}/sv-child-logs/ && chmod -R 777 ${WORKDIR}

USER 27

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
