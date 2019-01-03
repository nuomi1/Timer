//
//  Utils.swift
//  Timer
//
//  Created by nuomi1 on 20/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import Foundation
import Reusable
import WCDBSwift

// MARK: - debug

func debug(_ closure: () -> Void) {
    assert({
        closure()
        return true
    }())
}

// MARK: - WCDB

let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
let fileURL = documentDirectory.appendingPathComponent(R.string.localizable.databaseFilename())
let wcdb = Database(withFileURL: fileURL)

// MARK: - Reusable

extension UITableViewCell: Reusable {}
