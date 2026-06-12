import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "EventerMobile")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Erro crítico ao carregar CoreData: \(error)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Erro ao salvar CoreData: \(error)")
            }
        }
    }
}
