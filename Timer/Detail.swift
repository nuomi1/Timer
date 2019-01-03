//
//  Detail.swift
//  Timer
//
//  Created by nuomi1 on 13/8/18.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import Foundation
import SwifterSwift
import WCDBSwift

enum Category: String, Codable, CaseIterable {
    case towel // 毛巾
    case underwear // 内衣
    case toothbrush // 牙刷
    case none // 空
}

extension Category: ColumnCodable {
    static var columnType: ColumnType {
        return .text
    }

    init?(with value: FundamentalValue) {
        self.init(rawValue: value.stringValue)
    }

    func archivedValue() -> FundamentalValue {
        return FundamentalValue(rawValue)
    }
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

extension Detail: TableCodable {
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Detail

        case identify
        case title
        case createTime
        case expireTime
        case barcode
        case type
        case url
        case note

        static var objectRelationalMapping = TableBinding(CodingKeys.self)
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                identify: .init(isPrimary: true),
            ]
        }
    }
}

extension Detail {
    static var `default`: Detail {
        return Detail(identify: UUID(), title: String(), createTime: Date().beginning(of: .day)!, expireTime: Date().adding(.day, value: 1).beginning(of: .day)!, barcode: nil, type: Category.none, url: nil, note: nil)
    }
}

extension UUID: ColumnCodable {
    public static var columnType: ColumnType {
        return .text
    }

    public init?(with value: FundamentalValue) {
        self.init(uuidString: value.stringValue)
    }

    public func archivedValue() -> FundamentalValue {
        return FundamentalValue(uuidString)
    }
}
