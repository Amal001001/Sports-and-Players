//  ViewController.swift
//  Sports and Players

import UIKit
import CoreData

class SportsViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, imagePickerDelegate {

    var sportList : [SportEntity] = []
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var currentCellindexPath : Int?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchSport()
    }

    ////////////////UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           
        guard let image = info[.originalImage] as? UIImage else { return }
        let selectedimage = image
           addImageToEntity(id: currentCellindexPath!, selectedImage : selectedimage)
               
           DispatchQueue.main.async {
              self.tableView.reloadData()
           }
        
        picker.dismiss(animated: true, completion: nil)
     }
    ////////////////imagePickerDelegate
    func imagePick(cellIndexPath : Int) {
            
        let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
        
        currentCellindexPath = cellIndexPath
        DispatchQueue.main.async {
           self.present(imagePickerVC, animated: true)
        }

    }
}

//////////////////////////////////table view functions/////////////////////////
extension SportsViewController {
    
    override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sportCell", for: indexPath) as! SportTableViewCell
        
        cell.sportNameLabel.text = sportList[indexPath.row].sportName
        cell.cellindexpath = indexPath.row
        
        if let selectedImg = sportList[indexPath.row].sportImage {
            cell.addImageButton.setTitle("", for: .normal)
            let image = UIImage(data: selectedImg)
            cell.addImageView.image = image
        }else{
            cell.addImageButton.setTitle("add image", for: .normal)
        }
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sportList.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        managedObjectContext.delete(sportList[indexPath.row])
        self.saveSport()
    }
    

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayersViewController") as! PlayersViewController
         playerVC.sport = sportList[indexPath.row]
         
         navigationController?.pushViewController(playerVC, animated: true)
         
     }
}

////////////////////// data core functions////////////////////
extension SportsViewController {
    
    @IBAction func addSport(_ sender: UIBarButtonItem) {
  
           let alert = UIAlertController(title: "New Sport",
                                         message: "Add a new sport",
                                         preferredStyle: .alert)
           
           alert.addTextField(configurationHandler: nil)
           
           let saveAction = UIAlertAction(title: "Save", style: .default)
           {
               _ in
               let textField = alert.textFields![0]
               
               // add sport to data core
               let newSportEntry = SportEntity(context: self.managedObjectContext)
               newSportEntry.sportName = textField.text!
               newSportEntry.sportId = Int16(self.sportList.count)
               self.saveSport()
           }
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           alert.addAction(saveAction)
           alert.addAction(cancelAction)
           present(alert, animated: true, completion: nil)
           
       }
    
    func addImageToEntity(id: Int , selectedImage : UIImage){
        
        let oldSportItem = sportList[id]
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SportEntity")
                 
        let predcate = NSPredicate.init(format: "sportName = %@", oldSportItem.sportName!)

            request.predicate = predcate
            do{
                 let result = try managedObjectContext.fetch(request).first
                 let sportItem = result as! SportEntity
                     
                 sportItem.sportImage = selectedImage.pngData()
                 saveSport()
            }catch{
            print("can not save the image")
            }
    }
    
    func saveSport() {
        do{
            try managedObjectContext.save()
            print("Saved successful")
        }catch{
            print("Error \(error)")
        }
        fetchSport()
    }
    
    func fetchSport() {
        do{
            sportList = try managedObjectContext.fetch(SportEntity.fetchRequest())
            print("Success")
        }catch{
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
}
