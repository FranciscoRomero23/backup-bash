# backup-bash

Estos son unos scripts cuya funcion es realizar copias de seguridad remotas en una infraestructura de equipos gnu/linux.

Instrucciones para implantar el sistema de copias de seguridad

1. Clona el repositorio a tu servidor de copias de seguridad.

2. Crea un fichero clientes.csv donde estaran el hostname y la dirección ip de tus clientes.
   Siguiendo este formato:
        hostname:ipdaddres
   Ejemplo:
        debian9:192.168.1.175

3. Crea un par de claves ssh y comparte la clave publica con tus clientes (fichero authorized_keys).

4. Ejecuta el script instalación.sh

Script instalacion.sh

Este script realizara los siguientes pasos:

1. Creara los directorios donde se guardaran las copias de seguridad.

2. Añadira al crontab las tareas de copias de seguridad.

Al script debes indicarle cuatro parametros:

   Parametro 1: ruta de la clave privada ssh
   Parametro 2: ruta del fichero clientes.csv
   Parametro 3: ruta del directorio principal para las copias de seguridad
   Parametro 4: ruta del script backups.sh
