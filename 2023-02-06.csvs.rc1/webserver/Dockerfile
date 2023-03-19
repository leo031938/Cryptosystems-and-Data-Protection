# Webserver Dockerfile

FROM centos:7
FROM php:7.4-fpm

# php-fpm
RUN sed -i 's/user = www-data/user = root/g' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/group = www-data/group = root/g' /usr/local/etc/php-fpm.d/www.conf

# nginx
RUN sed -i 's/user nginx;/user root;/g' /etc/nginx/nginx.conf

RUN 	yum install epel-release -y && \
	yum update -y && \
	yum install -y \
	nginx \
	php \
	php-mysqlnd \
	php-fpm 
	

COPY webfiles/ /usr/share/nginx/html

COPY configfiles/nginx.conf     /etc/nginx/nginx.conf
COPY configfiles/php.ini        /etc/php.ini
COPY configfiles/www.conf       /etc/php-fpm.d/www.conf
COPY configfiles/php-fpm.conf   /etc/nginx/conf.d/php-fpm.conf
COPY configfiles/docker-entrypoint.sh /

RUN rm -f /usr/share/nginx/html/index.html /usr/share/nginx/html/nginx-logo.png /usr/share/nginx/html/poweredby.png
RUN chmod +x /docker-entrypoint.sh && \
    chown apache:apache /usr/share/nginx/html/*.php

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
