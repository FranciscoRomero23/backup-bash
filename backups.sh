#!/bin/bash

# Script que realiza copias de seguridad en los clientes disponibles.
# Los lunes hace una copia completa y el resto de dias hace una copia diferencial.
# Script creado por Francisco José Romero Morillo.

diasemana=`date +%u`
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
	if [ $diasemana = 1 ]
	then
		# Si el dia es domingo, la copia sera completa

		# Completa de los homes
		homes=`ssh -i /root/.ssh/backup-key root@$ip ls /home`
		for i in $homes
		do
			# Homes de los usuarios
			ssh -i /root/.ssh/backup-key root@$ip rm /home/$i/completa.snap
			ssh -i /root/.ssh/backup-key root@$ip rm /home/$i/diferencial.snap
			ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz -g /home/'$i'/completa.snap /home/'$i'/*' 2> /dev/null
			ssh -i /root/.ssh/backup-key root@$ip cp /home/$i/completa.snap /home/$i/diferencial.snap 2> /dev/null
		done
			# Home del root
			ssh -i /root/.ssh/backup-key root@$ip rm /root/completa.snap
			ssh -i /root/.ssh/backup-key root@$ip rm /root/diferencial.snap
			ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz -g /root/completa.snap /root/*' 2> /dev/null
			ssh -i /root/.ssh/backup-key root@$ip 'cp /root/completa.snap /root/diferencial.snap' 2> /dev/null
		# Completa del /etc
		ssh -i /root/.ssh/backup-key root@$ip rm /etc/completa.snap
		ssh -i /root/.ssh/backup-key root@$ip rm /etc/diferencial.snap
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/etc.tar.gz -g /etc/completa.snap /etc/*' 2> /dev/null
		ssh -i /root/.ssh/backup-key root@$ip 'cp /etc/completa.snap /etc/diferencial.snap' 2> /dev/null
		# Completa del /var/cache
		ssh -i /root/.ssh/backup-key root@$ip rm /var/cache/completa.snap
		ssh -i /root/.ssh/backup-key root@$ip rm /var/cache/diferencial.snap
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz -g /var/cache/completa.snap /var/cache/*' 2> /dev/null
		ssh -i /root/.ssh/backup-key root@$ip 'cp /var/cache/completa.snap /var/cache/diferencial.snap' 2> /dev/null
		# Completa del /var/lib
                ssh -i /root/.ssh/backup-key root@$ip rm /var/lib/completa.snap
                ssh -i /root/.ssh/backup-key root@$ip rm /var/lib/diferencial.snap
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz -g /var/lib/completa.snap /var/lib/*' 2> /dev/null
		ssh -i /root/.ssh/backup-key root@$ip 'cp /var/lib/completa.snap /var/lib/diferencial.snap' 2> /dev/null
		# Completa del /var/log
                ssh -i /root/.ssh/backup-key root@$ip rm /var/log/completa.snap
                ssh -i /root/.ssh/backup-key root@$ip rm /var/log/diferencial.snap
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz -g /var/log/completa.snap /var/log/*' 2> /dev/null
		ssh -i /root/.ssh/backup-key root@$ip 'cp /var/log/completa.snap /var/log/diferencial.snap' 2> /dev/null
		# Completa del /var/www
                ssh -i /root/.ssh/backup-key root@$ip rm /var/www/completa.snap
                ssh -i /root/.ssh/backup-key root@$ip rm /var/www/diferencial.snap
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz -g /var/www/completa.snap /var/www/*' 2> /dev/null
		ssh -i /root/.ssh/backup-key root@$ip 'cp /var/www/completa.snap /var/www/diferencial.snap' 2> /dev/null

		# Se comprime todo y se manda al servidor de copias de seguridad
		ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/completa_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
		scp -i /root/.ssh/backup-key root@$ip:/tmp/backup/completa_$fecha.tar.gz /copias/$hostname/completas 1> /dev/null
		# Borramos el directorio /tmp/backup
		ssh -i /root/.ssh/backup-key root@$ip rm -r /tmp/backup

		#Insertamos un nuevo registro en el log
		fechahora=`date +%b' '%d' '%H':'%M':'%S`
		estado=`ls /copias/$hostname/completas/completa_$fecha.tar.gz | wc -l`
		if [ $estado = 1 ]
		then
			echo "$fechahora $hostname completa: copia realizada" >> /home/francisco/backup-bash/backup_log
		else
			echo "$fechahora $hostname completa: copia fallida" >> /home/francisco/backup-bash/backup_log
		fi
	else
		# Si el dia no es domingo, la copia sera diferencial

                # Diferencial de los homes
                homes=`ssh -i /root/.ssh/backup-key root@$ip ls /home`
                for i in $homes
                do
                        # Homes de los usuarios
                        ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz -g /home/'$i'/diferencial.snap /home/'$i'/*' 2> /dev/null
                done
                        # Home del root
                        ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz -g /root/diferencial.snap /root/*' 2> /dev/null
                # Diferencial del /etc
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/etc.tar.gz -g /etc/diferencial.snap /etc/*' 2> /dev/null
                # Diferencial del /var/cache
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz -g /var/cache/diferencial.snap /var/cache/*' 2> /dev/null
                # Diferencial del /var/lib
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz -g /var/lib/diferencial.snap /var/lib/*' 2> /dev/null
                # Diferencial del /var/log
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz -g /var/log/diferencial.snap /var/log/*' 2> /dev/null
                # Diferencial del /var/www
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz -g /var/www/diferencial.snap /var/www/*' 2> /dev/null

                # Se comprime todo y se manda al servidor de copias de seguridad
                ssh -i /root/.ssh/backup-key root@$ip 'tar -czpf /tmp/backup/diferencial_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
                scp -i /root/.ssh/backup-key root@$ip:/tmp/backup/diferencial_$fecha.tar.gz /copias/$hostname/diferenciales 1> /dev/null
                # Borramos el directorio /tmp/backup
                ssh -i /root/.ssh/backup-key root@$ip rm -r /tmp/backup

                #Insertamos un nuevo registro en el log
                fechahora=`date +%b' '%d' '%H':'%M':'%S`
                estado=`ls /copias/$hostname/diferenciales/diferencial_$fecha.tar.gz | wc -l`
                if [ $estado = 1 ]
                then
                        echo "$fechahora $hostname diferencial: copia realizada" >> /home/francisco/backup-bash/backup_log
                else
                        echo "$fechahora $hostname diferencial: copia fallida" >> /home/francisco/backup-bash/backup_log
                fi
	fi
done < equipos.csv
