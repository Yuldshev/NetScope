import Foundation
import CoreData

final class CoreDataStack {
  static let shared = CoreDataStack()
  private init() {}
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "NetScope")
    
    container.loadPersistentStores { store, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return container
  }()
  
  var viewContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  func newBackgroundContext() -> NSManagedObjectContext {
    return persistentContainer.newBackgroundContext()
  }
  
  func saveContext() {
    let context = viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        print("Error saving context: \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func saveBackgroundContext(_ context: NSManagedObjectContext) {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        print("Error saving background context: \(nserror), \(nserror.userInfo)")
      }
    }
  }
}

