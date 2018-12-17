# backup-bash

Estos son unos scripts cuya función es realizar copias de seguridad remotas en una infraestructura de equipos gnu/linux.

Instrucciones para implantar el sistema de copias de seguridad

1. Clona el repositorio a tu servidor de copias de seguridad.

2. Crea un fichero clientes.csv donde estarán la dirección ip de tus clientes.

3. Crea un par de claves ssh y comparte la clave publica con tus clientes (fichero authorized_keys).

4. Ejecuta el script instalacion.sh

	Al script debes indicarle cuatro parámetros:

	* Parámetro 1: ruta de la clave privada ssh
	* Parámetro 2: ruta del fichero clientes.csv
	* Parámetro 3: ruta del directorio principal para las copias de seguridad
	* Parámetro 4: ruta del script backups.sh

        Este script realizara los siguientes pasos:

        1. Creara los directorios donde se guardaran las copias de seguridad.

        2. Añadirá al crontab las tareas de copias de seguridad.

        3. Creara el fichero de registros en el directorio principal para las copias de seguridad

