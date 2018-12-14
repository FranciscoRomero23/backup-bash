#!/bin/bash

diasemana=`date +%a`

while IFS=: read -r hostname ip
do
	# Creamos el directorio donde se preparara la copia de seguridad
	ssh -i /root/.ssh/backup-key root@$ip mkdir /tmp/backup

	# Generamos un fichero con los paquetes del sistema
	if [ $hostname == "zapatero" ]
	then
		ssh -i /root/.ssh/backup-key root@$ip 'rpm -qa > /tmp/backup/paquetes'
	else
		ssh -i /root/.ssh/backup-key root@$ip 'dpkg -l | cut -d" " -f3 > /tmp/backup/paquetes'
	fi
	# Hacemos la copia de seguridad según el dia de la semana
	if [ $diasemana == "dom" ]
	then
		# Si el dia es domingo, la copia sera completa
		# Completa de los homes
		homes=`ssh -i /root/.ssh/backup-key root@$ip ls /home`
		for i in $homes
		do
			ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_'$i'_completa.tar.gz /home/$i'
		done
		# Completa del etc
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/etc_completa.tar.gz /etc/*'
	else
		# Si el dia no es domingo, la copia sera diferencial
		echo "Diferencial"
	fi
done < equipos.csv
