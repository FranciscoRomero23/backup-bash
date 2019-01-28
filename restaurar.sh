#!/bin/bash

# Script que restaura las copias de seguridad disponibles.
# Indicas cliente y fecha de las copias, y te restaura esas copias.
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

# Mostramos los clientes de los que guardamos copias
echo "##############################"
echo "#    Clientes disponibles    #"
echo "##############################"
while IFS=: read -r hostname ip
do
	echo "# $hostname - $ip"
done < $clientes
echo "##############################"

#Funciones para las restauraciones
function funcion_completa {

# Comprobamos si la fecha es correcta
completa_existe=`ls /$directorio/$cliente/completas | grep $fecha_completa | wc -l`

if [ $completa_existe = 1 ]
then
	echo "Restaurando copia del cliente $cliente para la fecha $fecha_completa..."

	ip=`cat $clientes | grep -w $cliente | cut -d":" -f2`

	# Creamos un directorio para las copias de seguridad
	ssh -i $clavessh root@$ip mkdir /backups

	# Mandamos la copia al cliente
	scp -i $clavessh /$directorio/$cliente/completas/completa_$completa.tar.gz root@$ip:/backups 1> /dev/null

	# Descomprimimos las copia completa
	ssh -i $clavessh root@$ip 'tar -xzpf /backups/completa_'$completa'.tar.gz -C /'
	contenido=`ssh -i $clavessh root@$ip ls /tmp/backup/*.tar.gz`
	for i in $contenido
	do
		ssh -i $clavessh root@$ip 'tar -xzpf '$i' -C /'
	done

	# Instalamos los paquetes provenientes del fichero packages.txt
	paquetes=`ssh -i $clavessh root@$ip cat /tmp/backup/packages.txt`
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
		apt-get update -y 1> /dev/null
		apt-get install $listapaquetes -y 1> /dev/null
	fi

	# Vaciamos el directorio /tmp/backup
	ssh -i $clavessh root@$ip rm -r /tmp/backup

	echo "Restauración completa completada."
else
	echo "La fecha no es correcta o la has escrito mal."
fi
}

function funcion_diferencial {

# Comprobamos si la fecha es correcta
diferencial_existe=`ls /$directorio/$cliente/completas | grep $diferencial | wc -l`

if [ $diferencial_existe = 1 ]
then
	echo "Restaurando copia del cliente $cliente para la fecha $diferencial..."

	ip=`cat $clientes | grep -w $cliente | cut -d":" -f2`

	# Creamos un directorio para las copias de seguridad
	ssh -i $clavessh root@$ip mkdir /backups

	# Mandamos la copia al cliente
	scp -i $clavessh /$directorio/$cliente/diferenciales/diferencial_$completa.tar.gz root@$ip:/backups 1> /dev/null

	# Descomprimimos las copia diferencial
	ssh -i $clavessh root@$ip 'tar -xzpf /backups/diferencial_'$diferencial'.tar.gz -C /'
	contenido=`ssh -i $clavessh root@$ip ls /tmp/backup/*.tar.gz`
	for i in $contenido
	do
	        ssh -i $clavessh root@$ip 'tar -xzpf '$i' -C /'
	done

	# Instalamos los paquetes provenientes del fichero packages.txt
	paquetes=`ssh -i $clavessh root@$ip cat /tmp/backup/packages.txt`
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
                apt-get update -y 1> /dev/null
                apt-get install $listapaquetes -y 1> /dev/null
        fi

	# Borramos los ficheros tar.gz
	ssh -i $clavessh root@$ip rm -r /backups
	ssh -i $clavessh root@$ip rm -r /tmp/backup

	echo "Restauración diferencial completada."
else
	echo "La fecha no es correcta o la has escrito mal."
fi
}

echo "¿Que tipo de copia quieres restaurar?"
read tipo_copia

case $tipo_copia in
	completa|Completa)
		# Pedimos el cliente y las fechas de las copias
		echo "¿De que cliente es la copia de seguridad?"
		read cliente
		echo "Dime la fecha de la copia completa"
		read fecha_completa
		# Comprobamos si existe el cliente
		cliente_existe=`cat $clientes | grep -w $cliente | wc -l`

		if [ $cliente_existe = 1 ]
		then
			# Ejecutamos las funciones
			funcion_completa
		else
			echo "El cliente $cliente no existe o lo has escrito mal."
		fi
          ;;
	diferencial|Diferencial)
		# Pedimos el cliente y las fechas de las copias
		echo "¿De que cliente es la copia de seguridad?"
		read cliente
		echo "Dime la fecha de la copia completa"
		read fecha_completa
		echo "Dime la fecha de la copia diferencial"
		read fecha_diferencial
		# Comprobamos si existe el cliente
		cliente_existe=`cat $clientes | grep -w $cliente | wc -l`

		if [ $cliente_existe = 1 ]
		then
			# Ejecutamos las funciones
			funcion_completa
			funcion_diferencial
		else
			echo "El cliente $cliente no existe o lo has escrito mal."
		fi
          ;;
	*)
          echo "Opción incorrecta o mal escrita."
          ;;
esac

