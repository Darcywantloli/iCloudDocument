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
    @IBOutlet weak var loadButton: UIButton!
    
    let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
    
    var documentURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupiCloudDocument()
    }
    
    func setupUI() {
        setupTextView()
    }
    
    private func setupiCloudDocument() {
        documentURL = containerURL?.appendingPathComponent("Documents/test.txt")
    }
    
    private func setupTextView() {
        documentTextView.delegate = self
        documentTextView.returnKeyType = .done
    }
    
    @IBAction func saveDocument(_ sender: Any) {
        if let url = documentURL {
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
    
    @IBAction func loadDocument(_ sender: Any) {
        if let documentPath = documentURL?.path {
            print(documentPath)
            if FileManager.default.fileExists(atPath: documentPath, isDirectory: nil) {
                if let dataBuffer = FileManager.default.contents(atPath: documentPath) {
                    let dataString = String(data: dataBuffer, encoding: .utf8)
                    documentLabel.text = dataString
                }
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
