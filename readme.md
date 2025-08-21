# Inception
> 42 project. Docker container discovery.

**Inception** est un projet visant à déployer une stack de services Docker pour créer un environnement web complet et fonctionnel. Ce projet permet de comprendre comment configurer et orchestrer plusieurs services (Nginx, WordPress, MariaDB, Redis) à l'aide de Docker et Docker Compose.

---

## 📝 Description
***Inception*** est une introduction à l'orchestration de conteneurs **Docker**. Le projet consiste à créer une infrastructure complète pour héberger un site WordPress, avec les services suivants :
- **Nginx** : Serveur web et reverse proxy.
- **WordPress** : Système de gestion de contenu (CMS).
- **MariaDB** : Base de données pour WordPress.

## Docker
**Docker** permet la conteneurisation de chaque service. **Docker compose** Permet l'orchestration de plusieurs conteneurs. De par le sujet, un simple `make` doit effectuer toutes les commandes necessaire au démarrage de l'environnement.

Pour fonctionner, **Docker compose** a besoin d'un fichier de configuration **docker-compose.yml**.
Ce fichier liste tout les services (et donc tout les conteneurs), ainsi que leurs différents parametres d'utilisation.

```
(exemple d'un service dans 'docker-compose.yml')

nginx:
                build: requirements/nginx/.             // racine du services
                image: nginx:42                         // nom de l'image docker
                container_name: nginx                   // nom du conteneur créer
                ports:
                        - 443:443                       // port ouvert du conteneur
                volumes:
                        - /home/bgaertne/data/web:/var/www/html     // volume du conteneur
                depends_on:                             
                        - wordpress                     // definition des dépendances
                        - mariadb
                networks:                                
                        inception:                      // reseau auquel le conteneur appartient
                env_file:                               
                        - .env                          // fichier de variables d'env du conteneur
                restart: always                         // stratégie de redémarrage
```

### Détails des parametres de service

- **Racine du service**: ici doit se trouver le dockerfile, nécéssaire a la création du conteneur, ainsi tout autre fichier necessaire a la configuration.

- **Nom de l'image et du conteneur**: Interdiction de prendre une image préfaite; le nom de l'image doit etre le nom du service qui tourne dans le container, et le containeur doit porter le nom de son service.

- **Ports**: Un container est hermétique par défault. Nginx étant notre proxis, on doit pouvoir communiquer avec lui via le port HTTPS (443).

- **Volumes**: Un container, si éteint, est supprimé. Pour faire persisté les données, on paramètre un "dossier partager" entre le conteneur et la machine hote. (format/  */HOTE/:/CONTENEUR/*)

- **Dépendances**: Si un conteneur/service a besoin d'un autre service en ammont, on précise a notre conteneur d'attendre que les conteneurs de cette liste soit démarré. Ici, notre conteneur *nginx* ne démarreras que si les deux conteneurs **wordpress** et **mariadb** sont démarrés.

- **Réseau**: On place nos conteneurs dans le reseau fictif **inception**, pour qu'ils puissent communiquer entre eux (Si leurs ports sont bien configurés également).
 
- **stratégie de redémarrage**: On indique au conteneur de redémarrer ou non sous certaines conditions. ici, on souhaite que le conteneurs redémarre peu importe les circonstances. Il est possible par exemple de ne redémarrer que si le conteneur s'est arréter suite a une erreur.


### Orchestration par makefile:

La regle **all** du Makefile effectue la commande `docker-compose up --build`.
**Docker compose** créer alors les conteneurs (et leurs volumes, réseaux...) grace au **docker-compose.yml** et aux **Dockerfile** de chaques services, et on lui force a reconstruire les image à chaque fois avec **--build**. (autrement, une image n'est créer qu'une fois puis réutiliser à chaque démarrage du conteneur associé. Meme si le Dockerfile à été modifié)

La regle **clean** utilise les commandes `docker`: `stop`, `rm`, `rmi`, `volume rm` et `network rm` pour arreter les conteneurs, les supprimer, supprimer les images, les volumes et les réseaux créer par **Docker compose**

La regle **fclean** supprime les fichiers wordpress et DB, puisqu'on doit télécharger et installer wordpress automatiquement.

## Les services
Trois services: **Wordpress**, le site web. **MariaDB**, la base de données. Et **Nginx** le reverse proxy.

### Wordpress

```
FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
        php7.4-fpm \
	php7.4-mysqli \
	curl

RUN mkdir -p /run/php

COPY ./conf/www.conf etc/php/7.4/fpm/pool.d/.
COPY ./conf/script.sh .
RUN chmod +x script.sh

EXPOSE 9000

CMD ["./script.sh"]
```

Sur une base de **debian** qu'on **update**, **upgrade**, et ou on installe **php** et **curl** (pour faire fonctionner et télécharger wordpress).

On créer ensuite le dossier **/run/php** qui est nécéssaire au fonctionnement.
On copie nos fichiers de config dans le conteneur, puis on ouvre le port 9000 (port wordpress par default).

Enfin, on lance un script via la commande **CMD**, qui le mettra en PID 1.

**/!\ Si le PID 1 d'un conteneur s'arrete, le conteneur s'arrete également.** 

### Fichiers de config wordpress

- **conf/www.conf** : Un fichier de configuration qui est généré par la première installation de wordpress qu'on récupère et modifie a notre guise. (la seule modification faite est ligne 37. On donne le nom du conteneur où wordpress tourne, et le port)

- **script.sh**: Un script de téléchargement de wordpress, qui télécharge, installe et modifie certains fichiers de configuration généré (nottement pour configurer la bdd).

## MariaDB

Meme procédé; Le dockerfile créer le docker sous débian, installe les utilitaire maraiDB, copie les fichiers de config et lance un script de configuration.

## Nginx

Le dockerfile créer le conteneur sous débian etc... Créer les certificats pour l'https, et lance **daemon off** (sinon, nginx n'est pas en PID 1, et le conteneur s'arrete.)

**conf/default**:
```
server {
	listen 443 ssl default_server;                          // écoute sur port https
	listen [::]:443 ssl default_server;

	ssl_protocols TLSv1.2 TLSv1.3;                          // utilise tls 1.2 ou 1.3
	ssl_certificate /etc/nginx/ssl/bgaertne.crt;            // certificat et clé ssl
	ssl_certificate_key /etc/nginx/ssl/bgaertne.key;

	root /var/www/html;                                     // racine wordpress

	index index.php index.html index.htm index.nginx-debian.html;    // liste des indexes

	server_name bgaertne.42.fr;                             

	location / {
		try_files $uri $uri/ =404;                      // trouve les fichiers a la racine,
	}                                                       // sinon, envoie une 404

	location ~ \.php$ {
		include snippets/fastcgi-php.conf;              // chemin vers php
		fastcgi_pass wordpress:9000;
	}

}
```

Derniere chose; pour pouvoir atterir sur le wordpress en tapant **login.42.fr**, il faut aussi modifier le fichier **/etc/hosts** et ajouter la redirection.



