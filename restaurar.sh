#!/bin/bash

# Script que restaura las copias de seguridad disponibles.
# Indicas cliente y fecha de las copias, y te restaura esas copias.
# Script creado por Francisco José Romero Morillo.

# Este script utiliza tres parámetros:
# Parámetro 1: ruta clave privada ssh
# Parámetro 2: ruta fichero clientes.csv
# Parámetro 3: ruta directorio pricipal de copias

# Mostramos los clientes de los que guardamos copias
echo "##############################"
echo "#    Clientes disponibles    #"
echo "##############################"
while IFS=: read -r hostname ip
do
	echo "# $hostname - $ip"
done < $2
echo "##############################"

# Pedimos el cliente y las fechas de las copias
echo "¿De que cliente es la copia de seguridad?"
read cliente
echo "Dime la fecha de la copia completa"
read completa
echo "Dime la fecha de la copia diferencial"
read diferencial

# Comprobamos si existe el cliente
cliente_existe=`cat $2 | grep -w $cliente | wc -l`

if [ $cliente_existe = 1 ]
then
	# Comprobamos si las fechas son correctas
	completa_existe=`ls /$3/$cliente/completas | grep $completa | wc -l`
	diferencial_existe=`ls /$3/$cliente/completas | grep $diferencial | wc -l`

	if [ $completa_existe = 1 ] && [ $diferencial_existe = 1 ]
	then
		echo "Restaurando copia del cliente $cliente para la fecha $diferencial..."

		ip=`cat $2 | grep -w $cliente | cut -d":" -f2`

		# Creamos un directorio para las copias de seguridad
		ssh -i $1 root@$ip mkdir /backups

		# Mandamos las copias al cliente
		scp -i $1 /$3/$cliente/completas/completa_$completa.tar.gz root@$ip:/backups 1> /dev/null
		scp -i $1 /$3/$cliente/diferenciales/diferencial_$completa.tar.gz root@$ip:/backups 1> /dev/null

		# Descomprimimos las copia completa
		ssh -i $1 root@$ip 'tar -xzpf /backups/completa_'$completa'.tar.gz -C /'
		contenido=`ssh -i $1 root@$ip ls /tmp/backup/*.tar.gz`
		for i in $contenido
		do
			ssh -i $1 root@$ip 'tar -xzpf '$i' -C /'
		done

		# Instalamos los paquetes provenientes del fichero packages.txt
		paquetes=`ssh -i $1 root@$ip cat /tmp/backup/packages.txt`
		listapaquetes=''
		for i in $paquetes
		do
			listapaquetes="$listapaquetes $i"
		done
		if [ $cliente =="zapatero" ]
		then
			yum update -y
			yum install $listapaquetes -y 1> /dev/null
		else
			apt-get update -y 1 > /dev/null
			apt-get install $listapaquetes -y 1> /dev/null
		fi

		# Vaciamos el directorio /tmp/backup
		ssh -i $1 root@$ip rm -r /tmp/backup

	        # Descomprimimos las copia diferencial
	        ssh -i $1 root@$ip 'tar -xzpf /backups/diferencial_'$diferencial'.tar.gz -C /'
	        contenido=`ssh -i $1 root@$ip ls /tmp/backup/*.tar.gz`
	        for i in $contenido
	        do
	               	ssh -i $1 root@$ip 'tar -xzpf '$i' -C /'
	        done

		# Instalamos los paquetes provenientes del fichero packages.txt
		paquetes=`ssh -i $1 root@$ip cat /tmp/backup/packages.txt`
		listapaquetes=''
		for i in $paquetes
		do
		        listapaquetes="$listapaquetes $i"
		done
                if [ $cliente =="zapatero" ]
                then
                        yum update -y
                        yum install $listapaquetes -y 1> /dev/null
                else
                        apt-get update -y 1 > /dev/null
                        apt-get install $listapaquetes -y 1> /dev/null
                fi

		# Borramos los ficheros tar.gz
		ssh -i $1 root@$ip rm -r /backups
		ssh -i $1 root@$ip rm -r /tmp/backup

		echo "Restauración completada."
	else
		echo "Las fechas no son correctas o las has escrito mal."
	fi
else
	echo "El cliente $cliente no existe o lo has escrito mal."
fi
