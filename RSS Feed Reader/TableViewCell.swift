//
//  TableViewCell.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 10/30/21.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func clickStar(with isStarred: Bool, index indexPath: IndexPath)
    func goToAo3(index indexPath: IndexPath)
}

protocol FollowingTableViewCellDelegate: AnyObject {
    func trashFeed(index indexPath: IndexPath)
}

class TableViewCell: UITableViewCell {
    
    var delegate: TableViewCellDelegate?
    
    var isStarred: Bool = false
    var indexPath: IndexPath?
    
    //link to title label in table cell
    @IBOutlet weak var title: UIButton!
    
    //when the title of the fic is clicked it takes the user to the fic in archive of our own
    @IBAction func goToAo3(_ sender: Any) {
        delegate?.goToAo3(index: indexPath!)
    }
    
    //link to the summary label in table cell
    @IBOutlet weak var summary: UILabel!
    
    //link to star button in table cell
    @IBOutlet weak var starButton: UIButton!
    
    //action for when the star button is clicked
    @IBAction func starFic(_ sender: UIButton) {
        if isStarred {
            isStarred = false
            starButton.setImage(UIImage(named: "StarEmpty"), for: .normal)
        }
        else {
            isStarred = true
            starButton.setImage(UIImage(named: "StarFilled"), for: .normal)
        }
        delegate?.clickStar(with: isStarred, index: indexPath!)
    }
    
    //sets the information in the cell
    func setInfo(_ fic: fic, _ index: IndexPath) {
        title.setTitle(fic.title, for: UIControl.State.normal)
        summary.text = fic.summary
        indexPath = index
    }
    
    @IBOutlet weak var tagButton: UIButton!
    
    var followingDelegate: FollowingTableViewCellDelegate?
    
    @IBAction func trashFeed(_ sender: Any) {
        followingDelegate?.trashFeed(index: indexPath!)
    }
    
    func setInfoFollowing(_ tag: String, _ index: IndexPath) {
        tagButton.setTitle(tag, for: UIControl.State.normal)
        indexPath = index
    }
}
