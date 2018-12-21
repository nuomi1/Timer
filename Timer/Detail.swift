//
//  Detail.swift
//  Timer
//
//  Created by nuomi1 on 13/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import Foundation
import SwifterSwift

enum Category: String, Codable, CaseIterable {
    case towel // 毛巾
    case underwear // 内衣
    case toothbrush // 牙刷
    case none // 空
}

struct Detail: Codable {
    var identify = UUID() // 唯一标记
    var title = String() // 标题
    var createTime = Date() // 创建时间
    var expireTime = Date() // 到期时间
    var barcode: Int? // 条形码
    var type: Category? // 商品类型
    var url: URL? // 购买链接
    var note: String? // 备注
}

extension Detail {
    static var `default`: Detail {
        return Detail(identify: UUID(), title: String(), createTime: Date().beginning(of: .day)!, expireTime: Date().adding(.day, value: 1).beginning(of: .day)!, barcode: nil, type: .none, url: nil, note: nil)
    }
}
