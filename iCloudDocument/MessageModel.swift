//
//  MessageModel.swift
//  iCloudDocument
//
//  Created by imac on 2023/3/27.
//

import Foundation

// 資料型態
struct MessageModel: Encodable {
    var id: String
    var name: String
    var content: String
}
