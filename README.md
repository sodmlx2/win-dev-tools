# win-docker-intro
Example of .ps1 script to install docker utils on Windows Plataform and install Portainer platform.

## testing with portainer image.
* remove ALL schema portainer.
```
docker rm -f portainer              
docker rmi portainer/portainer-ce   
docker volume rm portainer_data
```
