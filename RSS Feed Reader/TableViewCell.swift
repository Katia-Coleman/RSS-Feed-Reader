//
//  TableViewCell.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 10/30/21.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func clickStar(with isStarred: Bool, index indexPath: IndexPath)
}

class TableViewCell: UITableViewCell {
    
    var delegate: TableViewCellDelegate?
    
    var isStarred: Bool = false
    var indexPath: IndexPath?
    
    //link to title label in table cell
    @IBOutlet weak var title: UILabel!
    
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
        title.text = fic.title
        indexPath = index
    }
}
