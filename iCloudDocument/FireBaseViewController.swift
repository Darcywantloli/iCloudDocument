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
        
        // 點空白處收鍵盤
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // 設定Firebase參考路徑
        databaseRef = Database.database().reference().child("messages")
        self.fetchMessageFromFirebase()
    }
    
    func setUI() {
        setLabel()
        setButton()
        setTextView()
        setTextField()
        setTableView()
        
        overrideUserInterfaceStyle = .light
    }
    
    private func setLabel() {
        personLabel.text = NSLocalizedString("message person", comment: "")
        messageLabel.text = NSLocalizedString("message content", comment: "")
    }
    
    private func setButton() {
        sendButton.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
    }
    
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
    
    // 將資料上傳到Firebase
    func sendMessageToFirebase() {
        let cryptoManager = CryptoManager()
        
        // 隨機產生一把key
        let key = databaseRef.childByAutoId().key
        
        // 阻擋空白輸入
        if personTextField.text == "" || messageTextView.text == "" {
            Alert.showAlertWith(title: NSLocalizedString("input can not be empty", comment: ""),
                                message: "",
                                vc: self,
                                confirmTitle: NSLocalizedString("confirm", comment: ""))
        } else {
            
            // 將輸入的資料做加密
            let message = MessageModel(id: key!,
                                       name: personTextField.text!,
                                       content: messageTextView.text!)
            
            let messageData = cryptoManager.classToStringData(message: message)
            let encryptData = cryptoManager.aesEncypt(messageData: messageData!)
            let encryptString = encryptData?.toHexString().uppercased()
            
            // 將加密後的資料以及時間戳上傳
            let data: [String: Any] = ["data": encryptString!,
                                       "timestamp": ServerValue.timestamp()]
            
            self.databaseRef.child("\(String(describing: key!))").setValue(data)
            
            Alert.showAlertWith(title: NSLocalizedString("send", comment: ""),
                                message: "",
                                vc: self,
                                confirmTitle: NSLocalizedString("confirm", comment: ""))
            
            self.personTextField.text = ""
            self.messageTextView.text = ""
        }
    }
    
    // 取得Firebase裡的資料
    func fetchMessageFromFirebase() {
        let cryptoManager = CryptoManager()
        
        self.databaseRef.observe(.value) { snapshot in
            if(snapshot.childrenCount > 0) {
                
                // 取得前先清空本地資料
                self.messageList.removeAll()
                
                // 對每一筆資料解密後存回本地
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
                }
                self.listTableView.reloadData()
            } else {
                self.messageList.removeAll()
                self.listTableView.reloadData()
            }
        }
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
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
    
    // 左滑刪除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: NSLocalizedString("delete", comment: "")) { action, view, complete in
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
