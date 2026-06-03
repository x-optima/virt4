#script.sh
#!/bin/bash

# Проверить сборку
docker build -f Dockerfile.python -t shvirtd-python:latest .

# Проверить размер
docker images | grep shvirtd-python

# Запустить без БД (он просто не сможет подключиться, но запустится)
docker run -d -p 5000:5000 --name my-app shvirtd-python:latest

# Проверить, что контейнер запущен
docker ps | grep my-app

# Посмотреть логи
docker logs my-app

# Остановить
docker stop my-app && docker rm my-app