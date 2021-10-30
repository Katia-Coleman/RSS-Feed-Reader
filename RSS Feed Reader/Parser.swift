//
//  XMLParser.swift
//  Test
//
//  Created by Katia Coleman on 10/20/21.
//

import Foundation

struct fic  {
    var title: String
}

class feedParser: NSObject, XMLParserDelegate {
    var currentElement: String = ""
    var currentTitle: String = ""
    var currentFeed: URL! = URL(string: "")
    var fics: [fic] = []
    
    //shows if the element is opening or closing
    private var inSection: Bool = false
    
    override init() {
        
    }
    
    //sets the feed to a given string (of a url)
    func setFeed(_ feed: String) {
        let url: URL = URL(string: feed)!
        currentFeed = url
    }
    
    //sets up the parser
    func parse() {
        if let parser = XMLParser(contentsOf: currentFeed) {
        parser.delegate = self
        parser.parse()
        }
    }
    
    //Checks if the element is starting, then sets the current element name and marks it as an opening tag
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        inSection = true
        currentElement = elementName
    }
    
    //Checks if the element is ending, then marks it as a closing tag and if it is the end of the entry adds a fic object to the arrat of fics with the information found in the entry.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        inSection = false
        if elementName == "entry" {
            let addedFic = fic(title: currentTitle)
            fics.append(addedFic)
        }
    }
    
    //if the element is open sets the information in that element to the proper place
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if inSection {
            switch currentElement
            {
            case "title":
                currentTitle = data
            default:
                break
            }
        }
    }
    
}
