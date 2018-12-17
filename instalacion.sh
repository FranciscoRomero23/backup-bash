#!/bin/bash

# Este script se encargara de crear los directorios donde se guardaran las copias de seguridad
# y de añadir al crontab las tareas de copias de seguridad.
# Script creado por Francisco José Romero Morillo.

# Se crean los directorios para las copias de seguridad
while IFS=: read -r hostname ip
do
	mkdir /$3/$hostname
	mkdir /$3/$hostname/completas
	mkdir /$3/$hostname/diferenciales
done < $2

# Se añaden al crontab las tareas de copias de seguridad

echo "0 22 * * * bash $4 $1 $2 $3" >> /var/spool/cron/crontabs/root

# Se crea el fichero de registros
touch /$3/backup_log
