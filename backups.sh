#!/bin/bash

# Script que realiza copias de seguridad en los clientes disponibles.
# Los lunes hace una copia completa y el resto de dias hace una copia diferencial.
# Script creado por Francisco José Romero Morillo.

# Este script utiliza tres parametros:
# Parametro 1: ruta clave privada ssh
# Parametro 2: ruta fichero clientes.csv
# Parametro 3: ruta directorio pricipal de copias

diasemana=`date +%u`
fecha=`date +%d-%m-%y`

clientes=`cat $2`
for ip in $clientes
do
	# Generamos el directorio donde se preparara la copia de seguridad
	ssh -i $1 root@$ip mkdir /tmp/backup

        # Obtenemos el hostname del cliente
        hostname=`ssh -i $1 root@$ip hostname -s`

	# Generamos un fichero con los paquetes del sistema
	if [ $hostname == "zapatero" ]
	then
		ssh -i $1 root@$ip 'rpm -qa > /tmp/backup/packages.txt'
	else
		ssh -i $1 root@$ip 'dpkg -l | grep ^i | cut -d" " -f3 > /tmp/backup/packages.txt'
	fi

	# Hacemos la copia de seguridad según el dia de la semana
	if [ $diasemana = 1 ]
	then
		# Si el dia es lunes, la copia sera completa

		# Completa de los homes
		homes=`ssh -i $1 root@$ip ls /home`
		for i in $homes
		do
			# Homes de los usuarios
			ssh -i $1 root@$ip rm /home/$i/completa.snap /home/$i/diferencial.snap 2> /dev/null
			ssh -i $1 root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz -g /home/'$i'/completa.snap /home/'$i'/*' 2> /dev/null
			ssh -i $1 root@$ip 'cp /home/'$i'/completa.snap /home/'$i'/diferencial.snap' 2> /dev/null
		done
			# Home del root
			ssh -i $1 root@$ip rm /root/completa.snap /root/diferencial.snap 2> /dev/null
			ssh -i $1 root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz -g /root/completa.snap /root/*' 2> /dev/null
			ssh -i $1 root@$ip 'cp /root/completa.snap /root/diferencial.snap' 2> /dev/null
		# Completa del /etc
		ssh -i $1 root@$ip rm /etc/completa.snap /etc/diferencial.snap 2> /dev/null
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/etc.tar.gz -g /etc/completa.snap /etc/*' 2> /dev/null
		ssh -i $1 root@$ip 'cp /etc/completa.snap /etc/diferencial.snap' 2> /dev/null
		# Completa del /var/cache
		ssh -i $1 root@$ip rm /var/cache/completa.snap /var/cache/diferencial.snap 2> /dev/null
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz -g /var/cache/completa.snap /var/cache/*' 2> /dev/null
		ssh -i $1 root@$ip 'cp /var/cache/completa.snap /var/cache/diferencial.snap' 2> /dev/null
		# Completa del /var/lib
               	ssh -i $1 root@$ip rm /var/lib/completa.snap /var/lib/diferencial.snap 2> /dev/null
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz -g /var/lib/completa.snap /var/lib/*' 2> /dev/null
		ssh -i $1 root@$ip 'cp /var/lib/completa.snap /var/lib/diferencial.snap' 2> /dev/null
		# Completa del /var/log
		ssh -i $1 root@$ip rm /var/log/completa.snap /var/log/diferencial.snap 2> /dev/null
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz -g /var/log/completa.snap /var/log/*' 2> /dev/null
		ssh -i $1 root@$ip 'cp /var/log/completa.snap /var/log/diferencial.snap' 2> /dev/null
		# Completa del /var/www
                ssh -i $1 root@$ip rm /var/www/completa.snap /var/www/diferencial.snap 2> /dev/null
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz -g /var/www/completa.snap /var/www/*' 2> /dev/null
		ssh -i $1 root@$ip 'cp /var/www/completa.snap /var/www/diferencial.snap' 2> /dev/null
                # Completa del /var/spool
               	ssh -i $1 root@$ip rm /var/spool/completa.snap /var/spool/diferencial.snap 2> /dev/null
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_spool.tar.gz -g /var/spool/completa.snap /var/spool/*' 2> /dev/null
                ssh -i $1 root@$ip 'cp /var/spool/completa.snap /var/spool/diferencial.snap' 2> /dev/null
                # Completa del /usr/sbin
               	ssh -i $1 root@$ip rm /usr/sbin/completa.snap /usr/sbin/diferencial.snap 2> /dev/null
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/usr_sbin.tar.gz -g /usr/sbin/completa.snap /usr/sbin/*' 2> /dev/null
                ssh -i $1 root@$ip 'cp /usr/sbin/completa.snap /usr/sbin/diferencial.snap' 2> /dev/null

		# Se comprime todo y se manda al servidor de copias de seguridad 
		ssh -i $1 root@$ip 'tar -czpf /tmp/backup/completa_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
		scp -i $1 root@$ip:/tmp/backup/completa_$fecha.tar.gz /$3/$hostname/completas 1> /dev/null
		# Borramos el directorio /tmp/backup
		ssh -i $1 root@$ip rm -r /tmp/backup

		#Insertamos un nuevo registro en el log
		fechahora=`date +%b' '%d' '%H':'%M':'%S`
		estado=`ls /$3/$hostname/completas/completa_$fecha.tar.gz | wc -l`
		if [ $estado = 1 ]
		then
			echo "$fechahora $hostname completa: copia realizada" >> /$3/backup_log
		else
			echo "$fechahora $hostname completa: copia fallida" >> /$3/backup_log
		fi
	else
		# Si el dia no es lunes, la copia sera diferencial

                # Diferencial de los homes
                homes=`ssh -i $1 root@$ip ls /home`
                for i in $homes
                do
                        # Homes de los usuarios
                        ssh -i $1 root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz -g /home/'$i'/diferencial.snap /home/'$i'/*' 2> /dev/null
                done
                        # Home del root
                        ssh -i $1 root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz -g /root/diferencial.snap /root/*' 2> /dev/null
                # Diferencial del /etc
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/etc.tar.gz -g /etc/diferencial.snap /etc/*' 2> /dev/null
                # Diferencial del /var/cache
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz -g /var/cache/diferencial.snap /var/cache/*' 2> /dev/null
                # Diferencial del /var/lib
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz -g /var/lib/diferencial.snap /var/lib/*' 2> /dev/null
                # Diferencial del /var/log
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz -g /var/log/diferencial.snap /var/log/*' 2> /dev/null
                # Diferencial del /var/www
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz -g /var/www/diferencial.snap /var/www/*' 2> /dev/null
                # Completa del /var/spool
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/var_spool.tar.gz -g /var/spool/completa.snap /var/spool/*' 2> /dev/null
                # Completa del /usr/sbin
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/usr_sbin.tar.gz -g /usr/sbin/completa.snap /usr/sbin/*' 2> /dev/null

                # Se comprime todo y se manda al servidor de copias de seguridad
                ssh -i $1 root@$ip 'tar -czpf /tmp/backup/diferencial_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
                scp -i $1 root@$ip:/tmp/backup/diferencial_$fecha.tar.gz /$3/$hostname/diferenciales 1> /dev/null
                # Borramos el directorio /tmp/backup
                ssh -i $1 root@$ip rm -r /tmp/backup

                #Insertamos un nuevo registro en el log
                fechahora=`date +%b' '%d' '%H':'%M':'%S`
                estado=`ls /$3/$hostname/diferenciales/diferencial_$fecha.tar.gz | wc -l`
                if [ $estado = 1 ]
                then
                        echo "$fechahora $hostname diferencial: copia realizada" >> /$3/backup_log
                else
                        echo "$fechahora $hostname diferencial: copia fallida" >> /$3/backup_log
                fi
	fi
done
