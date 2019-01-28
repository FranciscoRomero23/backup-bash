# backup-bash

Estos son unos scripts cuya función es realizar copias de seguridad remotas en una infraestructura de equipos gnu/linux.

Son cuatro scripts:

* backups.sh: Se encarga de hacer las copias de seguridad (los lunes una completa y diferenciales el resto de dias).
* restauracion.sh: Se encarga de restaurar la copia de seguridad que le indiquemos.
* borrar-copias.sh: Borra las copias diferenciales actuales.
* instalacion.sh: Se encarga de crear los directorios y añadir las tareas al crontab para el funcionamiento de los scripts.

Instrucciones para implantar el sistema de copias de seguridad

# Clona el repositorio a tu servidor de copias de seguridad.
2. Crea un fichero clientes.csv donde estarán el hostname y la dirección ip de tus clientes, con un formato hostname:direccionip.
3. Crea un par de claves ssh y comparte la clave publica con tus clientes (fichero authorized_keys).
4. Configura los parametros en los scripts backups.sh, borrar-copias.sh e instalacion.sh 
5. Ejecuta el script instalacion.sh

