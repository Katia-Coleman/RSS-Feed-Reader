//
//  SceneDelegate.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 10/22/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        if let urlContext = connectionOptions.urlContexts.first {
            let url = urlContext.url
            addFeed(url)
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            let url = urlContext.url
            addFeed(url)
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
    
    //adds a new RSS feed by clicking on the RSS feed button in ao3
    func addFeed (_ url: URL) {
        //initialize plist manager
        SwiftyPlistManager.shared.start(plistNames: ["SavedFics"], logging: false)
        var feeds: [String] = []
        var titles: [String] = []
        feeds = getSavedList("Following")
        //add the url to the list of followed urls
        var feed = url.absoluteString
        feed.removeFirst(5)
        feeds.append(feed)
        SwiftyPlistManager.shared.addNewOrSave(feeds, forKey: "Following", toPlistWithName: "SavedFics") {(err) in
        }
        //add the title of the feed to the list of followed tags
        titles = getSavedList("FeedTitles")
        let newFeed = feedParser()
        newFeed.setFeed(feed)
        newFeed.parse()
        titles.append(newFeed.channelTitle)
        SwiftyPlistManager.shared.addNewOrSave(titles, forKey: "FeedTitles", toPlistWithName: "SavedFics") {(err) in
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

