//
//  iCloudDocumentViewController.swift
//  iCloudDocument
//
//  Created by imac on 2023/3/17.
//

import UIKit

class iCloudDocumentViewController: UIViewController {
    
    @IBOutlet weak var documentTextView: UITextView!
    @IBOutlet weak var documentLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!

    private let fileManager = FileManager.default
    private let filename = "test.txt"
    
    var iCloudDocumentURL: URL?
    var localDocumentURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 16.0,  *) {
            localDocumentURL = fileManager.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0].appending(path: filename)
            iCloudDocumentURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appending(path: "Documents/\(filename)")
        } else {
            localDocumentURL = fileManager.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0].appendingPathComponent(filename)
            iCloudDocumentURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents/\(filename)")
        }
        
        setupUI()
    }
    
    func setupUI() {
        setupTextView()
    }
    
    private func setupTextView() {
        documentTextView.delegate = self
        documentTextView.returnKeyType = .done
    }

    @IBAction func saveToLocal(_ sender: Any) {
        if let url = localDocumentURL {
            do {
                try documentTextView.text.write(to: url,
                                                atomically: true,
                                                encoding: .utf8)
                print(url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // 儲存內容上iCloud
    @IBAction func uploadToDocument(_ sender: Any) {
        if let localDocumentPath = localDocumentURL?.path {
            if let iCloudDocumentPath = iCloudDocumentURL?.path {
                if fileManager.fileExists(atPath: iCloudDocumentPath, isDirectory: nil) {
                    try! fileManager.removeItem(atPath: iCloudDocumentPath)
                    try! fileManager.copyItem(atPath: localDocumentPath, toPath: iCloudDocumentPath)
                } else {
                    try! fileManager.copyItem(atPath: localDocumentPath, toPath: iCloudDocumentPath)
                }
            }
        }
    }
    
    // 讀取iCloud裡的文件
    @IBAction func loadFormDocument(_ sender: Any) {
        if let documentPath = iCloudDocumentURL?.path {
            print(documentPath)
            
            // 判斷文件裡的檔案存不存在
            if fileManager.fileExists(atPath: documentPath, isDirectory: nil) {
                
                // 取的文件裡的內容
                if let dataBuffer = fileManager.contents(atPath: documentPath) {
                    
                    // 顯示內容在Label
                    let dataString = String(data: dataBuffer, encoding: .utf8)
                    documentLabel.text = dataString
                }
            } else {
                print("no document")
            }
        }
    }
}

extension iCloudDocumentViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            self.view.endEditing(false)
            return false
        }
        return true
    }
}
