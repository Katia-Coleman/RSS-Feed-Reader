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
        for item in allFics {
            if item.starFilled {
                favoritedFics.append(item)
            }
        }
        tableView.reloadData()
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
        return cell
    }
}

//allows user to interact with specfic elements in a table view
extension FavoritesViewController: TableViewCellDelegate {
    //if the star button is clicked in a cell it makes that fic starred
    func clickStar(with isStarred: Bool, index indexPath: IndexPath) {
        if isStarred {
            print("Star")
            favoritedFics[indexPath.row].starFilled = true
        }
        else {
            print("unstar")
            favoritedFics[indexPath.row].starFilled = false
            favoritedFics.remove(at: indexPath.row)
        }
        tableView.reloadData()
    }
    
    //if the title of the fic is clicked it takes the user to that page in archive of our own
    func goToAo3(index indexPath: IndexPath) {
        print("link")
        UIApplication.shared.open(URL(string: favoritedFics[indexPath.row].link)!)
    }
}
