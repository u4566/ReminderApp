//
//  AddReminderCell.swift
//  Wysa Assignment
//
//  Created by Vaibhav on 11/07/21.
//

import UIKit

class AddReminderCell: UITableViewCell {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var dateView: UIView!
    
    let placeholder1 = UILabel()
    let placeholder2 = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    func setupUI() {        
        self.selectionStyle = .none
        self.backgroundColor = Colors.bgColor
        self.dateView.backgroundColor = Colors.bgColor
        
        taskTextView.layer.cornerRadius = 10
        taskTextView.layer.borderWidth = 0.5
        taskTextView.layer.borderColor = UIColor.lightGray.cgColor
        taskTextView.addDoneButtonOnKeyboard()
        
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.borderWidth = 0.5
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        titleTextField.addDoneButtonOnKeyboard()
        
        placeholder1.font = .systemFont(ofSize: 15)
        placeholder2.font = .systemFont(ofSize: 15)
        let frame1 = CGRect(x: 10, y: 15, width: 100, height: 20)
        let frame2 = CGRect(x: 5, y: 5, width: 100, height: 20)
        placeholder1.text = "Add Title"
        placeholder2.text = "Add Task"
        placeholder1.textColor = .gray
        placeholder2.textColor = .gray
        placeholder1.frame = frame1
        placeholder2.frame = frame2
        
        titleTextField.addSubview(placeholder1)
        taskTextView.addSubview(placeholder2)
        
        titleTextField.delegate = self
        taskTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension AddReminderCell: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        placeholder2.isHidden = !text.isEmpty
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        placeholder1.isHidden = !text.isEmpty
    }
}
