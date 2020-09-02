//
//  ViewController.swift
//  Todo
//
//  Created by TaeHyeong Kim on 2020/09/03.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import Amplify
import AmplifyPlugins
import Combine
class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var todoArrayList : [Todo] = []
    
    var todoSubscription: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        subscribeTodos()
        queryTodo()
        
    }
    @IBAction func actionAddTodo(_ sender: Any) {
        let alertController = UIAlertController(title: "할일추가", message: "할일을 입력해 주세요", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "제목"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "설명"
        }
        
        let saveAction = UIAlertAction(title: "추가", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            
            if firstTextField.text != nil && secondTextField.text != nil {
                self.addTodo(firstTextField.text! , Priority.low, secondTextField.text!)
            }
        })
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func addTodo(_ title: String, _ priority: Priority,_ description: String){
        let item = Todo(id: UUID().uuidString, name: title, priority: priority, description: description)
        Amplify.DataStore.save(item) { result in
            switch result {
            case .success(let savedItem):
                print("Saved Item: \(savedItem.name)")
                self.queryTodo()
            case .failure(let error):
                print("Could not save item to dataStore: \(error)")
            }
        }
    }
    private func queryTodo() {
        Amplify.DataStore.query(Todo.self, completion: { result in
            switch(result) {
            case .success(let todos):
                todoArrayList.removeAll()
                for todo in todos {
                    todoArrayList.append(todo)
                    print("==== Todo ====")
                    print("Name: \(todo.name)")
                    if let priority = todo.priority {
                        print("Priority: \(priority)")
                    }
                    if let description = todo.description {
                        print("Description: \(description)")
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Could not query DataStore: \(error)")
            }
        })
    }
    private func updateTodo(_ title: String){
        Amplify.DataStore.query(Todo.self,
                                where: Todo.keys.name.eq(title),
                                completion: { result in
                                    switch(result) {
                                    case .success(let todos):
                                        guard todos.count == 1, var updatedTodo = todos.first else {
                                            print("Did not find exactly one todo, bailing")
                                            return
                                        }
                                        updatedTodo.name = "File quarterly taxes"
                                        Amplify.DataStore.save(updatedTodo,
                                                               completion: { result in
                                                                switch(result) {
                                                                case .success(let savedTodo):
                                                                    print("Updated item: \(savedTodo.name )")
                                                                case .failure(let error):
                                                                    print("Could not update data in Datastore: \(error)")
                                                                }
                                        })
                                    case .failure(let error):
                                        print("Could not query DataStore: \(error)")
                                    }
        })
    }
    private func deleteTodo(_ title : String){
        Amplify.DataStore.query(Todo.self,
                                where: Todo.keys.name.eq(title),
                                completion: { result in
                                    switch(result) {
                                    case .success(let todos):
                                        guard todos.count == 1, let toDeleteTodo = todos.first else {
                                            print("Did not find exactly one todo, bailing")
                                            return
                                        }
                                        Amplify.DataStore.delete(toDeleteTodo,
                                                                 completion: { result in
                                                                    switch(result) {
                                                                    case .success:
                                                                        print("Deleted item: \(toDeleteTodo.name)")
                                                                        self.queryTodo()
                                                                    case .failure(let error):
                                                                        print("Could not update data in Datastore: \(error)")
                                                                    }
                                        })
                                    case .failure(let error):
                                        print("Could not query DataStore: \(error)")
                                    }
        })
    }
    private func subscribeTodos() {
        self.todoSubscription
            = Amplify.DataStore.publisher(for: Todo.self)
                .sink(receiveCompletion: { completion in
                    print("Subscription has been completed: \(completion)")
                    self.queryTodo()
                }, receiveValue: { mutationEvent in
                    print("Subscription got this value: \(mutationEvent)")
                    self.queryTodo()
                })
    }
}
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") as? TodoCell {
            cell.selectionStyle = .none
            let item = todoArrayList[indexPath.row]
            cell.lbTitle.text = item.name
            cell.lbPriority.text = "\(item.priority ?? Priority.low)"
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = todoArrayList[indexPath.row]
        let alertController = UIAlertController(title: item.name, message: item.description, preferredStyle: UIAlertController.Style.alert)
        
        let saveAction = UIAlertAction(title: "삭제", style: UIAlertAction.Style.default, handler: { alert -> Void in
            self.deleteTodo(item.name)
        })
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
}
