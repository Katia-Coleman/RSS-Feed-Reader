//
//  ViewController.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 10/22/21.
//

import UIKit

class ViewController: UIViewController {

    //the stack holding each of the labels of the fic titles
    //@IBOutlet weak var feedStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    var first = "file:///Users/katiacoleman/Desktop/Apps%20in%20Progress/RSS%20Feed%20Reader/first.txt"
    var second = "file:///Users/katiacoleman/Desktop/Apps%20in%20Progress/RSS%20Feed%20Reader/second.txt"
    var feeds: [String] = []
    var feedsIndex = 0
    var allFics: [fic] = []
    var encodedFics: [Data] = []
    var start: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add in the saved feeds
        feeds.append(first)
        feeds.append(second)
        
        //set up table view extension
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        tableView.reloadData()
    }
    
    //the action taken upon pressing the refresh button
    //adds in new fics, if there are no fics already added then gets the entirety of the feed
    @IBAction func refresh(_ sender: Any) {
            if feedsIndex == 1 {
                allFics.insert(contentsOf: addFics(feeds[feedsIndex]), at: 0)
            }
            else if feedsIndex == 0 {
                allFics.insert(contentsOf: addFics(feeds[feedsIndex]), at: 0)
            }
            else {
                allFics.insert(contentsOf: addFics("https://archiveofourown.org/tags/3828398/feed.atom"), at: 0)
            }
            feedsIndex += 1
            tableView.reloadData()
            saveFics()
    }
    
   //the action taken upon pressing the delete button
    //deletes all of the fics on the page
    @IBAction func deleteAllFics(_ sender: Any) {
        allFics.removeAll()
        tableView.reloadData()
        SwiftyPlistManager.shared.addNewOrSave([], forKey: "HomeFics", toPlistWithName: "SavedFics") {(err) in}
    }
    
    //sets up the parser for the feed and returns the array of the fics on that feed
    func getFics(_ url: String) -> [fic] {
        let newFeed = feedParser()
        newFeed.setFeed(url)
        newFeed.parse()
        return newFeed.fics
    }
    
    //checks if the id of the fic being added has already been added
    func checkRepeat(_ id: String) -> Bool {
        for fic in allFics {
            if id.compare(fic.id) == .orderedSame {
                return true
            }
        }
        return false
    }
    
    //creates an array of the new fics in the feed
    func addFics(_ newUrl: String) -> [fic] {
        var fics: [fic] = []
        for fic in getFics(newUrl) {
            if !checkRepeat(fic.id) {
                fics.append(fic)
            }
        }
        return fics
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
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    //specifies the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFics.count
    }
    
    //sets the information of a cell with the same format as that in the tableCell cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! TableViewCell
        cell.setInfo(allFics[indexPath.row], indexPath)
        cell.delegate = self
            if allFics[indexPath.row].starFilled {
                cell.starButton.setImage(UIImage(named: "StarFilled"), for: .normal)
            }
            else {
                cell.starButton.setImage(UIImage(named: "StarEmpty"), for: .normal)
            }
        
        return cell
    }
}

//allows user to interact with specfic elements in a table view
extension ViewController: TableViewCellDelegate {
    //if the star button is clicked in a cell it makes that fic starred
    func clickStar(with isStarred: Bool, index indexPath: IndexPath) {
        if isStarred {
            allFics[indexPath.row].starFilled = true
        }
        else {
            allFics[indexPath.row].starFilled = false
        }
        saveFics()
    }
}
