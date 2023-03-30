//
//  CryptoManager.swift
//  iCloudDocument
//
//  Created by imac on 2023/3/29.
//

import Foundation
import CryptoSwift

class CryptoManager {
    let key = "DarcyDarcyDarcyD"
    let iv = "1234567890123456"
    
    func classToStringData(message: MessageModel) -> Data? {
        let messageData = try? message.asDictionary()
        let jsonData = try? JSONSerialization.data(withJSONObject: messageData ?? [:], options: .prettyPrinted)
        let jsonToString = String(data: jsonData!, encoding: .utf8)
        let stringData = jsonToString?.data(using: .utf8)
        
        return stringData!
    }
    
    func jsonDataToModel(jsonData: Data) /*-> Codable*/ {
        do {
            let dictionary = try jsonData.asDictionary()
            print(dictionary)
        } catch {
            print(error)
        }
    }
    
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
