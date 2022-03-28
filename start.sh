#!/bin/bash
/bin/chmod -R 777 /run/linuxjobberuwsgi/
cd /linuxjobber/www/Django/Linuxjobber/ && python3.6 manage.py collectstatic --noinput
cd /linuxjobber/www/Django/Linuxjobber/ && python3.6 manage.py migrate
cd /linuxjobber/www/Django/Linuxjobber && nohup python3.6 manage.py runserver 0.0.0.0:4000  &
cd /linuxjobber/www/Django/Linuxjobber && nohup python3.6 manage.py process_tasks &
/usr/sbin/nginx
/usr/sbin/uwsgi --ini /etc/uwsgi.d/linuxjobber.ini
/bin/chmod -R 777 /run/linuxjobberuwsgi/
