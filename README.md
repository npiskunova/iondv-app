# iondv-app
IONDV. Framework apps installer


Usage: 
```
iondv-app [OPTION]... IONDV_APP_NAME_OR_GIT_URL'
 Install IONDV. Framework application to current dirrectory and create docker image.

Options:'
  -d                          stop, remove runnig app docker container and image,
                              create and run new once
  -l [value]                  mongodb docker name, for link with app docker container
                              (also set mongo uri value to [value]:27017)
  -k                          skip check
  -s [value]                  script to run after install and before build app
  -m [value]                  mongo uri, for example: mongodb:27017. Default localhost:27017
```

Example. Install and start app `khv-ticket-discount` with link docker mongodb

```
./iondv-app -d -l mongodb khv-ticket-discount
```

Example: Install app with link to git and mongo uri'
```
./iondv-app -m localhost:27017 https://git.iondv.ru/ION-METADATA/khv-svyaz-info.git'
```