//
//  XMLParser.swift
//  Test
//
//  Created by Katia Coleman on 10/20/21.
//

import Foundation

struct fic: Codable  {
    var title: String
    var id: String
    var starFilled: Bool
    var summary: String
    var link: String
    var author: String
    
    
    func encode(_ currentFic: fic) -> Data {
        var cf = currentFic
        return Data(bytes: &cf, count: MemoryLayout<fic>.stride)
    }
    
    func decode(_ dataFic: Data) -> fic {
        guard dataFic.count == MemoryLayout<fic>.stride else {
            fatalError("error")
        }
        var decodedFic: fic?
        dataFic.withUnsafeBytes({(bytes: UnsafePointer<fic>) in
            //decodedFic = UnsafePointer<fic>(bytes).pointee
        })
        return decodedFic!
    }
}

class feedParser: NSObject, XMLParserDelegate {
    var currentElement: String = ""
    var currentTitle: String = ""
    var currentId: String = ""
    var currentFeed: URL! = URL(string: "")
    var currentLink: String = ""
    var attributes: [String: String] = [:]
    var currentSummary: String = ""
    var summaryElement: String = ""
    var summarySection: String = ""
    var fics: [fic] = []
    
    //shows if the element is opening or closing
    private var inSection: Bool = false
    private var inSubSection: Bool = false
    
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
        inSubSection = true
        currentElement = elementName
        
        switch currentElement {
        case "link":
            currentLink = attributeDict["href"]!
        default:
            break
        }
    }
    
    //Checks if the element is ending, then marks it as a closing tag and if it is the end of the entry adds a fic object to the arrat of fics with the information found in the entry.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == currentElement {
            inSubSection = false
            inSection = false
        }
        if elementName == "entry" {
            let addedFic = fic(title: currentTitle, id: currentId, starFilled: false, summary: currentSummary, link: currentLink, author: "")
            fics.append(addedFic)
            currentSummary = ""
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
            case "id":
                currentId = data
            case "summary":
                currentSummary += data
            default:
                break
            }
        }
    }
    
    //ensures parser exits
    func parserDidEndDocument(_ parser: XMLParser) {
        
    }
    
}

class summaryParser: NSObject, XMLParserDelegate {
    var currentElement: String = ""
    var currentTags: [String] = []
    var data: Data? = nil
    var currentSummary: String = ""
    var completeSummary: String = ""
    var currentAuthor: String = ""
    
    //shows if the element is opening or closing
    private var inSection: Bool = false
    private var inSubSection: Bool = false
    
    override init() {
        
    }
    
    //sets the feed to a given string (of a url)
    func setData(_ feed: String) {
        let xmlFeed = "<root>" + feed + "</root>"
        data = xmlFeed.data(using: .utf8)!
    }
    
    //sets up the parser
    func parse() {
        let parser = XMLParser(data: data!)
        parser.delegate = self
        parser.parse()
        
    }
    
    //Checks if the element is starting, then sets the current element name and marks it as an opening tag
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        inSection = true
        if elementName == "a" || elementName == "p" {
            inSubSection = true
        }
        currentElement = elementName
        if attributeDict["rel"] != nil {
            currentElement = "author"
        }
    }
    
    //Checks if the element is ending, then marks it as a closing tag and if it is the end of the entry adds a fic object to the arrat of fics with the information found in the entry.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == currentElement {
            inSection = false
        }
        if elementName == "a" || elementName == "p" {
            inSubSection = false
        }
    }
    
    //if the element is open sets the information in that element to the proper place
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if inSubSection {
            switch currentElement
            {
            case "a":
                currentTags.append(data)
            case "p":
                if data != "by" {
                currentSummary += "\n\n"
                currentSummary += data
                }
            case "author":
                currentAuthor = data
            default:
                break
            }
        }
    }
    
    //does code upon parser starting
    func parserDidStartDocument(_ parser: XMLParser) {
        currentSummary = ""
        completeSummary = ""
    }
    
    //does code uopn parser exiting
    func parserDidEndDocument(_ parser: XMLParser) {
        completeSummary += currentTags[0]
        currentTags.remove(at: 0)
        completeSummary += "\n"
        for tag in currentTags {
            completeSummary += tag
            completeSummary += ", "
        }
        completeSummary = String(completeSummary.dropLast())
        completeSummary = String(completeSummary.dropLast())
        completeSummary += currentSummary
    }
    
}
