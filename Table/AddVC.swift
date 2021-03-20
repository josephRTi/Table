//
//  AddVC.swift
//  Table
//
//  Created by Егор Уваров on 17.03.2021.
//

import UIKit

class AddVC: UIViewController {
    var selectedName: String = "Anonymous"
    weak var delegate: ListVC!
    
    private var backButton:UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Table", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.returnKeyType = UIReturnKeyType.done
        //textField.borderStyle = .line
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "New row"
        textField.becomeFirstResponder()
        view.addSubview(textField)
        textField.delegate = self
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height * 0.12),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    @objc func addRecord(){
        var record:String = textField.text ?? "default"
        textField.endEditing(true)
    }
}


extension AddVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let row = textField.text {
            delegate?.rows.append(row)
            delegate?.tableView.reloadData()
        }
        return true
    }
}
