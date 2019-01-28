#!/bin/bash

# Script que borra las copias de seguridad diferenciales disponibles.
# Script creado por Francisco José Romero Morillo.

## Parámetros para el script
# Ruta del fichero clientes.csv
clientes=""
# Ruta del directorio principal para las copias de seguridad
directorio=""

while IFS=: read -r hostname ip
do
        rm -r /$directorio/$hostname/diferenciales/*
done < $clientes
