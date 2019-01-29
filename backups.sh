#!/bin/bash

# Script que realiza copias de seguridad en los clientes disponibles.
# Los lunes hace una copia completa y el resto de días hace una copia diferencial.
# Script creado por Francisco José Romero Morillo.

## Parámetros para el script
# Ruta de la clave privada ssh
clavessh=""
# Ruta del fichero clientes.csv
clientes=""
# Ruta del directorio principal para las copias de seguridad
directorio=""
# Ruta del script backups.sh
script=""

## Parámetros para la base de datos
# Usuario
user=""
# Contraseña
passwd=""
# Nombre de la base de datos
bd=""

diasemana=`date +%u`
fecha=`date +%d-%m-%y`

clientes=`cat $clientes | cut -d":" -f2`
for ip in $clientes
do
	# Generamos el directorio donde se preparara la copia de seguridad
	ssh -i $clavessh root@$ip mkdir /tmp/backup

        # Obtenemos el hostname del cliente
        hostname=`ssh -i $clavessh root@$ip hostname -s`

	# Generamos un fichero con los paquetes del sistema
	if [ $hostname == "zapatero" ]
	then
		ssh -i $clavessh root@$ip 'rpm -qa > /tmp/backup/packages.txt'
	else
		ssh -i $clavessh root@$ip 'dpkg -l | grep ^i | cut -d" " -f3 > /tmp/backup/packages.txt'
	fi

	# Hacemos la copia de seguridad según el día de la semana
	if [ $diasemana = 1 ]
	then
		# Si el día es lunes, la copia sera completa

		# Completa de los homes
		homes=`ssh -i $clavessh root@$ip ls /home`
		for i in $homes
		do
			# Homes de los usuarios
			ssh -i $clavessh root@$ip rm /home/$i/completa.snap /home/$i/diferencial.snap 2> /dev/null
			ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz -g /home/'$i'/completa.snap /home/'$i'/*' 2> /dev/null
			ssh -i $clavessh root@$ip 'cp /home/'$i'/completa.snap /home/'$i'/diferencial.snap' 2> /dev/null
		done
			# Home del root
			ssh -i $clavessh root@$ip rm /root/completa.snap /root/diferencial.snap 2> /dev/null
			ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz -g /root/completa.snap /root/*' 2> /dev/null
			ssh -i $clavessh root@$ip 'cp /root/completa.snap /root/diferencial.snap' 2> /dev/null
		# Completa del /etc
		ssh -i $clavessh root@$ip rm /etc/completa.snap /etc/diferencial.snap 2> /dev/null
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/etc.tar.gz -g /etc/completa.snap /etc/*' 2> /dev/null
		ssh -i $clavessh root@$ip 'cp /etc/completa.snap /etc/diferencial.snap' 2> /dev/null
		# Completa del /var/cache
		ssh -i $clavessh root@$ip rm /var/cache/completa.snap /var/cache/diferencial.snap 2> /dev/null
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz -g /var/cache/completa.snap /var/cache/*' 2> /dev/null
		ssh -i $clavessh root@$ip 'cp /var/cache/completa.snap /var/cache/diferencial.snap' 2> /dev/null
		# Completa del /var/lib
               	ssh -i $clavessh root@$ip rm /var/lib/completa.snap /var/lib/diferencial.snap 2> /dev/null
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz -g /var/lib/completa.snap /var/lib/*' 2> /dev/null
		ssh -i $clavessh root@$ip 'cp /var/lib/completa.snap /var/lib/diferencial.snap' 2> /dev/null
		# Completa del /var/log
		ssh -i $clavessh root@$ip rm /var/log/completa.snap /var/log/diferencial.snap 2> /dev/null
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz -g /var/log/completa.snap /var/log/*' 2> /dev/null
		ssh -i $clavessh root@$ip 'cp /var/log/completa.snap /var/log/diferencial.snap' 2> /dev/null
		# Completa del /var/www
                ssh -i $clavessh root@$ip rm /var/www/completa.snap /var/www/diferencial.snap 2> /dev/null
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz -g /var/www/completa.snap /var/www/*' 2> /dev/null
		ssh -i $clavessh root@$ip 'cp /var/www/completa.snap /var/www/diferencial.snap' 2> /dev/null
                # Completa del /var/spool
               	ssh -i $clavessh root@$ip rm /var/spool/completa.snap /var/spool/diferencial.snap 2> /dev/null
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_spool.tar.gz -g /var/spool/completa.snap /var/spool/*' 2> /dev/null
                ssh -i $clavessh root@$ip 'cp /var/spool/completa.snap /var/spool/diferencial.snap' 2> /dev/null
                # Completa del /usr/sbin
               	ssh -i $clavessh root@$ip rm /usr/sbin/completa.snap /usr/sbin/diferencial.snap 2> /dev/null
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/usr_sbin.tar.gz -g /usr/sbin/completa.snap /usr/sbin/*' 2> /dev/null
                ssh -i $clavessh root@$ip 'cp /usr/sbin/completa.snap /usr/sbin/diferencial.snap' 2> /dev/null

		# Se comprime todo y se manda al servidor de copias de seguridad 
		ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/completa_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
		scp -i $clavessh root@$ip:/tmp/backup/completa_$fecha.tar.gz /$directorio/$hostname/completas 1> /dev/null
		# Borramos el directorio /tmp/backup
		ssh -i $clavessh root@$ip rm -r /tmp/backup

		#Insertamos un nuevo registro en el log
		estado=`ls /$directorio/$hostname/completas/completa_$fecha.tar.gz | wc -l`
		if [ $estado = 1 ]
		then
                        fechasql=`date +%d/%m/%y`
                        hora=`date +%H:%M:%S`
                        echo "insert into copias values('$fechasql','$hora','$hostname','completa','realizada');" >> /$directorio/copia.sql
                        mysql -u $user -p$passwd $bd < /$directorio/copia.sql
                        rm /$directorio/copia.sql
                else
                        fechasql=`date +%d/%m/%y`
                        hora=`date +%H:%M:%S`
                        echo "insert into copias values('$fechasql','$hora','$hostname','completa','fallida');" >> /$directorio/copia.sql
                        mysql -u $user -p$passwd $bd < /$directorio/copia.sql
                        rm /$directorio/copia.sql
		fi
	else
		# Si el día no es lunes, la copia sera diferencial

                # Diferencial de los homes
                homes=`ssh -i $clavessh root@$ip ls /home`
                for i in $homes
                do
                        # Homes de los usuarios
                        ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/home_'$i'.tar.gz -N "last Mon" /home/'$i'/*' 2> /dev/null
                done
                        # Home del root
                        ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/home_root.tar.gz -N "last Mon" /root/*' 2> /dev/null
                # Diferencial del /etc
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/etc.tar.gz -N "last Mon" /etc/*' 2> /dev/null
                # Diferencial del /var/cache
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_cache.tar.gz -N "last Mon" /var/cache/*' 2> /dev/null
                # Diferencial del /var/lib
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_lib.tar.gz -N "last Mon" /var/lib/*' 2> /dev/null
                # Diferencial del /var/log
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_log.tar.gz -N "last Mon" /var/log/*' 2> /dev/null
                # Diferencial del /var/www
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_www.tar.gz -N "last Mon" /var/www/*' 2> /dev/null
                # Completa del /var/spool
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/var_spool.tar.gz -N "last Mon" /var/spool/*' 2> /dev/null
                # Completa del /usr/sbin
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/usr_sbin.tar.gz -N "last Mon" /usr/sbin/*' 2> /dev/null

                # Se comprime todo y se manda al servidor de copias de seguridad
                ssh -i $clavessh root@$ip 'tar -czpf /tmp/backup/diferencial_'$fecha'.tar.gz /tmp/backup/*' 2> /dev/null
                scp -i $clavessh root@$ip:/tmp/backup/diferencial_$fecha.tar.gz /$directorio/$hostname/diferenciales 1> /dev/null
                # Borramos el directorio /tmp/backup
                ssh -i $clavessh root@$ip rm -r /tmp/backup

                #Insertamos un nuevo registro en el log
                estado=`ls /$directorio/$hostname/diferenciales/diferencial_$fecha.tar.gz | wc -l`
                if [ $estado = 1 ]
                then
                        fechasql=`date +%d/%m/%y`
                        hora=`date +%H:%M:%S`
                        echo "insert into copias values('$fechasql','$hora','$hostname','diferencial','realizada');" >> /$directorio/copia.sql
                        mysql -u $user -p$passwd $bd < /$directorio/copia.sql
                        rm /$directorio/copia.sql
                else
                        fechasql=`date +%d/%m/%y`
                        hora=`date +%H:%M:%S`
                        echo "insert into copias values('$fechasql','$hora','$hostname','diferencial','fallida');" >> /$directorio/copia.sql
                        mysql -u $user -p$passwd $bd < /$directorio/copia.sql
                        rm /$directorio/copia.sql
                fi
	fi
done
