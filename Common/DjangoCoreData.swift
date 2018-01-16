//
//  DjangoCoreData.swift
//  DjangoSwift
//
//  Created by Michael Schloss on 12/13/17.
//  Copyright © 2017 Michael Schloss. All rights reserved.
//

import Foundation
import CoreData

public class DjangoCoreData
{
    public static let shared = DjangoCoreData()
    
    private var persistentContainer : NSPersistentContainer?
    public private(set) var managedObjectContext : NSManagedObjectContext?
    
    private init() { }
    
    func loadStore(withName name: String)
    {
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error
            {
                print("There's been an error loading the container! Error Details: \(error)")
            }
            else
            {
                self.managedObjectContext = container.viewContext
            }
        })
        persistentContainer = container
    }
}
