//
//  ViewController.swift
//  MyHitList
//
//  Created by Aleksandar Stanojcic on 4/5/17.
//  Copyright © 2017 Aleksandar Stanojcic. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController: NSFetchedResultsController<Person>!
    var imagePickerIndexPath = IndexPath(item: 0, section: 0)
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "The List"
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.bounds.size.width/2.0 - 16, height: 280)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 44)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.addPerson(_:)))
        let filterBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(ViewController.filter))
        navigationItem.rightBarButtonItems = [addBarButtonItem, filterBarButtonItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    //MARK: - Public API
    
    func stringFromEyeColor(_  eyeColor: UIColor) -> String{
        switch eyeColor {
        case UIColor.blue:
            return "Blue"
        case UIColor.purple:
            return "Purple"
        case UIColor.green:
            return "Green"
        case UIColor.brown:
            return "Brown"
        default:
            return "Unknown"
        }
    }
    
    //MARK: - Private API
    
    private func save(name: String, address: String, age: Int16, eyeColor: UIColor) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let person = Person(entity: Person.entity(), insertInto: managedContext)
        
        person.name = name
        person.address = address
        person.age = age
        person.eyeColor = eyeColor
        person.picture = UIImagePNGRepresentation(UIImage(named: "person-placeholder")!)! as NSData
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func reloadData(minimumAge: Int16 = 0) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let fetchRequest:NSFetchRequest<Person> = Person.fetchRequest()
        if minimumAge > 0 {
            fetchRequest.predicate = NSPredicate(format: "age > %d", minimumAge)
        }
        
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let eyeColorSortDescriptor = NSSortDescriptor(key: "eyeColor", ascending: true)
        fetchRequest.sortDescriptors = [eyeColorSortDescriptor, nameSortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: appDelegate.persistentContainer.viewContext,
                                                              sectionNameKeyPath: #keyPath(Person.eyeColor),
                                                              cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            collectionView.reloadData()
        } catch let error {
            print(error)
        }
    }
    
    @objc private func filter() {
        let alertController = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Show All", style: .default, handler: { (action) in
            self.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Over 65", style: .default, handler: { (action) in
            self.reloadData(minimumAge: Int16(65))
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func addPerson(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let nameToSave = alert.textFields?[0].text,
                let addressToSave = alert.textFields?[1].text,
                let age = alert.textFields?[2].text,
                let eyeColor = alert.textFields?[3].text else {
                    return
            }
            
            let eyeColorToSave = self.eyeColorFromString(eyeColor)
            let ageToSave = Int16(age) ?? 0
            
            self.save(name: nameToSave, address: addressToSave, age: ageToSave, eyeColor: eyeColorToSave)
            self.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields?[0].placeholder = "Name"
        alert.textFields?[1].placeholder = "Address"
        alert.textFields?[2].placeholder = "Age"
        alert.textFields?[3].placeholder = "Eye Color"
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func eyeColorFromString(_ eyeColor: String) -> UIColor {
        switch eyeColor {
        case "Blue":
            return UIColor.blue
        case "Purple":
            return UIColor.purple
        case "Green":
            return UIColor.green
        case "Brown":
            return UIColor.brown
        default:
            return UIColor.clear
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let person = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TargetCollectionViewCell
        
        cell.nameLabel.text = person.name
        cell.addressLabel.text = person.address
        cell.ageLabel.text = String(person.age)
        cell.eyeColorView.backgroundColor = person.eyeColor as! UIColor?
        if let pictureData = person.picture {
            cell.pictureImageView.image = UIImage(data: pictureData as Data)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderCollectionReusableView
        
        if let peopleInSection = fetchedResultsController.sections?[indexPath.section].objects as? [Person],
            let firstPerson = peopleInSection.first {
            header.headerLabel.text = "\(stringFromEyeColor(firstPerson.eyeColor! as! UIColor)) Eyed People"
        }
        
        return header
    }
}

//MARK: - UIColectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imagePickerIndexPath = indexPath
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        self.navigationController?.present(pickerController, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let person = fetchedResultsController.fetchedObjects?[imagePickerIndexPath.row]
        person?.picture = UIImagePNGRepresentation(image)! as NSData
        do {
            try appDelegate.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
        
        collectionView.reloadItems(at: [imagePickerIndexPath])
        picker.dismiss(animated: true, completion: nil)
    }
}
