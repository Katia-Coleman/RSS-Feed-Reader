//
//  ViewController.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 10/22/21.
//

import UIKit

class ViewController: UIViewController {

    //the stack holding each of the labels of the fic titles
    @IBOutlet weak var feedStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loops through each of the fics in the array and adds the title to the stack in the UI
        for fic in getFics() {
            let newLabel = UILabel()
            newLabel.text = fic.title
            newLabel.numberOfLines = 0
            feedStackView.addArrangedSubview(newLabel)
        }
    }
    
    //sets up the parser for the feed and returns the array of the fics on that feed
    func getFics() -> [fic] {
        let newFeed = feedParser()
        newFeed.setFeed("https://archiveofourown.org/tags/3828398/feed.atom")
        newFeed.parse()
        return newFeed.fics
    }
    

}

