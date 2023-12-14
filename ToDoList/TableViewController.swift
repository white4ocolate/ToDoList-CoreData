
import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var tasks: [Task] = []
    var selectedTasks : [Int] = []
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Please add new task", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alertController.textFields?.first
            if let newTaskTitle = textField?.text {
                self.saveTask(withTitle: newTaskTitle)
                self.tableView.reloadData()
            }
        }
        alertController.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        var alertController = UIAlertController()
        if selectedTasks.isEmpty {
            alertController = UIAlertController(title: "Clear ToDoList", message: "Are you sure you want clear ToDoList?", preferredStyle: .alert)
            let clearAction = UIAlertAction(title: "Clear", style: .default) { action in
                self.removeAllTasks()
            }
            alertController.addAction(clearAction)
        } else {
            alertController = UIAlertController(title: "Remove selected tasks", message: "Are you sure you want remove selected tasks?", preferredStyle: .alert)
            let clearAction = UIAlertAction(title: "Yes", style: .default) { action in
                self.removeSelectedTasks(tasks: self.selectedTasks)
                self.tableView.reloadData()
            }
            alertController.addAction(clearAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    private func removeSelectedTasks(tasks: [Int]) {
        let context = getContext()
        for task in tasks {
            print("task")
            print(task)
            let contextTask = self.tasks[task]
            context.delete(contextTask)
        }
        self.tasks = self.tasks.enumerated().filter{!tasks.contains($0.offset)}.map{ $0.element }
        selectedTasks.removeAll()
        do {
            try context.save()
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    private func removeAllTasks() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            for object in objects{
                context.delete(object)
                tasks.removeAll()
            }
            do {
                try context.save()
            }catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        self.tableView.reloadData()
    }
    
    private func saveTask(withTitle task: String) {
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = task
        do {
            try context.save()
            tasks.append(taskObject)
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()// request for getting all tasks
        
        /*
         // if want change sort order
         let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
         fetchRequest.sortDescriptors = [sortDescriptor ]
         */
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        cell.accessoryType = selectedTasks.contains(indexPath.row) ? .checkmark : .none
        
        return cell
    }
    
    //for delete one row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let task = tasks[indexPath.row]
            let context = getContext()
            context.delete(task)
            tasks.remove(at: indexPath.row)
            do {
                try context.save()
            }catch let error as NSError {
                print(error.localizedDescription)
            }
            self.tableView.reloadData()
        }
    }
    
    //select row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
//        print(selectedRow)
        if selectedTasks.contains(selectedRow) {
            let index = selectedTasks.firstIndex(of: selectedRow)
            selectedTasks.remove(at: index!)
        } else {
            selectedTasks.append(selectedRow)
        }
        print(selectedTasks)
        tableView.reloadData()
    }
}
