//
//  TodoListViewController.swift
//  TodoListExample
//
//  Created by Jesus Jaime Cano Terrazas on 24/07/21.
//

import UIKit

class TodoListViewController: BaseViewController {
    
    private var dataSource: [ToDoItem] = []
    private var isDetailActive: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = CoreDataManager.sharedInstance.readWithGeneric(className: ToDoItem.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isDetailActive = UserDefaults.standard.bool(forKey: "DETAIL_ACTIVE")
        
        tableView.reloadData()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateToDoViewController" {
            let createToDoViewController = segue.destination as! CreateToDoViewController
            
            if let itemToEdit = sender as? ToDoItem {
                createToDoViewController.toDoItemToEdit = itemToEdit
            }
            // 4
            createToDoViewController.delegate = self
        }
    }
    
    // MARK: - Private Methods
    
    private  func createDummyData() {
        let todoDict: [String: Any] = [
            "title" : "Estudiar Swift",
            "notes" : "Buscar ejemplos de Swift y repasarlos",
            "done" : false
        ]
        
        let todoDict2: [String: Any] = [
            "title" : "Comprar barritas",
            "notes" : "Barritas de fruta para el desayuno",
            "done" : true
        ]
        
        
        let todoDict3: [String: Any] = [
            "title" : "Comprar el pizarrón",
            "notes" : "Buscar un pizarrón portatil para el curso",
            "done" : false
        ]
        
        let todos = [
            "todos" : [todoDict, todoDict2, todoDict3]
        ]
        
        self.writeDictToJSON(dict: todos, fileName: "todos.json")
    }
    
    private func writeDictToJSON(dict: [String: Any], fileName: String) {
        
        let data = try! JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        let jsonString = String(data: data, encoding: .utf8)
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        guard let path = paths.first else { return }
        let completePath = path.appending("/\(fileName)")
        
        do {
            try jsonString?.write(toFile: completePath, atomically: true, encoding: .utf8)
        } catch let error {
            print("Write Error: \(error.localizedDescription)")
        }
        
    }
    
    private func readJSONToDict(fileName: String) -> [String: Any]? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        guard let path = paths.first else { return nil }
        let completePath = path.appending("/\(fileName)")
        
        do {
            let jsonString = try String(contentsOfFile: completePath, encoding: .utf8)
            
            if let data = jsonString.data(using: .utf8) {
                let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                return dic
            }
            
            return nil
        } catch let error {
            print("Reading error: \(error.localizedDescription)")
            
            return nil
        }
        
    }
    
    // MARK: - User Interface
    
    @IBAction func createNewToDoItem(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "CreateToDoViewController", sender: nil)
    }
    

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isDetailActive {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemDetailTableViewCell") as! TodoItemDetailTableViewCell
            cell.todoItem = dataSource[indexPath.row]
            
            return cell
            
//            returning an empty table view
//            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemTableViewCell") as! TodoItemTableViewCell
            cell.todoItem = dataSource[indexPath.row]
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemToSend = self.dataSource[indexPath.row]
        
        performSegue(withIdentifier: "CreateToDoViewController", sender: itemToSend)
    }
    
    
    // To allow delete
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete from DataBase")
            
            let todoItem = self.dataSource[indexPath.row]
            let context = CoreDataManager.sharedInstance.persistentContainer.viewContext
            
            context.delete(todoItem)
            CoreDataManager.sharedInstance.saveContext()
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    
}


// 3

// MARK: - CreateTodoDelegate

extension TodoListViewController: CreateTodoDelegate {
    
    // Aqui es donde recibimos el ToDo creado en la pantalla de creación
    func createTodoDidCreate(todoItem: ToDoItem) {
        print("ToDo received: \(todoItem.title)")
        dataSource.append(todoItem)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
