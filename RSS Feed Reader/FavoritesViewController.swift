//
//  FavoritesViewController.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 11/3/21.
//

import UIKit

class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var favoritedFics: [fic] = []
    var indexOfFic: [Int] = []
    var tableCell: TableViewCell?
    var allFics: [fic] = []
    var encodedFics: [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up table view extension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        //initializes the plist manager
        SwiftyPlistManager.shared.start(plistNames: ["SavedFics"], logging: false)
        //gets the information from the plist
        SwiftyPlistManager.shared.getValue(for: "HomeFics", fromPlistWithName: "SavedFics") {(result, err) in
            if err == nil{
                let results = result as! NSArray
                for item in results {
                    encodedFics.append(item as! Data)
                }
            }
        }
        
        //decodes the fics from the property list and adds them to the array to be added to the screen
        for eFic in encodedFics {
            do {
                allFics.append(try PropertyListDecoder.init().decode(fic.self, from: eFic))
            }
            catch {
                print{"error"}
            }
        }
        
        var i = 0
        for item in allFics {
            if item.starFilled {
                favoritedFics.append(item)
                indexOfFic.append(i)
            }
            i += 1
        }
        
        tableView.reloadData()
    }
    
    //saves the fics in a property list to be restored upon reopening the app
    func saveFics() {
        var decodedFics: [Data] = []
        for fic in allFics {
            do {
            decodedFics.append(try PropertyListEncoder.init().encode(fic))
            }
            catch {
                print("error saving")
            }
        }
        SwiftyPlistManager.shared.addNewOrSave(decodedFics, forKey: "HomeFics", toPlistWithName: "SavedFics") {(err) in
        }
    }
    
}

//enables table view
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    //specifies the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritedFics.count
    }
    
    //sets the information of a cell with the same format as that in the tableCell cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! TableViewCell
        cell.setInfo(favoritedFics[indexPath.row], indexPath)
        cell.delegate = self
        return cell
    }
}

//allows user to interact with specfic elements in a table view
extension FavoritesViewController: TableViewCellDelegate {
    //if the star button is clicked in a cell it makes that fic starred
    func clickStar(with isStarred: Bool, index indexPath: IndexPath) {
        if isStarred {
            favoritedFics[indexPath.row].starFilled = true
            allFics[indexOfFic[indexPath.row]].starFilled = true
        }
        else {
            favoritedFics[indexPath.row].starFilled = false
            allFics[indexOfFic[indexPath.row]].starFilled = false
            favoritedFics.remove(at: indexPath.row)
            //allFics.remove(at: indexOfFic[indexPath.row])
        }
        tableView.reloadData()
        saveFics()
    }
    
    //if the title of the fic is clicked it takes the user to that page in archive of our own
    func goToAo3(index indexPath: IndexPath) {
        UIApplication.shared.open(URL(string: favoritedFics[indexPath.row].link)!)
    }
    
    //Trashes a single fic from the list
    func trashFic(index indexPath: IndexPath) {
        allFics.remove(at: indexOfFic[indexPath.row])
        favoritedFics.remove(at: indexPath.row)
        tableView.reloadData()
        saveFics()
    }
}
