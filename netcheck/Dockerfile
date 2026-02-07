# Используем Ubuntu 24.04 для максимальной совместимости glibc
FROM mirror.gcr.io/library/ubuntu:24.04

# Отключаем интерактивные запросы при установке
ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    pkg-config cmake ninja-build clang \
    libgtk-3-dev libblkid-dev liblzma-dev libgcrypt20-dev \
    libayatana-appindicator3-dev \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем Flutter (стабильная ветка)
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"

# Принудительно скачиваем артефакты движка для Linux
# Настройка и предзагрузка
RUN flutter config --no-analytics && \
    flutter doctor && \
    flutter precache --linux

WORKDIR /app

# Копируем файлы проекта
COPY . .

# Сборка приложения
RUN flutter clean && \
    flutter pub get && \
    flutter build linux --release