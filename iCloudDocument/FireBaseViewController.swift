//
//  FireBaseViewController.swift
//  iCloudDocument
//
//  Created by imac on 2023/3/27.
//

import UIKit
import FirebaseDatabase

class FireBaseViewController: UIViewController {
    
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var personTextField: UITextField!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var listTableView: UITableView!
    
    var databaseRef: DatabaseReference!
    var messageList = [MessageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        databaseRef = Database.database().reference().child("messages")
        self.fetchMessageFromFirebase()
    }
    
    func setUI() {
        setTextView()
        setTextField()
        setTableView()
        
        overrideUserInterfaceStyle = .light
    }
    
    //    private func tryAES(message: MessageModel) {
    //        let cryptoManager = CryptoManager()
    //
    //        let messageData = cryptoManager.classToStringData(message: message)
    //        print(messageData! as NSData)
    //        let encryptData = cryptoManager.aesEncypt(messageData: messageData!)
    //        print(encryptData! as NSData)
    //        let encryptString = encryptData?.toHexString().uppercased()
    //
    //        let firebaseData = encryptString?.hexdecimal
    //        print(firebaseData! as NSData)
    //        let decryptData = cryptoManager.aesDecrypt(encryptData: firebaseData!)
    //        print(decryptData! as NSData)
    //        let decryptMessage = cryptoManager.jsonDataToModel(jsonData: decryptData!)
    //    }
    
    private func setTextView() {
        messageTextView.delegate = self
        messageTextView.returnKeyType = .done
    }
    
    private func setTextField() {
        personTextField.delegate = self
    }
    
    private func setTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil),
                               forCellReuseIdentifier: MessageTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 監聽Firebase狀況
        databaseRef.observe(.value) { snapshot in
            if let output = snapshot.value as? [String: Any] {
                print("\(output.count)")
            } else {
                print("0")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 移除監聽
        databaseRef.removeAllObservers()
    }
    
    func sendMessageToFirebase() {
        let cryptoManager = CryptoManager()
        let key = databaseRef.childByAutoId().key
        
        if personTextField.text == "" || messageTextView.text == "" {
            Alert.showAlertWith(title: "輸入不能為空",
                                message: "",
                                vc: self,
                                confirmTitle: "確認")
        } else {
            let message = MessageModel(id: key!,
                                       name: personTextField.text!,
                                       content: messageTextView.text!)
            let messageData = cryptoManager.classToStringData(message: message)
            let encryptData = cryptoManager.aesEncypt(messageData: messageData!)
            let encryptString = encryptData?.toHexString().uppercased()
            
            let data: [String: Any] = ["data": encryptString!,
                                       "timestamp": ServerValue.timestamp()]
            
            self.databaseRef.child("\(String(describing: key!))").setValue(data)
            
            Alert.showAlertWith(title: "送出",
                                message: "",
                                vc: self,
                                confirmTitle: "確認")
            
            self.personTextField.text = ""
            self.messageTextView.text = ""
        }
    }
    
    func fetchMessageFromFirebase() {
        let cryptoManager = CryptoManager()
        self.databaseRef.observe(.value) { snapshot in
            if(snapshot.childrenCount > 0) {
                self.messageList.removeAll()
                for firebaseMessages in snapshot.children.allObjects as! [DataSnapshot] {
                    let firebaseObject = firebaseMessages.value as? [String: Any]
                    let encryptString = firebaseObject?["data"] as! String
                    let decryptString = encryptString.hexdecimal
                    let decryptData = cryptoManager.aesDecrypt(encryptData: decryptString!)
                    do {
                        let jsonMessage = try JSONSerialization.jsonObject(with: decryptData!,
                                                                           options: []) as? [String : Any]
                        let messageId = jsonMessage?["id"]
                        let messageName = jsonMessage?["name"]
                        let messageContent = jsonMessage?["content"]
                        let message = MessageModel(id: messageId as! String,
                                                   name: messageName as! String,
                                                   content: messageContent as! String)
                        self.messageList.append(message)
                    } catch {
                        print(error.localizedDescription)
                    }
//                    let messageName = messageObject?["name"]
//                    let messageContent = messageObject?["content"]
//
//                    let message = MessageModel(id: messageID as! String,
//                                               name: messageName as! String,
//                                               content: messageContent as! String)
//
//                    self.messageList.append(message)
                }
                self.listTableView.reloadData()
            } else {
                self.messageList.removeAll()
                self.listTableView.reloadData()
            }
        }
    }
    
//    func getSystemTime() -> String {
//        let currentDate = Date()
//        let dateFormatter: DateFormatter = DateFormatter()
//
//        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
//        dateFormatter.locale = Locale.ReferenceType.system
//        dateFormatter.timeZone = TimeZone.ReferenceType.system
//
//        return dateFormatter.string(from: currentDate)
//    }
    
    @IBAction func sendMessage(_ sender: Any) {
        self.sendMessageToFirebase()
    }
}

extension FireBaseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier,
                                                 for: indexPath) as! MessageTableViewCell
        
        cell.personLabel.text = messageList[indexPath.row].name
        cell.messageLabel.text = messageList[indexPath.row].content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "刪除") { action, view, complete in
            self.databaseRef.child(self.messageList[indexPath.row].id).setValue(nil)
            complete(true)
        }
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
}

extension FireBaseViewController: UITextViewDelegate {
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

extension FireBaseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
