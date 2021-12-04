//
//  FollowingViewController.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 12/4/21.
//

import UIKit

class FollowingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    
    var following: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //following.append("first")
        //following.append("second")
        
        //initializes the plist manager
        SwiftyPlistManager.shared.start(plistNames: ["SavedFics"], logging: false)
        //gets the information from the plist
        SwiftyPlistManager.shared.getValue(for: "Following", fromPlistWithName: "SavedFics") {(result, err) in
            if err == nil{
                let results = result as! NSArray
                for item in results {
                    following.append(item as! String)
                }
            }
        }
        
        //set up table view extension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.reloadData()
    }
    
    //adds the URL in the text field to the list of followed feeds
    @IBAction func enteredText(_ sender: Any) {
        following.append(textField.text!)
        textField.text = ""
        tableView.reloadData()
        saveFeeds()
    }
    
    //saves the feeds in a property list to be restored upon reopening the app
    func saveFeeds() {
        SwiftyPlistManager.shared.addNewOrSave(following, forKey: "Following", toPlistWithName: "SavedFics") {(err) in
        }
    }
    
}

//enables table view
extension FollowingViewController: UITableViewDataSource, UITableViewDelegate {
    
    //specifies the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return following.count
    }
    
    //sets the information of a cell with the same format as that in the followingTableCell cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followingTableCell") as! TableViewCell
        cell.setInfoFollowing(following[indexPath.row], indexPath)
        cell.followingDelegate = self
        return cell
    }
}

extension FollowingViewController: FollowingTableViewCellDelegate {
    func trashFeed(index indexPath: IndexPath) {
        following.remove(at: indexPath.row)
        tableView.reloadData()
        saveFeeds()
    }
}
