//
//  ReminderVM.swift
//  Wysa Assignment
//
//  Created by Vaibhav on 11/07/21.
//

import UIKit
import CoreData

class ReminderVM: NSObject {
    
    var updateUI : (()->())?
    var remindersArray: [NSManagedObject] = []

    var reloadTable: Bool = false {
        didSet {
            updateUI?()
        }
    }
    
    func checkForEnabledNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
              (granted, error) in
              if granted {
                  print("yes")
              } else {
                  print("No")
              }
          }
    }
    
    func save(task: String, title: String, reminderDate: Date, index: Int) {
      checkForEnabledNotification()
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      let managedContext = appDelegate.persistentContainer.viewContext
      let entity = NSEntityDescription.entity(forEntityName: Keys.reminder, in: managedContext)!
      let reminder = NSManagedObject(entity: entity, insertInto: managedContext)
      reminder.setValue(title, forKeyPath: Keys.title)
      reminder.setValue(task, forKeyPath: Keys.task)
      reminder.setValue(reminderDate, forKeyPath: Keys.reminderDate)
      reminder.setValue(false, forKeyPath: Keys.isTaskDone)
      sendNotification(scheduledDate: reminderDate, reminderModel: reminder, index: index)

      do {
        try managedContext.save()
        remindersArray.append(reminder)
        sendNotification(scheduledDate: reminderDate, reminderModel: reminder, index: index)
        reloadTable = true
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Keys.reminder)
      
        do {
            remindersArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func deleteData(index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Reminder")
      
        do {
            remindersArray = try managedContext.fetch(fetchRequest)
            let model = remindersArray[index]            
            removeNotification(reminderModel: model, index: index)
            managedContext.delete(model)
            remindersArray.remove(at: index)
            
            reloadTable = true
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func updateData(task: String, title: String, reminderDate: Date, index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Reminder")
      
        do {
            remindersArray = try managedContext.fetch(fetchRequest)
            let model = remindersArray[index]
            model.setValue(title, forKeyPath: Keys.title)
            model.setValue(task, forKeyPath: Keys.task)
            model.setValue(reminderDate, forKeyPath: Keys.reminderDate)
            checkForEnabledNotification()
            sendNotification(scheduledDate: reminderDate, reminderModel: model, index: index)
            reloadTable = true
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func sendNotification(scheduledDate: Date, reminderModel: NSManagedObject, index: Int) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        let content = UNMutableNotificationContent()
        content.title = (reminderModel.value(forKey: Keys.title) as? String) ?? ""
        content.subtitle = scheduledDate.description.getFormattedDate()

        let interval = scheduledDate.timeIntervalSinceNow - Date().timeIntervalSinceNow <= 0  ? 1 : scheduledDate.timeIntervalSinceNow - Date().timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let id = "\(scheduledDate.description)\(index)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func removeNotification(reminderModel: NSManagedObject, index: Int) {
        let date = ((reminderModel.value(forKey: Keys.reminderDate) as? Date) ?? Date())
        let id = "\(date.description)\(index)"
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

}
