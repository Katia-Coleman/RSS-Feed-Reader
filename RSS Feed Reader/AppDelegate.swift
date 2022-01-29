//
//  AppDelegate.swift
//  RSS Feed Reader
//
//  Created by Katia Coleman on 10/22/21.
//

import UIKit
import BackgroundTasks


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var count: Int = 0


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //refresh upon opening the app
        let view = ViewController()
        view.getSavedFics("HomeFics")
        view.refresh()
        
        //register the background tasks
        registerBackgroundTasks()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)

        return true
    }
    
    //registers the background tasks
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.SO.apprefresh", using: nil) {task in
           print("BackgroundAppRefreshTaskScheduler is executed NOW!")
           print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
           task.expirationHandler = {
             task.setTaskCompleted(success: false)
           }

           // Do some data fetching and call setTaskCompleted(success:) asap!
           let isFetchingSuccess = true
           task.setTaskCompleted(success: isFetchingSuccess)
            //self.handleRefresh(task: task as! BGAppRefreshTask)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @objc func applicationDidEnterBackground() {
        submitBackgroundTasks()
    }
    
    func submitBackgroundTasks() {
        // Declared at the "Permitted background task scheduler identifiers" in info.plist
        let backgroundAppRefreshTaskSchedulerIdentifier = "com.SO.apprefresh"
        let timeDelay = 10.0

        do {
        let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: backgroundAppRefreshTaskSchedulerIdentifier)
        backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
        try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
            print("Submitted task request")
        } catch {
            print("Failed to submit BGTask")
            print(error)
        }
    }
}


extension AppDelegate {
    //the execution of the refresh
    func handleRefresh(task: BGAppRefreshTask) {
        print("handler")
        scheduleRefresh()
        refreshOperation()
        
        //handles the code for when the task exceeds 30 seconds (the time limit)
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            print("timed out")
            return
        }
        
        task.setTaskCompleted(success: true)
    }
    
    //schedules the fequency with which the task is executed
    func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "idk.RSS-Feed-Reader.appRefresh")
        print("schedule")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5)
        do {
          try BGTaskScheduler.shared.submit(request)
        }
        catch {
            print(error)
        }
    }
    
    //the function being called in the refresh
    //will be checking for new fanfics from the website and adding them to the saved fics
    func refreshOperation() {
        print(self.count)
        self.count += 1
    }
}

//an extension to deal with the opening of an RSS feed in the app
extension AppDelegate {
    //called when an URL is opened in the app
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Open")
        return true
    }
}
