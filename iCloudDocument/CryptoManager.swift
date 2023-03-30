//
//  CryptoManager.swift
//  iCloudDocument
//
//  Created by imac on 2023/3/29.
//

import Foundation
import CryptoSwift

class CryptoManager {
    
    // 加密用的key和iv
    let key = "DarcyDarcyDarcyD"
    let iv = "1234567890123456"
    
    // 資料轉換: MessageModel -> JSON -> String -> Data
    func classToStringData(message: MessageModel) -> Data? {
        let messageData = try? message.asDictionary()
        let jsonData = try? JSONSerialization.data(withJSONObject: messageData ?? [:], options: .prettyPrinted)
        let jsonToString = String(data: jsonData!, encoding: .utf8)
        let stringData = jsonToString?.data(using: .utf8)
        
        return stringData!
    }
    
    // 加密用: 對Bytes加密 -> Bytes轉Data
    func aesEncypt(messageData: Data) -> Data? {
        do {
            let aes = try AES(key: key, iv: iv)
            let encryptBytes = try aes.encrypt(messageData.bytes)
            let encryptData = Data(encryptBytes)
            
            return encryptData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // 解密用: 對Bytes解密 -> Bytes轉Data
    func aesDecrypt(encryptData: Data) -> Data? {
        do {
            let aes = try AES(key: key, iv: iv)
            let decryptBytes = try aes.decrypt(encryptData.bytes)
            let decryptData = Data(decryptBytes)
            
            return decryptData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
