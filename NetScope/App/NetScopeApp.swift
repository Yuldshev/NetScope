import SwiftUI

@main
struct NetScopeApp: App {
  let coreDataStack = CoreDataStack.shared
  @StateObject private var coordinator = AppCoordinator()
  
  var body: some Scene {
    WindowGroup {
      ZStack {
        if coordinator.showSplash {
          SplashView()
        } else {
          ScanView()
        }
      }
        .environment(\.managedObjectContext, coreDataStack.viewContext)
    }
  }
}
