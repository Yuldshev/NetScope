import SwiftUI

@main
struct NetScopeApp: App {
  let coreDataStack = CoreDataStack.shared
  
  var body: some Scene {
    WindowGroup {
      EmptyView()
        .environment(\.managedObjectContext, coreDataStack.viewContext)
    }
  }
}
