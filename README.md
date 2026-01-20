# inception_docker_42_project

This is a 42 curriculum project where you learn to use a Docker, nginx and setup a basic Wordpress site in low level fashion. Instead of using ready images the student needs to build the scripts etc from scratch as well as deal with
fire permissions when persistent data from container is mapped to hard drive. As we dont have enough rights on the school computers we also need to put it inside a virtual machine. 

The hardest part for me personally was debugging the interactions with wordpress, nginx, mariadb, Docker and VM as there are so many unknown parts interacting and it is hard to tell which part is broken. I also learned how to make the hostname resolution happen on the VM side using SOCKS v5 connection to VM. 

# TL;DR Quickstart


make       # build and start the stack
# open https://localhost:8443 in your browser
make fclean  # full cleanup (containers + data + .env)
Inception Dockerized WordPress + MariaDB + Nginx
This repository contains a Dockerized WordPress environment with MariaDB and Nginx. It is designed to run without root privileges on the host and supports persistent data storage in the data/ folder.

Quick Start
Build and start the stack:
``` bash
make

```
This will:

Create a default unsafe .env file at ./srcs/.env (if missing)

Prepare persistent data/mariadb and data/wordpress folders

Build and run Docker containers for WordPress, MariaDB, and Nginx

Expose WordPress at: https://localhost:8443

Default Credentials
The default passwords are unsafe if you did not provide an .env file:

User	Password	Role
siteboss	unsafe	WordPress admin
writer	unsafe	WordPress author
MariaBoss	unsafe	MariaDB admin
myMariaDB	unsafe	MariaDB database

Note: These passwords come from the default .env file if it doesn’t exist. You can safely modify .env before the first make run to use your own credentials.

Notes / Limitations
Port Mapping: This setup assumes that port 8443 is free on your host. If you want to use a different port, update the WP_HOME and WP_SITEURL environment variables in .env and the Nginx configuration accordingly.

Localhost Only: The stack is configured to run only on localhost. Changing it to a public hostname requires modifying Nginx and WordPress configuration.

No Host Root Needed: All Docker volumes and persistent data are cleaned safely using containers. You do not need sudo to run make fclean.

Persistent Data: All MariaDB and WordPress data is stored in the data/ folder. Removing data/ via make fclean or Docker ensures a clean start.

WordPress HTTPS: WordPress is forced to HTTPS internally using port 8443 ($_SERVER['HTTPS'] = 'on') for compatibility with the Dockerized Nginx setup.

Makefile Targets
Target	Description
make or make all	Build and run the stack
make run	Start containers only
make clean	Stop containers, remove Docker artifacts, keep persistent data and .env
make fclean	Stop containers, remove Docker artifacts, persistent data, and .env (full cleanup)
make re	Full rebuild from scratch (fclean + make all)

Recommended Usage
First-time setup:


make
Access WordPress:

https://localhost:8443
Rebuild or reset the environment:


make fclean   # full cleanup
make          # rebuild
TL;DR
Run make → build and start stack

Go to https://localhost:8443 → WordPress ready

Default credentials = unsafe for .env users and DB users

make fclean → full cleanup including persistent data

Designed for localhost + port 8443, rootless on host
