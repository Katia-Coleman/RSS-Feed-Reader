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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add in the saved feeds
        feeds.append(first)
        feeds.append(second)
        
        //set up table view extension
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //the action taken upon pressing the refresh button
    //adds in new fics, if there are no fics already added then gets the entirety of the feed
    @IBAction func refresh(_ sender: Any) {
        if feedsIndex < feeds.count {
            if feedsIndex - 1 >= 0 {
                allFics.insert(contentsOf: addFics(feeds[feedsIndex]), at: 0)
            }
            else {
                allFics.append(contentsOf: getFics(feeds[feedsIndex]))
            }
            feedsIndex += 1
            viewDidLoad()
            tableView.reloadData()
        }
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

}

//enables table view
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    //specifies the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(allFics.count)
        return allFics.count
    }
    
    //sets the information of a cell with the same format as that in the tableCell cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! TableViewCell
        cell.setInfo(allFics[indexPath.row])
        return cell
    }
}
