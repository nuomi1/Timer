//
//  Utils.swift
//  Timer
//
//  Created by nuomi1 on 20/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import Foundation

func debug(_ closure: () -> Void) {
    assert({
        closure()
        return true
    }())
}
