import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    self.setFrame(self.frame, display: true)

    self.alphaValue = 0.0
    // Вместо удаления масок, просто скрываем визуальные элементы
    // Это не ломает работу плагина window_manager
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    
    // Скрываем кнопки через альфа-канал или isHidden, но не удаляем их из styleMask
    self.standardWindowButton(.closeButton)?.isHidden = true
    self.standardWindowButton(.miniaturizeButton)?.isHidden = true
    self.standardWindowButton(.zoomButton)?.isHidden = true

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
    // Это ключевой момент для новых macOS: 
    // Настраиваем кнопки после того, как окно полностью инициализировано
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        if let closeButton = self.standardWindowButton(.closeButton) {
            closeButton.isHidden = true
        }
        if let miniaturizeButton = self.standardWindowButton(.miniaturizeButton) {
            miniaturizeButton.isHidden = true
        }
        if let zoomButton = self.standardWindowButton(.zoomButton) {
            zoomButton.isHidden = true
        }
    }
}
// import Cocoa
// import FlutterMacOS

// class MainFlutterWindow: NSWindow {
//   override func awakeFromNib() {
//     let flutterViewController = FlutterViewController()
//     let windowFrame = self.frame
//     self.contentViewController = flutterViewController
//     self.setFrame(windowFrame, display: true)

//     RegisterGeneratedPlugins(registry: flutterViewController)

//     super.awakeFromNib()
//   }
// }
