#Bash script to backup linuxjobber media file

for file in /linuxjobber/www/Django/Linuxjobber; do
   cp -r /linuxjobber/www/Django/Linuxjobber/media /web/
done

