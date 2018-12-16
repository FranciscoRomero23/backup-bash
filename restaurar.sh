#!/bin/bash

# Script que restaura las copias de seguridad disponibles.
# Indicas cliente y dia, y te restaura esa copia.
# Script creado por Francisco José Romero Morillo.

# Este script utiliza tres parametros:
# Parametro 1: ruta clave privada ssh
# Parametro 2: ruta fichero clientes.csv
# Parametro 3: ruta directorio pricipal de copias

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

disponible=`cat $2 | grep -w $cliente | wc -l`

if [ $disponible != 0 ]
then
	echo "Restaurando copia del cliente $cliente para la fecha $fecha..."

	ip=`cat $2 | grep -w $cliente | cut -d":" -f2`
	ssh -i $1 root@$ip mkdir /tmp/backup/completa
	ssh -i $1 root@$ip mkdir /tmp/backup/diferencial

	# Mandamos las copias al cliente
	scp -i $1 /$3/$cliente/completas/completa_$fecha.tar.gz root@$ip:/tmp/backup
	scp -i $1 /$3/$cliente/diferenciales/diferencial_$fecha.tar.gz root@$ip:/tmp/backup

	# Descomprimimos las copias
	ssh -i $1 root@$ip tar -xzpf /tmp/backup/completa_$fecha.tar.gz /tmp/backup/completa
	ssh -i $1 root@$ip tar -xzpf /tmp/backup/diferencial_$fecha.tar.gz /tmp/backup/diferencial

	echo "Restauración completada."
else
	echo "No existe el cliente $cliente o lo has escrito mal"
fi
