//
//  BackgroundTask.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 11/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit

class BackgroundTask {
    private let application: UIApplication
    private var identifier = UIBackgroundTaskIdentifier.invalid

    init(application: UIApplication) {
        self.application = application
    }

    class func run(application: UIApplication, handler: (BackgroundTask) -> ()) {
        // NOTE: The handler must call end() when it is done

        let backgroundTask = BackgroundTask(application: application)
        backgroundTask.begin()
        handler(backgroundTask)
    }

    func begin() {
        self.identifier = application.beginBackgroundTask {
            self.end()
        }
    }

    func end() {
        if (identifier != UIBackgroundTaskIdentifier.invalid) {
            application.endBackgroundTask(identifier)
        }

        identifier = UIBackgroundTaskIdentifier.invalid
    }
}
