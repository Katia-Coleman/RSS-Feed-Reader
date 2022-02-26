//
//  BlacklistViewController.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 1/22/22.
//

import UIKit

class BlacklistViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textfield: UITextField!
    
    var allFics: [fic] = []
    var encodedFics: [Data] = []
    var blacklistedItems: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initializes the plist manager
        SwiftyPlistManager.shared.start(plistNames: ["SavedFics"], logging: false)
        //gets the saved fics from the plist
        SwiftyPlistManager.shared.getValue(for: "HomeFics", fromPlistWithName: "SavedFics") {(result, err) in
            if err == nil{
                let results = result as! NSArray
                for item in results {
                    encodedFics.append(item as! Data)
                }
            }
        }
        //gets the saved blacklisted items from the plist
        SwiftyPlistManager.shared.getValue(for: "BlacklistedItems", fromPlistWithName: "SavedFics")
            {(result, err) in
            if err == nil{
                let results = result as! NSArray
                for item in results {
                    blacklistedItems.append(item as! String)
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
    
        
        //set up table view extension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.reloadData()
    }
    
    
    @IBAction func enteredText(_ sender: Any) {
        blacklistedItems.append(textfield.text!)
        textfield.text = ""
        tableView.reloadData()
        saveFeeds()
    }
    
    //saves the blacklisted items in a property list to be restored upon reopening the app
    func saveFeeds() {
        SwiftyPlistManager.shared.addNewOrSave(blacklistedItems, forKey: "BlacklistedItems", toPlistWithName: "SavedFics") {(err) in
        }
    }
    
    //When the information button is clicked on a pop-up will show up to descibe how the blacklist works
    @IBAction func informationPopUp(_ sender: Any) {
        let alert = UIAlertController(title: "Blacklist Info", message: "Blacklisting an item removes all fics with that blacklisted item in their description. Just type the item into the provided textbox.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//enables table view
extension BlacklistViewController: UITableViewDataSource, UITableViewDelegate {
    
    //specifies the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blacklistedItems.count
    }
    
    //sets the information of a cell with the same format as that in the followingTableCell cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blacklistTableCell") as! TableViewCell
        cell.setInfoFollowing(blacklistedItems[indexPath.row], indexPath)
        cell.followingDelegate = self
        return cell
    }
}

extension BlacklistViewController: FollowingTableViewCellDelegate {
    func trashFeed(index indexPath: IndexPath) {
        blacklistedItems.remove(at: indexPath.row)
        tableView.reloadData()
        saveFeeds()
    }
}
