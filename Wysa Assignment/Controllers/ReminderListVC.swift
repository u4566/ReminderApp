//
//  ReminderListVC.swift
//  Wysa Assignment
//
//  Created by Vaibhav on 11/07/21.
//

import UIKit
import CoreData

class ReminderListVC: UIViewController {

    @IBOutlet weak var remindersTable: UITableView!
    
    let reminderCellID = "ReminderCell"

    let bottomCard = (UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "ReminderBottomCardVC") as? ReminderBottomCardVC) ?? ReminderBottomCardVC()
    let cardHeight : CGFloat = UIScreen.main.bounds.height * 0.8
    let visualEffectView = UIVisualEffectView()
    var cardHelper = BottomCardHelper()
    
    let doneImage: UIImage = #imageLiteral(resourceName: "selected")
    let toBeDoneImage: UIImage = #imageLiteral(resourceName: "unselected")

    lazy var reminderVMObj : ReminderVM = {
        return ReminderVM()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initVM()
        reminderVMObj.fetchData()
    }
    
    
    func setupUI() {
        self.view.backgroundColor = Colors.bgColor
        remindersTable.backgroundColor = Colors.bgColor
        navigationController?.navigationBar.barTintColor = Colors.navBarColor
        
        self.title = "Reminders"
        remindersTable.delegate = self
        remindersTable.dataSource = self
        remindersTable.tableFooterView = UIView()
        remindersTable.showsVerticalScrollIndicator = false
        
        setupNavigationBar()
        setupBottomCard()
    }
    
    func initVM() {
        reminderVMObj.updateUI = { [weak self] in
            DispatchQueue.main.async {
                self?.remindersTable.reloadData()
            }
        }
    }
    
    func setupBottomCard() {
        cardHelper = BottomCardHelper(cardState: .collapsed, bottomCard: bottomCard, cardHeight: cardHeight, visualEffectView: visualEffectView)
        self.visualEffectView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        let y: CGFloat = navBarHeight + topDistance
        self.visualEffectView.frame = CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: screenWidth, height: screenHeight - y))

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        self.visualEffectView.addGestureRecognizer(tapGestureRecognizer)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.tapAction))
        swipeDown.direction = .down
        self.bottomCard.view.addGestureRecognizer(swipeDown)

        bottomCard.parentVC = self
        let newFrame    = self.bottomCard.view.frame
        self.bottomCard.view.frame = CGRect(x: newFrame.origin.x, y: screenHeight, width: newFrame.width, height: self.cardHeight)
        addCard(cardHelper: cardHelper)
    }

    @objc func tapAction() {
        handleCardState(cardHelper: cardHelper)
    }
    
    func setupNavigationBar() {
        let addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addButtonAction))
        addButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.systemBlue], for: .normal)
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addButtonAction() {
        bottomCard.cardType = .add
        bottomCard.setTitle()
        bottomCard.bottomTable.reloadData()
        tapAction()
    }

    @objc func checkButtonAction(sender: UIButton) {
        let tag = sender.tag
        let reminderModel = reminderVMObj.remindersArray[tag]
        let isDone = (reminderModel.value(forKey: Keys.isTaskDone) as? Bool) ?? false
        let date = (reminderModel.value(forKey: Keys.reminderDate) as? Date) ?? Date()
        reminderModel.setValue(!isDone, forKeyPath: Keys.isTaskDone)
        isDone ? reminderVMObj.removeNotification(reminderModel: reminderModel, index: tag) : reminderVMObj.sendNotification(scheduledDate: date, reminderModel: reminderModel, index: tag)
        remindersTable.reloadData()
    }
    
}

extension ReminderListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reminderCellID, for: indexPath) as? ReminderCell else {
            fatalError("ReminderCell does not exists")
        }
        let model = reminderVMObj.remindersArray[indexPath.row]
        cell.titleLabel.text = model.value(forKey: Keys.title) as? String
        cell.dateLabel.text = ((model.value(forKey: Keys.reminderDate) as? Date) ?? Date()).description.getFormattedDate()
        let isDone = (model.value(forKey: Keys.isTaskDone) as? Bool) ?? false
        cell.checkButton.tag = indexPath.row
        cell.checkButton.setImage(isDone ? doneImage : toBeDoneImage, for: .normal)
        cell.checkButton.addTarget(self, action: #selector(checkButtonAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        remindersTable.setBackground(isEmpty: reminderVMObj.remindersArray.isEmpty)
        return reminderVMObj.remindersArray.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modifyAction = UIContextualAction(style: .destructive, title:  "Delete", handler: {[weak self] _,_,_ in
                let row = indexPath.row
                self?.reminderVMObj.deleteData(index: row)
            })
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let model = reminderVMObj.remindersArray[row]
        let isDone = (model.value(forKey: Keys.isTaskDone) as? Bool) ?? false
        bottomCard.cardType = isDone ? .markAsUndone : .markAsDone
        bottomCard.reminderModel = model
        bottomCard.currentSelectedIndex = row
        bottomCard.setTitle()
        bottomCard.bottomTable.reloadData()
        tapAction()
    }
    
}
