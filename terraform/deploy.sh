#!/usr/bin/env bash
# Прерываем выполнение при ошибке, обращении к несуществующей переменной или падении команды в pipe
set -euo pipefail

# URL репозитория можно передать первым аргументом, иначе берется значение по умолчанию
REPO_URL="${1:-https://github.com/x-optima/virt4.git}"

# Ветка может быть передана вторым аргументом, по умолчанию main
BRANCH="${2:-main}"

# Имя каталога вычисляется из URL репозитория
REPO_DIR="/opt/$(basename -s .git "$REPO_URL")"

# Создаем /opt, если его еще нет.
sudo mkdir -p /opt

# Если репозиторий еще не клонировался — делаем clone
if [ ! -d "$REPO_DIR/.git" ]; then
  sudo git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
else
  # Иначе обновляем локальную копию
  sudo git -C "$REPO_DIR" fetch --all
  sudo git -C "$REPO_DIR" checkout "$BRANCH"
  sudo git -C "$REPO_DIR" reset --hard "origin/$BRANCH"
fi

# Переходим в каталог проекта
cd "$REPO_DIR"

# Поддерживаем стандартные имена compose-файлов
if [ -f compose.yaml ] || [ -f compose.yml ] || [ -f docker-compose.yml ]; then
  sudo docker compose up -d --build
else
  echo "Compose file not found in $REPO_DIR"
  exit 1
fi

# Показываем список контейнеров после запуска
sudo docker ps -a