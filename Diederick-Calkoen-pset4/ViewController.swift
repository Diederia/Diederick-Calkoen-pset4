//
//  ViewController.swift
//  Diederick-Calkoen-pset4
//
//  Created by Diederick Calkoen on 19/11/16.
//  Copyright © 2016 Diederick Calkoen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var toDoArray = Array<String>()
    var completedArray = Array<Bool>()
    let db = DatabaseHelper()
    
    @IBOutlet weak var inputDataField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if db == nil {
            print("Error with database")
        }
        
        
        do {
            if let toDoDb = try db?.read() {
                let completedDb = try db?.readCompleted()
                completedArray = completedDb!
                toDoArray = toDoDb
            } else {
                completedArray = []
                toDoArray = []
            }
        } catch {
            print("Error with displaying to-do's")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToDo(_ sender: Any) {
        toDoAdding()
    }
    
    @IBAction func enterPressed(_ sender: Any) {
        toDoAdding()
    }
    func toDoAdding (){
        if inputDataField.text == "" {
            let alertController = UIAlertController(title: "No input provided", message:
                "Enter a to-do to add to the list.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        do {
            try db!.create(ToDo: inputDataField.text!)
            print ("est1")
            toDoArray = try db!.read()
            completedArray = try db!.readCompleted()
        } catch {
            print(error)
        }
        inputDataField.text = ""
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomCell
        
        cell.toDoLabel.text = toDoArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        var toDoCompleted = completedArray[indexPath.row]
        toDoCompleted = !toDoCompleted
        completedArray[indexPath.row] = toDoCompleted
//        let updateToDo = toDoArray[indexPath.row]
// werkt nog niet helemaal goed
//        do {
//            print("test1")
//            try db!.update(toDoName: updateToDo, checked: toDoCompleted)
//        } catch {
//            print("Error with updating checked status")
//        }
//        do {
//            toDoArray = try db!.read()
//            completedArray = try db!.readCompleted()
//        } catch {
//            print("Error with displaying")
//        }
        if toDoCompleted == true{
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deleteToDo = toDoArray[indexPath.row]
            let deletedCompleted = completedArray[indexPath.row]
            
            do {
                try db!.delete(toDoName: deleteToDo, checked: deletedCompleted)
            } catch {
                print("Error with deleting to-do")
            }
            
            do {
                toDoArray = try db!.read()
                completedArray = try db!.readCompleted()
            } catch {
                print("Error with displaying to-do")
            }
            tableView.reloadData()
        }
    }
}
