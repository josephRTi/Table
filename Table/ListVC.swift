//
//  ListVC.swift
//  Table
//
//  Created by Егор Уваров on 15.03.2021.
//

import UIKit
import MobileCoreServices


class ListVC: UIViewController, UITableViewDragDelegate, UITableViewDropDelegate {
    
    weak var delegate: AddVC!
    var rows = ["row 1", "row 2", "row 3",]

    var refreshControl = UIRefreshControl()

    private var editButton: UIButton = {
        let editButton = UIButton()
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitle("Done", for: .selected)
        editButton.setTitleColor(.systemBlue, for: .normal)
        editButton.setTitleColor(.systemBlue, for: .selected)
        return editButton
    }()
    
    
    private var addButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight:.light)
        return addButton
    }()
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Table"
        configureTableView()
        editButton.addTarget(self, action: #selector(editing), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addRecord), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        tableView.dragInteractionEnabled = true
        tableView.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalToConstant: 43)
        ])
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        // set delegates
        setTableViewDelegates()
        // set row height
        tableView.rowHeight = 100
        // register cells
        tableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")
        // set constraints
        tableView.pin(to: view)
    }
    
    func setTableViewDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    
    @objc func toAddVC() {
        navigationController?.pushViewController(AddVC(), animated: true)
    }
    
    @objc func editing(){
        UIView.transition(with: editButton, duration: 0.2, options: .transitionCrossDissolve, animations: { self.editButton.isSelected = !self.editButton.isSelected }, completion: nil)
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        tableView.reloadData()
        sender.endRefreshing()
    }
    
    @objc func addRecord(){
        let newListVC = AddVC()
        newListVC.delegate = self
        self.navigationController?.pushViewController(newListVC, animated: true)
    }
}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
            
            if let indexPath = coordinator.destinationIndexPath {
                destinationIndexPath = indexPath
            } else {
                // Get last index path of table view.
                let section = tableView.numberOfSections - 1
                let row = tableView.numberOfRows(inSection: section)
                destinationIndexPath = IndexPath(row: row, section: section)
            }
            
            coordinator.session.loadObjects(ofClass: NSString.self) { items in
                // Consume drag items.
                let stringItems = items as! [String]
                
                var indexPaths = [IndexPath]()
                for (index, item) in stringItems.enumerated() {
                    let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                    self.rows.append(item)
                    indexPaths.append(indexPath)
                }

                tableView.insertRows(at: indexPaths, with: .automatic)
            }
    }
    
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let placeName = rows[indexPath.row]

        let data = placeName.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }

        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
    
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.rows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = rows[indexPath.row]
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = rows.remove(at: sourceIndexPath.row)
        rows.insert(mover, at: destinationIndexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        cell.titleLabel.text = rows[indexPath.row]
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        //cell.textLabel?.textAlignment = .center
        return cell
        
    }
    
    
}
