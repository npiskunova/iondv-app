# Сборка в docker

## Установка docker
*Желательно делать не под root*

### Для CentOS

Установка последней версии docker:
```
sudo yum -y install docker-ce docker-ce-cli containerd.io
```

Добавляем текущего пользователя в группу docker:
```
sudo groupadd docker
sudo usermod -aG docker $USER
```

### Для Ubuntu

Установка последней версии docker:
```
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

#### Проверка

Проверить можно `docker run hello-world`

## Запуск Mongo в докере

Запускаем с маппингом на локальный порт:
```
docker run -p 27017:27017 mongo:latest
```

## Установка node

```
docker pull node:10
```
