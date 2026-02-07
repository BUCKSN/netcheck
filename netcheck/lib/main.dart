import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

const double windowWidth = 300;
const double windowHeight = 160;
const int checkIntervalSeconds = 5;
const Size minimumSize = Size(255, 120);
const Size maximumSize = Size(1920, 1080);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(windowWidth, windowHeight),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: "NetCheck",
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(true);
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setMinimumSize(minimumSize);
    await windowManager.setMaximumSize(maximumSize);
  });

  runApp(const NetCheckApp());
}

class NetCheckApp extends StatelessWidget {
  const NetCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NetCheckWindow(),
    );
  }
}

class NetCheckWindow extends StatefulWidget {
  const NetCheckWindow({super.key});

  @override
  State<NetCheckWindow> createState() => _NetCheckWindowState();
}

class _NetCheckWindowState extends State<NetCheckWindow> with TrayListener {
  final TextEditingController _hostController = TextEditingController();
  String _status = '';
  String _shortStatus = '';
  Color _statusColor = Colors.green;
  bool _isChecking = false;
  bool _windowVisible = true;
  bool _autoCheckEnabled = false;
  bool _isAlwaysOnTop = false;
  bool _isTextFieldFocused = false;
  Timer? _autoCheckTimer;
  String _currentAddress = '';
  final FocusNode _focusNode = FocusNode();
  
  Timer? _timerProgressTimer;
  double _timerProgress = 0.0;
  bool _timerPaused = false;

  @override
  void initState() {
    super.initState();
    
    trayManager.addListener(this);
    _hostController.text = 'ya.ru';
    
    _focusNode.addListener(() {
      setState(() {
        _isTextFieldFocused = _focusNode.hasFocus;
        if (_isTextFieldFocused) {
          _pauseTimerProgress();
        } else {
          _resumeTimerProgress();
        }
      });
    });
    
    _initTray();
    
    Future.delayed(const Duration(milliseconds: 50), () {
      _checkHost();
      _startAutoCheck();
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _timerProgressTimer?.cancel();
    trayManager.removeListener(this);
    _focusNode.dispose();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _initTray() async {
    try {
      await _updateTrayIcon();
      await _updateTrayMenu();
      await trayManager.setToolTip('NetCheck\nАдрес: $_currentAddress\nСтатус: $_status');
    } catch (e) {
      // print('Ошибка инициализации трея: $e');
    }
  }

  Future<void> _updateTrayIcon() async {
    try {
      String iconName = _statusColor == Colors.green 
          ? 'tray_icon_green' 
          : _statusColor == Colors.orange 
              ? 'tray_icon_orange' 
              : 'tray_icon_red';
      
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/images/$iconName.ico'
            : 'assets/images/$iconName.png',
      );
    } catch (e) {
      // print('Ошибка обновления иконки: $e');
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/images/tray_icon_green.ico'
            : 'assets/images/tray_icon_green.png',
      );
    }
  }

  Future<void> _updateTrayMenu() async {
    try {
      final menu = Menu(
        items: [
          MenuItem(
            key: 'exit_app',
            label: 'Закрыть',
          ),
          MenuItem.separator(),
          if (_currentAddress.isNotEmpty) ...[
            MenuItem(
              key: 'check_now',
              label: 'GO: $_currentAddress',
            )
          ],
          MenuItem.separator(),
          MenuItem(
            key: 'toggle_auto_check',
            label: _autoCheckEnabled ? 'Автопроверка: ВКЛ' : 'Автопроверка: ВЫКЛ',
          ),
          MenuItem(
            key: 'toggle_always_on_top',
            label: _isAlwaysOnTop ? 'Поверх окон: ВКЛ' : 'Поверх окон: ВЫКЛ',
          ),
          MenuItem(
            key: 'show_hide',
            label: _windowVisible ? 'Свернуть' : 'Развернуть',
          ),
        ],
      );
      
      await trayManager.setContextMenu(menu);
      await trayManager.setToolTip('NetCheck\nАдрес: $_currentAddress\nСтатус: $_shortStatus');
    } catch (e) {
      // print('Ошибка обновления меню: $e');
    }
  }

  void _startAutoCheck() {
    if (_autoCheckEnabled) {
      _autoCheckTimer?.cancel();
      _autoCheckTimer = Timer.periodic(
        const Duration(seconds: checkIntervalSeconds),
        (timer) {
          // Проверяем только если поле ввода не активно
          if (!_isTextFieldFocused) {
            _checkHost();
          }
        },
      );
      _startTimerProgress();
    } else {
      _stopTimerProgress();
    }
  }

  void _stopAutoCheck() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = null;
    _stopTimerProgress();
  }

  void _toggleAutoCheck() {
    setState(() {
      _autoCheckEnabled = !_autoCheckEnabled;
    });
    
    if (_autoCheckEnabled) {
      _startAutoCheck();
      _checkHost();
    } else {
      _stopAutoCheck();
    }
    
    _updateTrayMenu();
  }

  void _toggleAlwaysOnTop() async {
    setState(() {
      _isAlwaysOnTop = !_isAlwaysOnTop;
    });
    
    await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
    _updateTrayMenu();
  }

  void _minimizeToTray() async {
    await windowManager.minimize();  // Стандартное сворачивание вместо hide()
    setState(() {
      _windowVisible = false;
    });
    _updateTrayMenu();
  }

  void _startTimerProgress() {
    _timerProgressTimer?.cancel();
    _timerProgress = 0.0;
    _timerPaused = false;
    
    _timerProgressTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (!_timerPaused) {
          setState(() {
            _timerProgress += 0.1 / checkIntervalSeconds;
            if (_timerProgress >= 1.0) {
              _timerProgress = 0.0;
            }
          });
        }
      },
    );
  }

  void _stopTimerProgress() {
    _timerProgressTimer?.cancel();
    _timerProgressTimer = null;
    setState(() {
      _timerProgress = 0.0;
      _timerPaused = false;
    });
  }

  void _pauseTimerProgress() {
    if (_autoCheckEnabled && !_timerPaused) {
      setState(() {
        _timerPaused = true;
      });
    }
  }

  void _resumeTimerProgress() {
    if (_autoCheckEnabled && _timerPaused) {
      setState(() {
        _timerPaused = false;
      });
    }
  }

  // Метод для очистки адреса до вида host:port
  void _cleanupAddress() {
    final text = _hostController.text.trim();
    
    if (text.isEmpty) return;
    
    // Парсим адрес
    final parsed = _parseHostAndPort(text);
    final host = parsed['host'] ?? '';
    final port = parsed['port'] ?? '';
    
    if (host.isEmpty) return;
    
    // Формируем чистый адрес
    final cleanAddress = port.isEmpty ? host : '$host:$port';
    
    // Обновляем поле ввода только если адрес изменился
    if (text != cleanAddress) {
      _hostController.text = cleanAddress;
      _hostController.selection = TextSelection.fromPosition(
        TextPosition(offset: cleanAddress.length),
      );
    }
  }

  Future<void> _checkHost() async {
    // Запускаем таймер сразу при начале проверки
    if (_autoCheckEnabled) {
      _startTimerProgress();
    }
    
    // Очищаем адрес только если поле ввода не активно
    if (!_isTextFieldFocused) {
      _cleanupAddress();
    }
    
    final text = _hostController.text.trim();
    
    if (text.isEmpty) return;
    
    setState(() {
      _isChecking = true;
      _status = 'Проверяем...';
      _shortStatus = 'Проверка...';
    });

    // Парсим адрес для извлечения хоста и порта
    final parsed = _parseHostAndPort(text);
    final host = parsed['host'] ?? '';
    final port = parsed['port'] ?? '';
    
    if (host.isEmpty) {
      setState(() {
        _status = '❌ Неверный адрес';
        _shortStatus = '❌ Ошибка';
        _statusColor = Colors.red;
        _isChecking = false;
      });
      await _updateTrayIcon();
      await _updateTrayMenu();
      return;
    }
    
    final portInt = int.tryParse(port) ?? 0;
    _currentAddress = portInt == 0 ? host : '$host:$portInt';

    try {
      bool isUp;
      
      if (portInt == 0) {
        isUp = await _pingHost(host);
        _status = '✅ $host';
        _shortStatus = '✅ $host';
      } else {
        isUp = await _checkPort(host, portInt);
        _status = '✅ $host:$portInt';
        _shortStatus = '✅ $host:$portInt';
      }
      
      setState(() {
        _statusColor = isUp ? Colors.green : Colors.orange;
        if (!isUp) {
          _status = _status.replaceFirst('✅', '⚠️');
          _shortStatus = _shortStatus.replaceFirst('✅', '⚠️');
        }
      });
      
    } catch (e) {
      setState(() {
        _status = '❌ Ошибка';
        _shortStatus = '❌ Ошибка';
        _statusColor = Colors.red;
      });
    }

    setState(() {
      _isChecking = false;
    });

    await _updateTrayIcon();
    await _updateTrayMenu();
  }

  Map<String, String> _parseHostAndPort(String input) {
    final result = {'host': input, 'port': ''};
    
    try {
      final cleanInput = input.trim();
      
      final ipPortMatch = RegExp(r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?::(\d{1,5}))?$').firstMatch(cleanInput);
      if (ipPortMatch != null) {
        result['host'] = ipPortMatch.group(1)!;
        if (ipPortMatch.group(2) != null) {
          result['port'] = ipPortMatch.group(2)!;
        }
        return result;
      }
      
      if (cleanInput.contains('://') || cleanInput.contains('@') || cleanInput.contains('/')) {
        String uriString = cleanInput;
        if (!cleanInput.contains('://')) {
          uriString = 'http://$cleanInput';
        }
        
        final uri = Uri.tryParse(uriString);
        if (uri != null && uri.host.isNotEmpty) {
          result['host'] = uri.host;
          
          if (uri.hasPort) {
            result['port'] = uri.port.toString();
          }
        }
      } else if (cleanInput.contains(':')) {
        final parts = cleanInput.split(':');
        if (parts.length == 2) {
          final portCandidate = parts[1];
          if (RegExp(r'^\d{1,5}$').hasMatch(portCandidate)) {
            result['host'] = parts[0];
            result['port'] = portCandidate;
          }
        }
      }
    } catch (e) {
      // print('Ошибка парсинга адреса: $e');
    }
    
    return result;
  }

  Future<bool> _pingHost(String host) async {
    try {
      final result = await Process.run('ping', 
          Platform.isWindows ? ['-n', '1', '-w', '2000', host] : ['-c', '1', '-W', '2', host]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkPort(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, 
          timeout: const Duration(seconds: 3));
      socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Обработчик нажатия клавиши Enter
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (!_isTextFieldFocused) {
        _checkHost();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {}

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_hide':
        if (_windowVisible) {
          windowManager.minimize();  // Стандартное сворачивание вместо hide()
          setState(() {
            _windowVisible = false;
          });
        } else {
          windowManager.show();
          windowManager.focus();
          windowManager.setMinimumSize(minimumSize);
          windowManager.setMaximumSize(maximumSize);
          setState(() {
            _windowVisible = true;
          });
        }
        _updateTrayMenu();
        break;
      case 'toggle_auto_check':
        _toggleAutoCheck();
        break;
      case 'toggle_always_on_top':
        _toggleAlwaysOnTop();
        break;
      case 'check_now':
        _checkHost();
        break;
      case 'exit_app':
        windowManager.close();
        break;
    }
  }

  // Виджет для индикатора таймера
  Widget _buildTimerIndicator(double scale) {
    return Container(
      height: 2.0,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: _timerPaused ? 0.2 : 0.3),
        borderRadius: BorderRadius.circular(1.0),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _timerProgress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withValues(alpha: _timerPaused ? 0.4 : 0.6),
                Colors.white.withValues(alpha: _timerPaused ? 0.6 : 1.0),
                Colors.white.withValues(alpha: _timerPaused ? 0.4 : 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(1.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      resizeEdgeSize: 8,
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              color: _statusColor,
              border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
              // Скругляем окошко
              borderRadius: BorderRadius.circular(4),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => windowManager.startDragging(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final currentWidth = constraints.maxWidth;
                  final currentHeight = constraints.maxHeight;
                  
                  final widthScale = currentWidth / windowWidth;
                  final heightScale = currentHeight / windowHeight;
                  
                  final uniformScale = widthScale < heightScale ? widthScale : heightScale;
                  final scale = uniformScale.clamp(0.8, 2.0);
                  
                  const headerHeight = 30.0;
                  
                  return Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: headerHeight,
                            child: Stack(
                              children: [                            
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _minimizeToTray,
                                            child: const Center(
                                              child: Icon(
                                                Icons.minimize,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _toggleAlwaysOnTop,
                                            child: Center(
                                              child: Icon(
                                                _isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => windowManager.close(),
                                            child: const Center(
                                              child: Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                                
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _shortStatus,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          Expanded(
                            child: Container(
                              width: currentWidth,
                              padding: EdgeInsets.fromLTRB(12 * scale, 0, 12 * scale, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Поле ввода
                                  SizedBox(
                                    height: 36 * scale,
                                    child: TextField(
                                      controller: _hostController,
                                      focusNode: _focusNode,
                                      onSubmitted: (_) {
                                        // Очищаем и проверяем при нажатии Enter в поле
                                        _cleanupAddress();
                                        _checkHost();
                                      },
                                      onTapOutside: (_) {
                                        _focusNode.unfocus();
                                      },
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14 * scale,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'IP/host или URL',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12 * scale,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: const OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12 * scale,
                                          vertical: 8 * scale,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Переключатель автопроверки
                                  Column(
                                    children: [
                                      Container(
                                        height: 34 * scale,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.2),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12 * scale,
                                          vertical: 6 * scale,
                                        ),
                                        child: Row(
                                          children: [
                                            Transform.scale(
                                              scale: 0.9 * scale,
                                              child: Switch(
                                                value: _autoCheckEnabled,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _autoCheckEnabled = value;
                                                  });
                                                  if (value) {
                                                    _startAutoCheck();
                                                    _checkHost();
                                                  } else {
                                                    _stopAutoCheck();
                                                  }
                                                },
                                                activeThumbColor: Colors.white,
                                                activeTrackColor: Colors.black.withValues(alpha: 0.3),
                                                inactiveThumbColor: Colors.grey,
                                                inactiveTrackColor: Colors.black.withValues(alpha: 0.1),
                                              ),
                                            ),
                                            SizedBox(width: 12 * scale),
                                            Expanded(
                                              child: Text(
                                                'Автопроверка ($checkIntervalSeconds сек)',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14 * scale,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Индикатор таймера (над кнопкой)
                                  _buildTimerIndicator(scale),
                                  
                                  // Кнопка проверки
                                  SizedBox(
                                    height: 32 * scale,
                                    child: ElevatedButton(
                                      onPressed: _isChecking ? null : () {
                                        // Всегда очищаем адрес при нажатии кнопки
                                        _cleanupAddress();
                                        _checkHost();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black.withValues(alpha: 0.3),
                                        foregroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _isChecking ? '⏳ Проверка...' : 'Проверить сейчас',
                                          style: TextStyle(
                                            fontSize: 14 * scale,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}