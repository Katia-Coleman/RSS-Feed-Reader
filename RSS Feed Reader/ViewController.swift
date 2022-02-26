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
    @IBOutlet weak var searchBar: UISearchBar!
    
    var first = "file:///Users/katiacoleman/Desktop/Apps%20in%20Progress/RSS%20Feed%20Reader/first.txt"
    var second = "file:///Users/katiacoleman/Desktop/Apps%20in%20Progress/RSS%20Feed%20Reader/second.txt"
    var feeds: [String] = []
    var feedsIndex = 0
    var blacklistedItems: [String] = []
    var allFics: [fic] = []
    var displayedFics: [fic] = []
    var indexOfDisplay: [Int] = []
    var searchedString = ""
    var encodedFics: [Data] = []
    var start: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add in the saved feeds
        //feeds.append(first)
        //feeds.append(second)
        //feeds.append("https://archiveofourown.org/tags/3828398/feed.atom")
        //feeds.append("https://archiveofourown.org/tags/582724/feed.atom")
        
        //get the saved information
        getSavedFics("HomeFics")
        feeds = getSavedList("Following")
        blacklistedItems = getSavedList("BlacklistedItems")
        
        //set up table view extension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.reloadData()
        
        //set up search bar
        searchBar.delegate = self
        displayedFics = allFics
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(backgroundRefreshStatusDidChange),
              name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    @objc func backgroundRefreshStatusDidChange() {
        print("New status: \(UIApplication.shared.backgroundRefreshStatus)")
    }
    
    //code runs when the main view controller is opened
    override func viewDidAppear(_ animated: Bool) {
        feeds = getSavedList("Following")
        blacklistedItems = getSavedList("BlacklistedItems")
        getSavedFics("HomeFics")
        displayedFics = allFics
        searchedString = ""
        searchBar.text = ""
        removeBlacklistedItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    //gets the saved fics from the property list
    func getSavedFics(_ item: String) {
        allFics.removeAll()
        encodedFics.removeAll()
        //initializes the plist manager
        SwiftyPlistManager.shared.start(plistNames: ["SavedFics"], logging: false)
        //gets the information from the plist
        SwiftyPlistManager.shared.getValue(for: item, fromPlistWithName: "SavedFics") {(result, err) in
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
    }
    
    //retrieves the saved feeds from the property list
    func getSavedList(_ item: String) -> [String] {
        var temp: [String] = []
        SwiftyPlistManager.shared.getValue(for: item, fromPlistWithName: "SavedFics") {(result, err) in
            if err == nil{
                let results = result as! NSArray
                for item in results {
                    temp.append(item as! String)
                }
            }
        }
        return temp
    }
    
    //the action taken upon pressing the refresh button
    //adds in new fics, if there are no fics already added then gets the entirety of the feed
    @IBAction func refresh(_ sender: Any) {
        refresh()
        tableView.reloadData()
    }
    
    func refresh() {
        for feed in feeds {
            allFics.append(contentsOf: addFics(feed))
        }
        removeBlacklistedItems()
        allFics.sort(by: {$0.dateUpdated.compare($1.dateUpdated) == .orderedDescending})
        saveFics()
        displayedFics = allFics
    }
    
   //the action taken upon pressing the delete button
    //deletes all of the fics on the page
    @IBAction func deleteAllFics(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Alert", message: "Do you want to delete all saved fics?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            if action.style == .default {
                self.allFics.removeAll()
                self.displayedFics = self.allFics
                self.tableView.reloadData()
                SwiftyPlistManager.shared.addNewOrSave([], forKey: "HomeFics", toPlistWithName: "SavedFics") {(err) in}
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //sets up the parser for the feed and returns the array of the fics on that feed
    func getFics(_ url: String) -> [fic] {
        let newFeed = feedParser()
        newFeed.setFeed(url)
        newFeed.parse()
        var changedFics: [fic] = []
        for updatedFic in newFeed.fics {
            let newSummary = summaryParser()
            newSummary.setData(updatedFic.summary)
            newSummary.parse()
            changedFics.append(fic(title: updatedFic.title, id: updatedFic.id, starFilled: updatedFic.starFilled, summary: newSummary.completeSummary, link: updatedFic.link, author: newSummary.currentAuthor, dateUpdated: updatedFic.dateUpdated))
        }
        return changedFics
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
    
    //removes all the fics with a blacklisted item in the summary section
    func removeBlacklistedItems() {
        for item in blacklistedItems {
            var ficIndex = 0
            for fic in allFics {
                if fic.summary.contains(item) {
                    allFics.remove(at: ficIndex)
                    ficIndex -= 1
                }
                ficIndex += 1
            }
        }
        saveFics()
    }

}

//enables table view
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    //specifies the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedFics.count
    }
    
    //sets the information of a cell with the same format as that in the tableCell cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! TableViewCell
        cell.setInfo(displayedFics[indexPath.row], indexPath)
        cell.delegate = self
            if displayedFics[indexPath.row].starFilled {
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
        if searchedString != ""
        {
            if isStarred {
                allFics[indexOfDisplay[indexPath.row]].starFilled = true
                displayedFics[indexPath.row].starFilled = true
            }
            else {
                allFics[indexOfDisplay[indexPath.row]].starFilled = false
                displayedFics[indexPath.row].starFilled = false
            }
        }
        else {
            if isStarred {
                allFics[indexPath.row].starFilled = true
            }
            else {
                allFics[indexPath.row].starFilled = false
            }
        }
        saveFics()
    }
    
    //if the title of the fic is clicked it takes the user to that page in archive of our own
    func goToAo3(index indexPath: IndexPath) {
        UIApplication.shared.open(URL(string: allFics[indexPath.row].link)!)
    }
    
    //Trashes a single fic from the list
    func trashFic(index indexPath: IndexPath) {
        if searchedString != "" {
            allFics.remove(at: indexOfDisplay[indexPath.row])
            displayedFics.remove(at: indexPath.row)
        }
        else {
            allFics.remove(at: indexPath.row)
            displayedFics.remove(at: indexPath.row)
        }
        tableView.reloadData()
        saveFics()
    }
}

//extension for functions relating to the search bar
extension ViewController: UISearchBarDelegate {
    //function that runs when the search button is clicked
    //sets the displayed fics to any with the what was typed in the search bar in its summary section
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedString = searchBar.text!.lowercased()
        displayedFics.removeAll()
        var index = 0
        if searchedString != "" {
            for fic in allFics {
                if(fic.summary.lowercased().contains(searchedString)) {
                    displayedFics.append(fic)
                    indexOfDisplay.append(index)
                }
                index += 1
            }
        }
        else {
            displayedFics = allFics
        }
        tableView.reloadData()
    }
}
