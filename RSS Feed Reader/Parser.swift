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
    var feedName: String
    var dateUpdated: Date
    
    
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
    var currentDateUpdated: Date = Date()
    var attributes: [String: String] = [:]
    var currentSummary: String = ""
    var summaryElement: String = ""
    var summarySection: String = ""
    var fics: [fic] = []
    
    var channelTitle: String = ""
    
    //shows if the element is opening or closing
    private var inSection: Bool = false
    private var inSubSection: Bool = false
    private var inBeginning: Bool = true
    
    override init() {
        
    }
    
    //sets the feed to a given string (of a url)
    func setFeed(_ feed: String) {
        let url: URL = URL(string: feed)!
        currentFeed = url
    }
    
    //sets the feed to a given url
    func setFeedWithUrl(_ feed: URL) {
        currentFeed = feed
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
        case "entry":
            inBeginning = false
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
            let addedFic = fic(title: currentTitle, id: currentId, starFilled: false, summary: currentSummary, link: currentLink, author: "", feedName: channelTitle, dateUpdated: currentDateUpdated)
            fics.append(addedFic)
            //print(currentSummary)
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
            case "updated":
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                currentDateUpdated = formatter.date(from: data)!
            default:
                break
            }
        }
        
        if inBeginning {
            switch currentElement {
            case "title":
                //print("data: \(data)")
                channelTitle += data
            default:
                break
            }
        }
    }
    
    //ensures parser exits
    func parserDidEndDocument(_ parser: XMLParser) {
        if let range = channelTitle.range(of: "AO3 works tagged '") {
           channelTitle.removeSubrange(range)
        }
        channelTitle.remove(at: channelTitle.index(before: channelTitle.endIndex))
    }
}

class summaryParser: NSObject, XMLParserDelegate {
    var currentElement: String = ""
    var data: Data? = nil
    var currentSummary: String = ""
    var completeSummary: String = ""
    var currentAuthor: String = ""
    var currentSection: String = ""
    var itemsInSummary: [String : Array<String>] = [:]
    var summaryPartName: String = ""
    var incompleteString: String = ""
    
    var currentTags: [String] = []
    var fandoms: [String] = []
    var rating: String = ""
    var warnings: [String] = []
    var categories: [String] = []
    var characters: [String] = []
    var relationships: [String] = []
    
    var channelTitle: String = ""
    
    //shows if the element is opening or closing
    private var inSection: Bool = false
    private var inSubSection: Bool = false
    private var inList: Bool = false
    
    override init() {
        
    }
    
    //sets the feed to a given string (of a url)
    func setData(_ feed: String) {
        let xmlFeed = "<root>" + feed + "</root>"
        data = xmlFeed.data(using: .utf8)!
    }
    
    //sets the feed to a given string (of a url)
    func setFeed(_ feed: String) {
        data = feed.data(using: .utf8)!
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
        if elementName == "li" {
            inList = true
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
        if elementName == "li" {
            inList = false
            //itemsInSummary[summaryPartName] = currentTags
            //currentTags.removeAll()
        }
        if elementName == "a" {
            switch currentSection {
            case "Fandoms:":
                fandoms.append(incompleteString)
            case "Rating:":
                rating = incompleteString
            case "Warnings:":
                warnings.append(incompleteString)
            case "Categories:":
                categories.append(incompleteString)
            case "Characters:":
                characters.append(incompleteString)
            case "Relationships:":
                relationships.append(incompleteString)
            case "Additional Tags:":
                currentTags.append(incompleteString)
            default:
                break
            }
            incompleteString = ""
        }
    }
    
    //if the element is open sets the information in that element to the proper place
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //print("\(currentElement): \(data)")
        if inSubSection {
            switch currentElement
            {
            case "a":
                incompleteString += data
                //currentTags.append(data)
            case "p":
                if data != "by" {
                currentSummary += "\n\n"
                currentSummary += data
                }
            case "author":
                currentAuthor = data
            case "li":
                print(data)
                currentSection = data
            default:
                break
            }
        }
        else if inList {
            if data != "," {
                currentSection = data
            }
        }
    }
    
    //does code upon parser starting
    func parserDidStartDocument(_ parser: XMLParser) {
        currentSummary = ""
        completeSummary = ""
    }
    
    //lists out each of the tags in the section given
    func listTags(_ list: [String]) {
        for tag in list {
            completeSummary += tag
            completeSummary += ", "
        }
        completeSummary = String(completeSummary.dropLast())
        completeSummary = String(completeSummary.dropLast())
    }
    
    //does code uopn parser exiting
    func parserDidEndDocument(_ parser: XMLParser) {
        
        //completeSummary += currentTags[0]
        //currentTags.remove(at: 0)
        //completeSummary += "\n"
        listTags(fandoms)
        completeSummary += "\n"
        listTags(warnings)
        completeSummary += ", "
        listTags(relationships)
        completeSummary += ", "
        listTags(characters)
        completeSummary += ", "
        listTags(currentTags)
        completeSummary += currentSummary
        
    }
    
}
