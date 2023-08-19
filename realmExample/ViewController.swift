//
//  ViewController.swift
//  realmExample
//
//  Created by Ярослав on 18.08.2023.
//

import UIKit
import RealmSwift
import SnapKit

class Dog: Object {
    @Persisted var name: String
    @Persisted var age: Int
}

class ViewController: UIViewController {
    let realm = try! Realm()
    let tableView = UITableView()
    var dog = Dog()
    lazy var dogs = Array(realm.objects(Dog.self))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 10,
            migrationBlock: { migration, oldSchemaVersion in


            },
            deleteRealmIfMigrationNeeded: true
        )
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTap))
        navigationItem.rightBarButtonItem = barButton
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.layoutMargins)
            $0.left.right.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        dogs = Array(realm.objects(Dog.self))
        tableView.reloadData()
    }
    
    @objc func addTap() {
        let alertController = UIAlertController(title: "Добавить собакена", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.addTextField()
        
        alertController.textFields?[0].placeholder = "Имя собакена"
        alertController.textFields?[1].placeholder = "Возраст собакена"
        
        let submitAction = UIAlertAction(title: "Добавить", style: .default) { _ in
            let dogName = alertController.textFields?[0].text ?? ""
            let dogAge = Int(alertController.textFields?[1].text ?? "") ?? 0
            
            let dog = Dog()
            dog.name = dogName
            dog.age = dogAge

            try! self.realm.write {
                self.realm.add(dog)
            }
            
            self.dogs = Array(self.realm.objects(Dog.self))
            self.tableView.reloadData()
        }
        
        alertController.addAction(submitAction)
        self.present(alertController, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "🐶 \(dogs[indexPath.row].name), \(dogs[indexPath.row].age) yrs."
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let dog = dogs[indexPath.row]
        
        try! realm.write {
            realm.delete(dog)
        }
        
        dogs.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
