import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Ждем, пока система создаст стандартное меню
    if let mainMenu = NSApp.mainMenu {
        // Список названий пунктов, которые нужно удалить (локализованные имена)
        // В английской системе это "Edit", "View", "Window", "Help"
        let titlesToRemove = ["Edit", "View", "Help", "Правка", "Вид", "Справка"]
        
        for item in mainMenu.items {
            if titlesToRemove.contains(item.title) {
                mainMenu.removeItem(item)
            }
        }
        
        // Альтернативный способ по индексам (если названия не подхватываются):
        // Индекс 0 - App Menu (Netcheck), 1 - File, 2 - Edit, 3 - View...
        // Удаляем с конца, чтобы индексы не смещались:
        /*
        if mainMenu.numberOfItems > 4 { mainMenu.removeItem(at: 4) } // Help
        if mainMenu.numberOfItems > 3 { mainMenu.removeItem(at: 3) } // View
        if mainMenu.numberOfItems > 2 { mainMenu.removeItem(at: 2) } // Edit
        */
    }
    
    super.applicationDidFinishLaunching(notification)
  }
}
// import Cocoa
// import FlutterMacOS

// @main
// class AppDelegate: FlutterAppDelegate {
//   override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//     return true
//   }

//   override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
//     return true
//   }
// }
