# backup-bash

Estos son unos scripts cuya función es realizar copias de seguridad remotas en una infraestructura de equipos gnu/linux.

Son cuatro scripts:

* backups.sh: Se encarga de hacer las copias de seguridad (los lunes una completa y diferenciales el resto de dias).
* restauracion.sh: Se encarga de restaurar la copia de seguridad que le indiquemos.
* borrar-copias.sh: Borra las copias diferenciales actuales.
* instalacion.sh: Se encarga de crear los directorios y añadir las tareas al crontab para el funcionamiento de los scripts.

Dentro del script backups.sh se realiza un insert en una tabla donde se guardan los registros de las copias. La base de datos debe ser MySql/MariaDB y puede crearse con la siguiente sentencia sql:

```sql
create table copias
(
fecha varchar(8),
hora    varchar(8),
host    varchar(8),
tipo    varchar(11),
estado  varchar(9),
constraint pk_copias primary key(fecha,host)
);
```

Instrucciones para implantar el sistema de copias de seguridad

1. Clona el repositorio a tu servidor de copias de seguridad.
2. Crea un fichero clientes.csv donde estarán el hostname y la dirección ip de tus clientes, con un formato hostname:direccionip.
3. Crea un par de claves ssh y comparte la clave publica con tus clientes (fichero authorized_keys).
4. Configura los parametros en los scripts backups.sh, borrar-copias.sh e instalacion.sh 
5. Crea la base de datos para los registros y cambia los datos del insert dentro del script backups.sh
6. Ejecuta el script instalacion.sh
