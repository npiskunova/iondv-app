# iondv-app
IONDV. Framework apps installer


Usage: 
```
iondv-app [OPTION]... IONDV_APP_NAME_OR_GIT_URL'
 Install IONDV. Framework application to current dirrectory and create docker image.

Options:'
  -d                          stop, remove runnig app docker container and image,
                              create and run new once
  -c [value]                  start cluster with [value] count
  -r                          remove app folder, if they exist
  -i                          import data
  -y                          yes to all
  -q                          quiet mode. Show only major and warn information
  -l [value]                  mongodb docker name, for link with app docker container
                              (also set mongo uri value to [value]:27017)
  -k                          skip check
  -s [value]                  script to run after install and before build app
  -m [value]                  mongo uri, for example: mongodb:27017. Default localhost:27017

Environment:
  IONDVUrlGitFramework       URL for get framework, default: https://github.com/iondv/framework.git'
  IONDVUrlGitModules         Base of URL for get modules, default https://github.com/iondv'
  IONDVUrlGitApp             Base of URL for get app, default https://github.com/iondv'
  IONDVUrlGitExtApp          Base of URL for get app extension, default https://github.com/iondv'
```

Example. Install and start app `khv-ticket-discount` with link docker mongodb

```
./iondv-app -d -l mongodb khv-ticket-discount
```

Example: Install app with link to git and mongo uri'
```
./iondv-app -m localhost:27017 https://git.iondv.ru/ION-METADATA/khv-svyaz-info.git'
```