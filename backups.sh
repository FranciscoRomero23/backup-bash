#!/bin/bash

diasemana=`date +%a`
fecha=`date +%d-%m-%y`

while IFS=: read -r hostname ip
do
	# Generamos el directorio donde se preparara la copia de seguridad
	ssh -i /root/.ssh/backup-key root@$ip mkdir /tmp/backup

	# Generamos un fichero con los paquetes del sistema
	if [ $hostname == "zapatero" ]
	then
		ssh -i /root/.ssh/backup-key root@$ip 'rpm -qa > /tmp/backup/paquetes'
	else
		ssh -i /root/.ssh/backup-key root@$ip 'dpkg -l | cut -d" " -f3 > /tmp/backup/paquetes'
	fi

	# Hacemos la copia de seguridad según el dia de la semana
	if [ $diasemana == "lun" ]
	then
		# Si el dia es domingo, la copia sera completa

		# Completa de los homes
		homes=`ssh -i /root/.ssh/backup-key root@$ip ls /home`
		for i in $homes
		do
			# Homes de los usuarios
			ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz /home/$i/*' 2> /dev/null
		done
			# Home del root
			ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz /root/*' 2> /dev/null
		# Completa del /etc
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/etc.tar.gz /etc/*' 2> /dev/null
		# Completa del /var/cache
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz /var/cache/*' 2> /dev/null
		# Completa del /var/lib
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz /var/lib/*' 2> /dev/null
		# Completa del /var/log
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz /var/log/*' 2> /dev/null
		# Completa del /var/www
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz /var/www/*' 2> /dev/null

		# Se comprime todo y se manda al servidor de copias de seguridad
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/completa_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
		scp -i /root/.ssh/backup-key root@$ip:/tmp/backup/completa_$fecha.tar.gz /copias/$hostname/completas 1> /dev/null
		# Borramos el directorio /tmp/backup
		ssh -i /root/.ssh/backup-key root@$ip rm -r /tmp/backup
	else
		# Si el dia no es domingo, la copia sera diferencial

		fechacompleta='14-dic-18'

                # Diferencial de los homes
                homes=`ssh -i /root/.ssh/backup-key root@$ip ls /home`
                for i in $homes
                do
                        # Homes de los usuarios
                        ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz /home/$i/* -N $fechacompleta' 2> /dev/null
                done
                        # Home del root
                        ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz /root/* -N $fechacompleta' 2> /dev/null
                # Diferencial del /etc
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/etc.tar.gz /etc/* -N $fechacompleta' 2> /dev/null
                # Diferencial del /var/cache
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz /var/cache/* -N $fechacompleta' 2> /dev/null
                # Diferencial del /var/lib
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz /var/lib/* -N $fechacompleta' 2> /dev/null
                # Diferencial del /var/log
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz /var/log/* -N $fechacompleta' 2> /dev/null
                # Diferencial del /var/www
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz /var/www/*  -N $fechacompleta' 2> /dev/null

                # Se comprime todo y se manda al servidor de copias de seguridad
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/diferencial_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
                scp -i /root/.ssh/backup-key root@$ip:/tmp/backup/diferencial_$fecha.tar.gz /copias/$hostname/diferenciales 1> /dev/null
                # Borramos el directorio /tmp/backup
                ssh -i /root/.ssh/backup-key root@$ip rm -r /tmp/backup

	fi
done < equipos.csv
