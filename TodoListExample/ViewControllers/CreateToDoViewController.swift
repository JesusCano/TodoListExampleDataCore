//
//  CreateToDoViewController.swift
//  TodoListExample
//
//  Created by Jesus Jaime Cano Terrazas on 31/07/21.
//

import UIKit

/*
 1) Declaramos nuestro protocolo
 2) Declaramos una variable llamada 'delegate' del tipo del protocolo en la clase desde donde vamos a enviar los datos
 3) Implementamos el protocolo en la clase en la que vamos a recibir los datos
 4) Asignamos la variable 'delegate' en el prepareForSegue de la clase que va a recibir los datos
 5) Mandamos los datos a través de la variable 'delegate' desde la clase que los contiene
 */


// 1
protocol CreateTodoDelegate: AnyObject {
    func createTodoDidCreate(todoItem: ToDoItem)
}

class CreateToDoViewController: BaseViewController {
    
    // 2
    weak var delegate: CreateTodoDelegate?
    var toDoItemToEdit: ToDoItem?
    var actionToDo: String = "CREATE"
    
    @IBOutlet weak var newTaskBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    private var selectedColor = UIColor.lightGray
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // With thhis thing, we know that this class will subscribe to the keyboard notifications
        manageKeyboard = true
        
        if let name = self.toDoItemToEdit?.title {
            print("Exists ToDoItem: \(name)")
            self.setData()
            self.actionToDo = "UPDATE"
        }
        
    }
    
    // MARK: - Private Methods
    
    private func setData() {
        self.titleTextField.text = self.toDoItemToEdit?.title
        self.notesTextField.text = self.toDoItemToEdit?.notes
        self.colorButton.backgroundColor = self.toDoItemToEdit?.color as! UIColor
        self.selectedColor = self.toDoItemToEdit?.color as! UIColor
        self.actionButton.setTitle("UPDATE", for: .normal)
    }
    
    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectColorViewController" {
            let selectColorViewController = segue.destination as! SelectColorViewController
            
            // 4
            selectColorViewController.delegate = self
        }
    }
    
    
    // MARK: - Keyboard
    
    override func keyboardWillShow(notification: Notification) {
        print("Se presenta el teclado")
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            let keyboardFrame = keyboardSize.cgRectValue
            
            self.newTaskBottonConstraint.constant = keyboardFrame.height - view.safeAreaInsets.bottom
            
            let animationTime = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            UIView.animate(withDuration: animationTime) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func keyboardWillHide(notification: Notification) {
        print("Se oculta el teclado")
        
        if let userInfo = notification.userInfo {
            self.newTaskBottonConstraint.constant = 0
            
            let animationTime = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            
            UIView.animate(withDuration: animationTime) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - User interaction
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        guard let title = titleTextField.text else { return }
        guard let notes = notesTextField.text else { return }
        
//        let todoItem = ToDoItem(title: title, notes: notes, done: false, color: selectedColor)
        
        if self.actionToDo == "UPDATE" {
            self.toDoItemToEdit?.title = title
            self.toDoItemToEdit?.notes = notes
            self.toDoItemToEdit?.color = self.selectedColor
            CoreDataManager.sharedInstance.saveContext()
            navigationController?.popViewController(animated: true)
        } else {
            let context = CoreDataManager.sharedInstance.persistentContainer.viewContext
            let todoItem = ToDoItem(context: context)
            todoItem.title = title
            todoItem.color = selectedColor
            todoItem.done = false
            todoItem.notes = notes
            
            // 5
            delegate?.createTodoDidCreate(todoItem: todoItem)
            CoreDataManager.sharedInstance.saveContext()
        }
        
    }
    
}

// MARK: - SelectColorDelegate

extension CreateToDoViewController: SelectColorDelegate {
    func colorSelected(color: UIColor) {
        print("Colo: \(color)")
        self.selectedColor = color
        colorButton.backgroundColor = color
        navigationController?.popViewController(animated: true)
    }
    
}
