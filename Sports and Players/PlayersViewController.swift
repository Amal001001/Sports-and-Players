//  PlayersViewController.swift
//  Sports and Players

import UIKit
import CoreData

class PlayersViewController: UIViewController {

    var playersList : [PlayerEntity] = []
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var tableView: UITableView!
    
    var sport : SportEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = sport.sportName
        
        tableView.dataSource = self
        tableView.delegate = self
        fetchPlayer()
    }

    @IBAction func addPlayerButton(_ sender: Any) {
        let alert = UIAlertController(title: "New Player", message: "Add a new player",preferredStyle: .alert)
               
            alert.addTextField(configurationHandler: nil)
            alert.addTextField(configurationHandler: nil)
            alert.addTextField(configurationHandler: nil)
                       
        let nameTextField = alert.textFields![0]
        let ageTextField = alert.textFields![1]
        let heightTextField = alert.textFields![2]
                       
        nameTextField.placeholder = "Enter player name"
        ageTextField.placeholder = "Enter player age"
        heightTextField.placeholder = "Enter player height"
                       
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                           
            let newPlayer = PlayerEntity(context: self.managedObjectContext)
            newPlayer.playerName = nameTextField.text!
            newPlayer.playerAge = ageTextField.text!
            newPlayer.playerHeight = heightTextField.text!
            DispatchQueue.main.async {
                          newPlayer.player_sportRelationship?.sportName = self.sport?.sportName
                           self.sport?.addToSport_playerRelationship(newPlayer)
                           self.tableView.reloadData()
                           self.savePlayer()
            }
                         
        }
                       
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)

    }
    
    func savePlayer() {
         do {
             try managedObjectContext.save()
             print("Saved successful")
            }catch{
                   print("Error \(error)")
            }
               
         fetchPlayer()
    }
           
    func fetchPlayer() {
          do {
              playersList = try managedObjectContext.fetch(PlayerEntity.fetchRequest())
              print("Fetched player uccess")
             }catch{
                   print("Error: \(error)")
             }
          tableView.reloadData()
    }
    
}
//////////////////////////////////table view functions/////////////////////////
extension PlayersViewController : UITableViewDataSource,UITableViewDelegate{
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
         return sport.sport_playerRelationship?.count ?? 0
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)

         let currentPlayer = sport.sport_playerRelationship?[indexPath.row] as! PlayerEntity
        cell.textLabel?.numberOfLines = 0
         
        cell.textLabel?.text = "player name: \(currentPlayer.playerName!)\nage: \(currentPlayer.playerAge!)\nhieght: \(currentPlayer.playerHeight!)"
        return cell
     }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         let currentPlayer = sport.sport_playerRelationship?[indexPath.row] as! PlayerEntity
         managedObjectContext.delete(currentPlayer)
        self.savePlayer()
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let currentPlayer = sport.sport_playerRelationship?[indexPath.row] as! PlayerEntity
          
         let alert = UIAlertController(title: "Edit Player", message: nil, preferredStyle: .alert)
                 
                 alert.addTextField {
                     (textField) in
                     textField.text = currentPlayer.playerName
                 }
                 
                 alert.addTextField {
                     (textField) in
                     textField.text = currentPlayer.playerAge
                 }
                 
                 alert.addTextField {
                     (textField) in
                     textField.text = currentPlayer.playerHeight
                 }
                 
                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                     let playerName = alert?.textFields![0]
                     let playerAge = alert?.textFields![1]
                     let playerHeight = alert?.textFields![2]
                     currentPlayer.playerName = playerName?.text
                     currentPlayer.playerAge = playerAge?.text
                     currentPlayer.playerHeight = playerHeight?.text
                     self.savePlayer()
                 }))
                 
                 self.present(alert, animated: true, completion: nil)
       }
}
