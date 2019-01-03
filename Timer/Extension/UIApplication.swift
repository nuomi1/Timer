//
//  UIApplication.swift
//  Timer
//
//  Created by nuomi1 on 14/10/2018.
//  Copyright © 2018 nuomi1. All rights reserved.
//

import UIKit

extension UIApplication {
    var navigationController: UINavigationController? {
        return keyWindow?.rootViewController as? UINavigationController
    }

    var splitViewController: UISplitViewController? {
        return keyWindow?.rootViewController as? UISplitViewController
    }

    var tabBarController: UITabBarController? {
        return keyWindow?.rootViewController as? UITabBarController
    }
}
