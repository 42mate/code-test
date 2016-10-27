# Diario de puesta en funcionamiento de un blog en Drupal

El objetivo del proyecto consiste en implementar un blog personal en PHP. El
proyecto tiene que ajustarse a las siguientes condiciones:

1. Debe tener una base de datos.
2. Debe estar implmentando en PHP.
3. Puede tener componentes en JavaScript.
4. Debe funcionar en celulares.
5. Debe contar con un frontend y un backend autenticado con nombre de usuario y
   contraseña para postear en el blog.
6. Los posts deben poder contar con imágenes (file uploads).
7. El proyecto debe versionarse en este [repositorio](https://github.com/42mate/code-test).
8. El proyecto debe deployearse en un servidor de producción que será entregado y deberá configurarlo.

## Selección del framework web en PHP

Dado que han pasado bastantes años desde la última vez que tuve que poner en un
funcionamiento un blog desarrollado en PHP (Wordpress en aquel entonces) consideré
oportuno realizar una búsqueda exploratoria en la web para tener un vistazo del
panorama actual en el ecosistema de PHP. La idea era tener un conocimiento
sobre las herramientas disponibles que permitan instalar, configurar y desplegar rápidamente un blog.

Hay varias preguntas que surgen para encarar este proyecto de blog:

1. ¿Voy a implementarlo desde cero? Es decir ¿me conviene estar desarrollando
  funcionalidades tales como manejo de usuarios, credenciales, ruteo de URLs,
  loop de un blog, paginación?
2. ¿Voy a implementarlo utilizando como base algún framework web, como por ejemplo,
  [Laravel](https://laravel.com/)?
3. ¿Voy a utilizar algún paquete, módulo, extensión oficial o de terceros para
   ser instalada en algún CMS o framework web en PHP?

Consideré descartar entonces la alternativa 1, desarrollar desde cero, dado que
para el caso actual prioricé tener una solución rápida para probar y que,
además, no tengo el el conocimiento necesario en el lenguaje PHP para llevar a
cabo este proyecto en particular.

En cuanto a la alternativa 2, he encontrado guías y tutoriales que prometen tener
un blog personal "*en 10 minutos*" pero, visto y considerando los ejemplos,
implicaría comprender adecuadamente la sintaxis y construcciones de programación
del lenguaje en poco tiempo. Además, de manera similar con la alternativa 1,
mis conocimientos en el lenguaje hubiesen tranformado esos 10 minutos en 1000+
minutos (por decir un número).

¡Entonces! La tercera alternativa parecía ajustarse en gran parte al proyecto
solicitado. Entre las búsquedas en la web aparecía como destacado el módulo
[`Blog`](https://www.drupal.org/documentation/modules/blog) para Drupal. Según
la documentación, este módulo se encuentra incluído en el core de Drupal 7 pero
en Drupal 8 los desarrolladores decidieron publicarlo como módulo aparte.
Parece ser entonces este módulo lo que estaba buscando. La documentación del
módulo es corta, simple pero rendidora.

Como no sabía si tendría problemas al instalar el módulo `Blog` al utilizar Drupal 8
decidí por utilizar Drupal 7, el cual recordemos ya incluye dicho módulo.

#### ¿Y Wordpress?

Durante el análisis de alternativas me cruzó por la mente utilizar Wordpress. Tenía
a favor las ventajas de que ya me tocado instalarlo y configurarlo en un hosting
y es, en el área de blogging, uno de los reyes. A pesar de ello, las condiciones
propuestas para el proyecto hacen referencia a palabras como "backend", "frontend", "celulares" y "JavaScript" entre otras, lo cual me hizo pensar que el sistema
tendría que ser, cuanto menos, modular y permitir ser extendido con, por ejemplo,
una API RESTful. Nuevamente, estas no son condiciones obligatorias explícitas,
solamente me tomé la libertad de pensar a futuro como detalle extra.  
¿Y entonces? A decir verdad, ignoraba si Wordpress cuenta con la capacidad
anteriormente requerida (por mí) y de esta manera, quedó descartado como
alternativa. *Cuestión:* hay que investigar más.

## Selección del entorno de desarrollo

Para llevar a cabo la la instalación de dependencias y desarrollo a nivel local
consideré importante aislar el entorno de desarollo de mi sistema operativo host.
Es por ello que elegí en este caso a Vagrant como herramienta de administración
del entorno virtualizado.

Necesitaría instalar en la VM, como mínimo, PHP, MySQL, Apache y Drupal.
Instalar otras herramientas como git, curl y algunos módulos para PHP es bienvenido
también. Buscando en la web he encontrado tutoriales, posts y consejos para instalar
lo anterior, claro, no todo junto por lo que el [Vagrantfile](../../Vagrantfile) y
el [archivo de provisioning](../../scripts/bootstrap.sh) terminan siendo una mezcla refinada de todo.

Debo reconocer que desde que comencé con el desarrollo del proyecto, pasé una
considerable cantidad de tiempo instalando, aprovisionando y configurando la máquina
virtual. He ahi la importancia de tener entonces pre-establecidos y depurados
para un arranque rápido en un proyecto.

#### ¿Y Docker?

Me pareció una buena oportunidad para utilizar Docker para el desarrollo de este
proyecto pero todavía no he llegado a probar lo suficiente y entender en detalle
la tecnología como para dedicar minutos/horas *ahora* en ponerlo en práctica. En
otro momento será.

## (Otros) Problemas encontrados

### Vlad

Poco antes de comenzar a proceder a instalar y configurar la máquina virtual me
topé con el proyecto [Vlad](https://github.com/hashbangcode/vlad) (Vagrant LAMP Ansible Drupal) el cual permite disponer en unos cuantos minutos de una
instalación virtualizada con PHP, MySQL, Apache, Git, Ansible, Varnish y Xdebug,
entre otros.  
La cuestión es que Vlad utiliza por defecto [NFS para las carpetas
sincronizadas](https://www.vagrantup.com/docs/synced-folders/nfs.html) por lo que
si el sistema operativo host no cuenta con las dependencias necesarias para soportar NFS (como era mi caso), el comando `vagrant up` falla. Se resuelve ejecutando
`sudo apt install nfs-common rpcbind nfs-kernel-server` en sistemas Debian y derivados.  
El siguiente problema fue con [Ansible](https://www.ansible.com/) al momento de
realizar el provisioning. Al parecer, Vlad tiene problemas con las últimas versiones
de Ansible si se encuentra instalado en el sistema operativo host.  
Decidí entonces definir "desde cero" el archivo Vagrantfile y la definición del
provisioning tomando como referencia algunas guías:

* https://www.dev-metal.com/super-simple-vagrant-lamp-stack-bootstrap-installable-one-command/
* https://www.digitalocean.com/community/tutorials/como-instalar-linux-apache-mysql-php-lamp-en-ubuntu-14-04-es
* https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md

### "The directory sites/default/files is not writable"

Este fue otro ítem que me consumió otra considerable cantidad de tiempo. El problema
consistía en que el instalador web de Drupal 7 advertía que no era capaz de escribir
en el archivo `sites/default/settings.php`. Al parecer, éste es un [problema](https://www.drupal.org/server-permissions) con el que se encuentran los [desarrolladores](http://theaccidentalcoder.com/content/drupal-and-permissions-avoiding-directory-sitesdefaultfiles-not-writable-error) [desde hace años](https://www.drupal.org/node/231865). Intenté por supuesto probando cambiar
los permisos y owner/grupo del archivo dentro de la máquina virtual, más sin efecto
positivo alguno.  
Un poco menos tranquilo ya, pensé que tal vez la instalación de Drupal 7 tuvo
problemas, que por cierto la realicé en base a [este post](https://www.lullabot.com/articles/goodbye-drush-make-hello-composer).
Aproveché que iba a reinstalar Drupal para instalar Drupal 8 (acción que en la
jerga estudiantil pre-examen se conoce como *"ya fue todo"*).  Pero no, el
problema ahora es que la carpeta `sites/defaults/files/translations` no es writable.  
Al final la solución consistió en [configurar en el Vagrantfile](http://jeremykendall.net/2013/08/09/vagrant-synced-folders-permissions/) para que la carpeta sincronizada tenga los atributos `user: "www-data"` y `group: "www-data"`, por lo que en el siguiente `vagrant reload` ya fue posible instalar Drupal.
Para instalar el módulo `Blog` seguí [esta conveniente guía](https://www.inmotionhosting.com/support/edu/drupal-8/blogging/install-enable).

## Deploy a producción

Mi intención era utilizar Ansible o [Fabric](http://www.fabfile.org/) pero decidí
empezar por lo más sencillo y tal vez menos organizado que son los scripts de
deploy. Para el provisioning en el servidor de producción reutilicé el archivo
de [bootstrap](../../scripts/bootstrap.sh) utilizado ya para Vagrant.

No tenía definido ningún flujo de trabajo para el deploy por lo que me terminé
decantando por:

1. Realizar provisioning del servidor.
2. Clonar el repositorio en GitHub en el servidor de producción.
3. Actualizar repositorio mediante `git pull origin master`
4. Reubicar ciertas carpetas dentro del repositorio en el directorio raíz del
   servidor web.
5. Instalar/actualizar dependencias del proyecto.
4. Volver al paso 3 y repetir.

En cuanto a credenciales de acceso, traté de seguir las recomendaciones propuestas
en [The Twelve-Factor App](https://12factor.net/).
