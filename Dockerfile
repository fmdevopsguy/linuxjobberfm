
FROM centos:7

MAINTAINER The CentOS Project <cloud-ops@centos.org>

LABEL Vendor="CentOS" \
      License=GPLv2 \
      Version=2.4.6-40

RUN yum -y install wget git httpd https://repo.ius.io/ius-release-el$(rpm -E '%{rhel}').rpm


RUN yum --skip-broken -y install httpd-devel \
                   zlib-devel \
                   bzip2-devel \
                   openssl-devel \
                   ncurses-devel \
                   sqlite-devel \
                   readline \
                   python36u \
                   python36u-pip \
                   python36u-devel \
                   uwsgi \
                   uwsgi-plugin-python36 \
                   nginx \
                   python-pip \
                   mysql-devel \
                   redhat-rpm-config \
                   python-devel python-pip \
                   python-setuptools \
                   python-wheel \
                   python-cffi \
                   libffi-devel \
                   cairo \
                   pango \
                   gdk-pixbuf2 \
                   gcc \
                   which \
                   gcc-c++

RUN mkdir -p /linuxjobber/
#RUN mkdir -p /usr/share/nginx/web/classroom
#RUN mkdir -p /usr/share/nginx/web/workntutor
RUN mkdir -p /linuxjobber/www/certificates/
RUN mkdir -p /linuxjobber/www/Django/
RUN mkdir -p /linuxjobber/www/testscripts/
COPY www/certificates /linuxjobber/www/certificates/
COPY www/Django /linuxjobber/www/Django/
COPY www/git /linuxjobber/www/git
#COPY www/testscripts /linuxjobber/www/testscripts/
COPY www/tracker.yml /linuxjobber/www/tracker.yml
COPY www/README.md /linuxjobber/www/README.md
#COPY container.nginx.conf /etc/nginx/nginx.conf
#COPY package.json /linuxjobber
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Angular Implentation
#RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
RUN yum install -y nodejs && yum install -y gcc-c++ make sshpass
#COPY environment.prod.ts /linuxjobber/www/Angular/src/environments/
COPY requirement.txt /linuxjobber/www/Django/Linuxjobber/requirement.txt


#RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
#ENV NVM_DIR=/root/.nvm

#WORKDIR /linuxjobber/www/Angular
#
#RUN . $HOME/.nvm/nvm.sh && nvm install stable && npm install && npm run-script build
#

RUN git config --global user.email "joseph.showunmi@linuxjobber.com" && git config --global user.name "joseph.showunmi"
#COPY www/Angular/dist/groupclass/* /usr/share/nginx/web/classroom/
#COPY www/Workntutor/dist/fuse/* /usr/share/nginx/web/workntutor/
#
#RUN yes | cp -r /linuxjobber/www/Angular/dist/groupclass/* /usr/share/nginx/web/classroom
#

# Python Implementation

WORKDIR /linuxjobber/www/Django/Linuxjobber/
RUN /bin/python3.6 -m pip install  -r requirement.txt
RUN pip3 install mysql-connector-python
COPY settings.ini /linuxjobber/www/Django/Linuxjobber/
COPY settings.py /linuxjobber/www/Django/Linuxjobber/Linuxjobber/settings.py

ADD linuxjobber.ini /etc/uwsgi.d/linuxjobber.ini

RUN mkdir -p /run/linuxjobberuwsgi/ && chgrp nginx /run/linuxjobberuwsgi && chmod 2775 /run/linuxjobberuwsgi && touch /run/linuxjobberuwsgi/uwsgi.sock

COPY backup.sh /web/
RUN chmod -R 777 /linuxjobber/www/Django/Linuxjobber/media
RUN touch /linuxjobber/www/Django/Linuxjobber/django_dev.log
RUN touch /linuxjobber/www/Django/Linuxjobber/django_dba.log
RUN touch /linuxjobber/www/Django/Linuxjobber/django_production.log
RUN cd /linuxjobber/www/Django/Linuxjobber/ && chmod -R 777 django_dba.log django_dev.log django_production.log
RUN chmod -R 777 /linuxjobber/www/Django/Linuxjobber/django_dba.log /linuxjobber/www/Django/Linuxjobber/django_dev.log /linuxjobber/www/Django/Linuxjobber/django_production.log

RUN chgrp -R 0 /linuxjobber/www/Django/* /start.sh /run /run/* /run/linuxjobberuwsgi/* /etc /usr/share/nginx /var/lib /var/log /usr/sbin/uwsgi
RUN chmod -R g=u /linuxjobber/www/Django/* /start.sh /run /run/* /run/linuxjobberuwsgi/* /etc /usr/share/nginx /usr/sbin/uwsgi  /var/lib /var/log

RUN yum -y install sudo
RUN groupadd -g 1001 linuxjobber && useradd -u 1001 linuxjobber -g linuxjobber
RUN echo 'linuxjobber  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers;
RUN chown -R linuxjobber:linuxjobber /linuxjobber
RUN mkdir -p /mnt
RUN chown -R linuxjobber:linuxjobber /mnt /var/log /var/lib /var/log/nginx
RUN touch /var/run/nginx.pid && chown -R linuxjobber:linuxjobber /var/run/nginx.pid

#workntutor
#RUN mkdir -p /usr/share/nginx/web/workntutor
#COPY workntutor.ts /linuxjobber/www/Workntutor/src/environments/environment.prod.ts
#WORKDIR /linuxjobber/www/Workntutor
#RUN npm install --silent && ng build --prod
#RUN npm install --silent
#RUN npm run-script build
#RUN . $HOME/.nvm/nvm.sh && nvm install stable && npm install && npm run-script build



USER linuxjobber
#CMD ["/start.sh"]
ENTRYPOINT ["/start.sh"]
EXPOSE 4000 7000

