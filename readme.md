# ajouter l'utilisateur aux sudoers
sudo visudo
# ajouter comme ceci :
# User privilege specification
root	ALL=(ALL:ALL) ALL
login	ALL=(ALL:ALL) ALL

# update les packages
sudo apt-get update

# installer vim, git, ssh, make, docker.io et docker-compose
sudo apt-get install vim openssh-server git make docker.io docker-compose

# trouver l'ip de la vm
ip addr show
# 2: enp0s3 inet /IP/

# eteindre VM, ajouter une redirection de port :
settings VM -> reseau -> advanced -> redirection de port
Ajouter une redirection :
nom: ssh
protocole: TCP
ip hote: /
port hote: 2222
ip invite: ip de VM 
port invite: 22

# generer la clef ssh (pour github)
ssh-keygen

# connexsion ssh depuis hote
ssh -p 2222 login@127.0.0.1
# tranferer un fichier par ssh (depuis hote)
scp -P 2222 chemin-du-fichier login@127.0.0.1:/home/login/Desktop

###  docker commands:
sudo docker ps -a
sudo docker images -a	
sudo docker rm {container}
sudo docker rmi {image}
sudo docker build -t {image name}
sudo docker run -d -p 443:443 --name {container name} {image name}
sudo docker stop {container}
sudo docker start {container}
# copier un fichier d'un container vers l'hote
sudo docker cp {container}:{chemin du fichier} {chemin cible}
exemple ->
sudo docker cp wp-php:/etc/php/7.4/fpm/pool.d/www.conf ./requirements/wordpress

### docker-compose commands:
sudo docker-compose up --build

## makefile rules :
all : creates and runs all docker containers for the project
clean : stops and deletes all docker containers, images, volumes and networks
fclean : deletes wordpress and database data
list : lists all containers, images, and networks

## docker-compose.yml
File used by the command docker-compose to build all containers according to listed parameters:
3 containers : nginx, wordpress, mariadb
build: location of the files of each container
volumes: host-side files used by containers to store data
network: containers are isolated from everything, so we connect them together.
env-file: all env variables we pass here will be exported in the container's env



