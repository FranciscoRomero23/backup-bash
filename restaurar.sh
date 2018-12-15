#!/bin/bash

# Script que restaura las copias de seguridad disponibles.
# Indicas cliente y dia, y te restaura esa copia.
# Script creado por Francisco José Romero Morillo.

# Mostramos los clientes de los que guardamos copias
echo "##############################"
echo "#    Clientes disponibles    #"
echo "##############################"
while IFS=: read -r hostname ip
do
	echo "# $hostname - $ip"
done < clientes.csv
echo "##############################"

# Pedimos el cliente y las fechas de las copias
echo "¿De que cliente es la copia de seguridad?"
read cliente
echo "¿De que fecha es la copia de seguridad?"
read fecha

disponible=`cat clientes.csv | grep -w $cliente | wc -l`

if [ $disponible != 0 ]
then
	echo "Restaurando copia del cliente $cliente para la fecha $fecha..."

	ip=`cat clientes.csv | grep -w $cliente | cut -d":" -f2`
	ssh -i /root/.ssh/backup-key root@$ip mkdir /tmp/backup/completa
	ssh -i /root/.ssh/backup-key root@$ip mkdir /tmp/backup/diferencial

	# Mandamos las copias al cliente
	scp -i /root/.ssh/backup-key /copias/$cliente/completas/completa_$fecha.tar.gz root@$ip:/tmp/backup
	scp -i /root/.ssh/backup-key /copias/$cliente/diferenciales/diferencial_$fecha.tar.gz root@$ip:/tmp/backup

	# Descomprimimos las copias
	ssh -i /root/.ssh/backup-key root@$ip tar -xzpf /tmp/backup/completa_$fecha.tar.gz /tmp/backup/completa	
	ssh -i /root/.ssh/backup-key root@$ip tar -xzpf /tmp/backup/diferencial_$fecha.tar.gz /tmp/backup/diferencial

	echo "Restauración completada."
else
	echo "No existe el cliente $cliente o lo has escrito mal"
fi
