//
//  ReminderBottomCardVC.swift
//  Wysa Assignment
//
//  Created by Vaibhav on 11/07/21.
//

import UIKit
import CoreData

enum ReminderBottomCardType {
    case add, markAsDone, markAsUndone
}

class ReminderBottomCardVC: UIViewController {

    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var bottomTable: UITableView!
    
    var parentVC = UIViewController()
    let addReminderCellID = "AddReminderCell"
    var cardType: ReminderBottomCardType = .add
    var reminderDate = Date()
    let datePicker = UIDatePicker()
    
    var reminderModel: NSManagedObject?
    var currentSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        self.view.roundCorners([.topLeft, .topRight], radius: 20)
        self.view.backgroundColor = Colors.bgColor
        bottomTable.backgroundColor = Colors.bgColor
        
        markButton.addTarget(self, action: #selector(markAction), for: .touchUpInside)
        bottomTable.dataSource = self
        bottomTable.delegate = self
        bottomTable.tableFooterView = UIView()
        bottomTable.showsVerticalScrollIndicator = false
        bottomTable.separatorStyle = .none
        
        let addNib = UINib(nibName: addReminderCellID, bundle: .main)
        bottomTable.register(addNib, forCellReuseIdentifier: addReminderCellID)
    }
    
    func setTitle() {
        var title = ""
        switch cardType {
        case .add:
            title = "Add Reminder"
        case .markAsDone:
            title = "Update"
        case .markAsUndone:
            title = "Update"
        }
        markButton.setTitle(title, for: .normal)
    }
    
    func getDatePicker() -> UIDatePicker {
        datePicker.date = Date()
        datePicker.locale = .current
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(handleDateSelection), for: .valueChanged)
        return datePicker
    }
    
    @objc func handleDateSelection(sender: UIDatePicker) {
        reminderDate = sender.date
        datePicker.setDate(reminderDate, animated: true)
    }
    
    @objc func markAction() {
        guard let parent = parentVC as? ReminderListVC else { return }
        guard let cell = bottomTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddReminderCell else { return }
        let title = cell.titleTextField.text ?? ""
        let task = cell.taskTextView.text ?? ""
        cell.titleTextField.resignFirstResponder()
        cell.taskTextView.resignFirstResponder()
        switch cardType {
        case .add:
            if title.isEmpty || task.isEmpty {
                let alert = UIAlertController(title: "Alert", message: Keys.fillData, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if reminderDate < Date() {
                let alert = UIAlertController(title: "Alert", message: Keys.greaterDate, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            parent.reminderVMObj.save(task: task, title: title, reminderDate: reminderDate, index: parent.reminderVMObj.remindersArray.count)
        default:
            if title.isEmpty || task.isEmpty {
                let alert = UIAlertController(title: "Alert", message: Keys.fillData, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            parent.reminderVMObj.updateData(task: task, title: title, reminderDate: reminderDate, index: currentSelectedIndex)
        }
        parent.tapAction()
    }
}

extension ReminderBottomCardVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: addReminderCellID, for: indexPath) as? AddReminderCell else { fatalError("AddReminderCell does not exists")
        }
        cell.placeholder1.isHidden = true
        cell.placeholder2.isHidden = true
        switch cardType {
        case .add:
            cell.titleTextField.text = ""
            cell.taskTextView.text = ""
            cell.dateButton.setTitle("Select date", for: .normal)
            cell.dateView.addSubview(getDatePicker())
            cell.placeholder1.isHidden = false
            cell.placeholder2.isHidden = false
        case .markAsDone:
            cell.titleTextField.text = reminderModel?.value(forKey: Keys.title) as? String
            cell.taskTextView.text = reminderModel?.value(forKey: Keys.task) as? String
            let date = (reminderModel?.value(forKey: Keys.reminderDate) as? Date) ?? Date()
            datePicker.setDate(date, animated: true)
            cell.dateButton.setTitle("Selected Date", for: .normal)
        case .markAsUndone:
            cell.titleTextField.text = reminderModel?.value(forKey: Keys.title) as? String
            cell.taskTextView.text = reminderModel?.value(forKey: Keys.task) as? String
            let date = (reminderModel?.value(forKey: Keys.reminderDate) as? Date) ?? Date()
            datePicker.setDate(date, animated: true)
            cell.dateButton.setTitle("Selected Date", for: .normal)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
