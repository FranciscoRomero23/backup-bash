#!/bin/bash

# Este script se encargara de crear los directorios donde se guardaran las copias de seguridad
# y de añadir al crontab las tareas de copias de seguridad.
# Script creado por Francisco José Romero Morillo.

## Parámetros para el script
# Ruta de la clave privada ssh
clavessh=""
# Ruta del fichero clientes.csv
clientes=""
# Ruta del directorio principal para las copias de seguridad
directorio=""
# Ruta del script backups.sh
script_backup=""
# Ruta del script borrar-copias.sh
script_borrar=""

# Se crean los directorios para las copias de seguridad
while IFS=: read -r hostname ip
do
	mkdir /$directorio/$hostname
	mkdir /$directorio/$hostname/completas
	mkdir /$directorio/$hostname/diferenciales
done < $clientes

# Se añaden al crontab las tareas de copias de seguridad
echo "0 23 * * * bash $script_backup" >> /var/spool/cron/crontabs/root
echo "0 16 * 1 * bash $script_borrar" >> /var/spool/cron/crontabs/root
