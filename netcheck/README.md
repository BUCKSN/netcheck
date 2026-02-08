# 🌐 NetCheck

**A simple yet powerful network availability checker for desktops**

## ✨ Features

- **🔍 Real-time Network Monitoring** - Instantly check connectivity to any host or IP address
- **🔄 Auto-Check Mode** - Automatically verify network status at customizable intervals
- **🔔 System Tray Integration** - Runs minimized in system tray with visual status indicators
- **📱 Clean, Modern UI** - Beautiful Flutter-based interface with smooth animations
- **🎯 Flexible Address Input** - Supports IP addresses, hostnames, URLs with port specification
- **🧠 Automatic Layout Correction for IP Input** - The program automatically detects and corrects Russian keyboard layout errors when entering IP addresses.
- **📊 Visual Progress Indicators** - Animated timer and status bars for intuitive monitoring
- **🔝 Always on Top** - Optional window pinning for constant visibility
- **🖱️ Drag & Resize** - Fully resizable window with smooth dragging support

## 🚀 Quick Installation

## Linux
```bash
sh -ci "$(curl -fsSL https://raw.githubusercontent.com/BUCKSN/netcheck/main/release/install.sh)"
```
### 🗑️ Uninstallation

To completely remove NetCheck from your system:

```bash
sudo rm -rf /usr/local/bin/netcheck
rm -rf $HOME/.local/share/netcheck
rm -rf $HOME/.local/share/applications/netcheck.desktop
rm -rf $HOME/.local/share/icons/hicolor/32x32/apps/netcheck.png
```
## Windows
[netcheck.zip](https://raw.githubusercontent.com/BUCKSN/netcheck/main/release/netcheck.zip)

## MacOs
[netcheck_installer.dmg](https://raw.githubusercontent.com/BUCKSN/netcheck/main/release/netcheck_installer.dmg)

## 📖 Usage

1. **Launch NetCheck** from your application menu or run `netcheck`
2. **Enter a target address** in the input field (IP, hostname, or URL)
3. **Click "Check Now"** or press Enter to perform an immediate check
4. **Enable Auto-Check** to monitor connectivity automatically every 5 seconds
5. **Minimize to tray** to keep monitoring running without cluttering your desktop

### How It Checks
- **Without port** (e.g., `google.com`, `192.168.1.1`) - Performs ICMP ping to check host availability
- **With port** (e.g., `google.com:443`, `192.168.1.1:8080`) - Checks specific TCP port connectivity

### Input Examples
- `google.com` - Ping check for domain availability
- `192.168.1.1` - Ping check for local router
- `8.8.8.8:53` - Check DNS port (53) connectivity
- `google.com:443` - Check HTTPS port connectivity
- `https://api.github.com` - Full URL support (automatically extracts host and port)
- `8ю8ю8ю8` → converts to 8.8.8.8
- `1ю1ю1ю1Ж8080` → correctly recognized as 1.1.1.1:8080
- `192ю168ю0ю1Ж22` → corrected to 192.168.0.1:22
- `8.8.8.8Ж53` → interpreted as 8.8.8.8:53

### Status Indicators
- **🟢 Green** - Connection successful
- **🟠 Orange** - Connection failed or timeout
- **🔴 Red** - Invalid address or critical error

## 🛠️ Requirements

- **Linux** (Ubuntu 24.04+, Debian 12+, Fedora 40+, Arch Linux)
- **Flutter Runtime** (Included, no separate install needed)
- **System Tray** (GNOME, KDE, XFCE, MATE, Cinnamon compatible)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

# 🌐 NetCheck (Русская версия)

**Простой, но мощный инструмент для проверки доступности сети для Linux**

## ✨ Возможности

- **🔍 Мониторинг сети в реальном времени** - Мгновенная проверка подключения к любому хосту или IP-адресу
- **🔄 Автоматическая проверка** - Автоматическая проверка состояния сети с настраиваемыми интервалами
- **🔔 Интеграция с системным треем** - Работает в свернутом виде в системном трее с визуальными индикаторами
- **📱 Чистый современный интерфейс** - Красивый интерфейс на основе Flutter с плавными анимациями
- **🎯 Гибкий ввод адресов** - Поддержка IP-адресов, имен хостов, URL с указанием портов
- **🧠 Автоисправление раскладки при вводе IP** - Программа автоматически распознаёт и исправляет русскую раскладку при вводе IP-адресов.
- **📊 Визуальные индикаторы прогресса** - Анимированные таймеры и индикаторы статуса
- **🔝 Поверх всех окон** - Опциональное закрепление окна для постоянной видимости
- **🖱️ Перетаскивание и изменение размера** - Полноценно изменяемое окно с поддержкой плавного перетаскивания

## 🚀 Быстрая установка

## Linux
```bash
sh -ci "$(curl -fsSL https://raw.githubusercontent.com/BUCKSN/netcheck/main/release/install.sh)"
```
## 🗑️ Удаление

Для полного удаления NetCheck из вашей системы:

```bash
sudo rm -rf /usr/local/bin/netcheck
rm -rf $HOME/.local/share/netcheck
rm -rf $HOME/.local/share/applications/netcheck.desktop
rm -rf $HOME/.local/share/icons/hicolor/32x32/apps/netcheck.png
```
## Windows
[netcheck.zip](https://raw.githubusercontent.com/BUCKSN/netcheck/main/release/netcheck.zip)

## MacOs
[netcheck_installer.dmg](https://raw.githubusercontent.com/BUCKSN/netcheck/main/release/netcheck_installer.dmg)

## 📖 Использование

1. **Запустите NetCheck** из меню приложений или выполните `netcheck`
2. **Введите целевой адрес** в поле ввода (IP, имя хоста или URL)
3. **Нажмите "Проверить сейчас"** или Enter для немедленной проверки
4. **Включите Автопроверку** для автоматического мониторинга каждые 5 секунд
5. **Сверните в трей** для продолжения мониторинга без загромождения рабочего стола

### Как происходит проверка
- **Без порта** (например, `google.com`, `192.168.1.1`) - Выполняется ICMP ping для проверки доступности хоста
- **С портом** (например, `google.com:443`, `192.168.1.1:8080`) - Проверяется доступность конкретного TCP порта


### Примеры ввода

- `google.com` - Проверка доступности домена через ping
- `192.168.1.1` - Проверка доступности локального роутера через ping
- `8.8.8.8:53` - Проверка доступности DNS порта (53)
- `google.com:443` - Проверка доступности HTTPS порта
- `https://api.github.com` - Полная поддержка URL (автоматически извлекает хост и порт)
- `8ю8ю8ю8` → преобразуется в 8.8.8.8
- `1ю1ю1ю1Ж8080` → корректно определится как 1.1.1.1:8080
- `192ю168ю0ю1Ж22` → исправится до 192.168.0.1:22
- `8.8.8.8Ж53` → будет интерпретировано как 8.8.8.8:53

### Индикаторы статуса
- **🟢 Зеленый** - Подключение успешно
- **🟠 Оранжевый** - Подключение не удалось или таймаут
- **🔴 Красный** - Неверный адрес или критическая ошибка

## 🛠️ Требования

- **Linux** (Ubuntu 24.04+, Debian 12+, Fedora 40+, Arch Linux)
- **Среда Flutter** (Включена, не требует установки)
- **Системный трей** (Совместимо с GNOME, KDE, XFCE, MATE, Cinnamon)

## 📄 Лицензия

Этот проект лицензирован под лицензией MIT - подробности в файле [LICENSE](LICENSE).