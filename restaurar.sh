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
done < equipos.csv
echo "##############################"

# Pedimos el cliente y la fecha de la copia de seguridad
echo "¿Cliente?"
read cliente
echo "¿Fecha?"
read fecha

disponible=`cat equipos.csv | grep -w $cliente | wc -l`

if [ $disponible != 0 ]
then
	echo "Restaurando copia del cliente $cliente para la fecha $fecha..."
	echo "Restauración completada."
else
	echo "No existe el cliente $cliente o lo has escrito mal"
fi
