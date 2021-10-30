//
//  TableViewCell.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 10/30/21.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    //link to title label in table cell
    @IBOutlet weak var title: UILabel!
    
    //sets the information in the cell
    func setInfo(_ fic: fic) {
        title.text = fic.title
    }
}
