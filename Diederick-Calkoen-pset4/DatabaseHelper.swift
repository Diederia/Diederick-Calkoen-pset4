//
//  DatabaseHelper.swift
//  Diederick-Calkoen-pset4
//
//  Created by Diederick Calkoen on 22/11/16.
//  Copyright © 2016 Diederick Calkoen. All rights reserved.
//

import Foundation
import SQLite

class DatabaseHelper {
    
    private let users = Table("users")
    private let id = Expression<Int64>("id")
    private let toDo = Expression<String?>("toDo")
    private let checked = Expression<Bool>("checked")
    
    private var db: Connection?
    
    init?() {
        do {
            try setupDatabase()
        } catch {
            print(error)
            return nil
        }
    }
    
    private func setupDatabase() throws {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
            try createTable()
        } catch {
            throw error
        }
    }
    
    private func createTable() throws {
        do {
            try db!.run(users.create(ifNotExists: true) {
                t in
                
                t.column(id, primaryKey: .autoincrement)
                t.column(toDo, unique: true)
                t.column(checked)
            })
        } catch {
            throw error
        }
    }
    
    func create(ToDo: String) throws {
        
        let insert = users.insert(self.toDo <- ToDo, self.checked <- false)
        
        do {
            let rowId = try db!.run(insert)
            print("done with creating:", rowId)
        } catch {
            throw error
        }
    }
    
    func read() throws -> Array<String> {
        
        var result = Array<String>()
        
        do {
            for item in try db!.prepare(users) {
                result.append(item[toDo]!)
            }
        } catch {
            throw error
        }
        return result
    }    
    
    func readCompleted() throws -> Array<Bool> {
        
        var result = Array<Bool>()
        
        do {
            for item in try db!.prepare(users) {
                result.append(item[checked])
            }
        } catch {
            throw error
        }
        return result
    }
    
    func delete(toDoName: String, checked: Bool) throws {
        let deleteRow = users.filter(toDo == toDoName)

        do {
            let numDeleteRow = try db!.run(deleteRow.delete())
            
            print("Done with deleting:", numDeleteRow)
        } catch {
            throw error
        }
    }
    
    func update(toDoName: String, checked: Bool) throws {
        let updateRow = users.filter(toDo == toDoName)
        do {
            let numUpdateRow = try db!.run(updateRow.update())
            print("Done with Updating:", numUpdateRow)
        } catch {
            throw error
        }
    }
}
