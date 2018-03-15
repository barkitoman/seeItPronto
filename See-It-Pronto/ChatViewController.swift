//
//  ChatViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 7/15/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, LGChatControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    
    @IBOutlet weak var chatContent: UIScrollView!
    
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    var animateDistance: CGFloat!
    var messages: [LGChatMessage] = []
    var from = ""
    var to   = "2"
    var lastToMessageDate = ""
    var oponentImageName  = ""
    var isTheFirstMessage = true
    var isFromPushNotification = false
    
    fileprivate let kTimeoutInSeconds:TimeInterval = 5
    fileprivate var loadMessagesTimer: Timer?
    
    fileprivate let sizingCell = LGChatMessageCell()
    var opponentImage: UIImage?
    
    fileprivate struct Constants {
        static let MessagesSection: Int = 0;
        static let MessageCellIdentifier: String = "LGChatController.Constants.MessageCellIdentifier"
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.from = User().getField("id")
        self.lastToMessageDate = "\(Utility().getCurrentDate()) \(Utility().getTime())"
        self.findConversation()
        self.internalNewMessages()
        self.txtMessage.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none 
        // Keep message field visible
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ChatViewController.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ChatViewController.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        // Hide keyboard on tap
        let taps = UITapGestureRecognizer( target: self, action: #selector(ChatViewController.handleSingleTap(_:)) )
        taps.numberOfTapsRequired = 1
        self.view.addGestureRecognizer( taps )
        
        // Format message field
        self.txtMessage.leftViewMode = UITextFieldViewMode.always
        self.txtMessage.leftView = UIView( frame: CGRect( x: 0, y: 0, width: 10, height: 35 ) )
        self.txtMessage.layer.masksToBounds = true
        self.txtMessage.layer.borderColor = UIColor( red: 0, green: 0, blue: 0, alpha: 0.20 ).cgColor
        self.txtMessage.layer.borderWidth = 1.0
        self.txtMessage.delegate = self
        self.txtMessage.attributedPlaceholder = NSAttributedString(
            string: "  Enter message here.",
            attributes: [
                NSForegroundColorAttributeName: UIColor( red: 0, green: 0, blue: 0, alpha: 0.40 )
            ]
        )
        if(self.isFromPushNotification == true){
            self.isTheFirstMessage = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver( self )
    }
    
    // Animate message field to accomodate for keyboard
    func animateViewMoving( _ up: Bool, move: CGFloat ) {
        DispatchQueue.main.async {
            self.chatContent.setContentOffset(CGPoint(x: 0,  y: up ? ( 0 - move ) : move ), animated: true)
        }
    }
    
    // Handler for tap outside keyboard
    func handleSingleTap( _ recognizer: UITapGestureRecognizer ) {
        self.view.endEditing( true )
    }
    
    // Handler to put field back when done editing
    func keyboardWillHide( _ notification: Foundation.Notification ) {
        DispatchQueue.main.async {
            self.chatContent.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // Handler to keep field visible when editing
    func keyboardWillShow( _ notification: Foundation.Notification ) {
        self.chatContent.setContentOffset(CGPoint(x: 0, y: 270), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        if(User().getField("id") != "") {
            User().updateField("current_chat", value: self.to)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.isNavigationBarHidden = false
        }
        super.viewWillDisappear(animated)
        if(User().getField("id") != "") {
            User().updateField("current_chat", value: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func scrollToBottom() {
        if messages.count > 0 {
            var lastItemIdx = self.tableView.numberOfRows(inSection: Constants.MessagesSection) - 1
            if lastItemIdx < 0 {
                lastItemIdx = 0
            }
            let lastIndexPath = IndexPath(row: lastItemIdx, section: Constants.MessagesSection)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
    }
    
    func addNewMessage(_ message: LGChatMessage) {
        messages += [message]
        tableView.reloadData()
        self.scrollToBottom()
    }
    
    @IBAction func btnSend(_ sender: AnyObject) {
        let message = self.txtMessage.text!
        if(!message.isEmpty) {
            let newMessage = LGChatMessage(content: self.txtMessage.text!, sentByString: .User)
            self.addNewMessage(newMessage)
            self.saveMessage()
            self.txtMessage.text = ""
            self.isTheFirstMessage = false
        }
    }
    
    func saveMessage(){
        let params = "from_user_id=\(self.from)&to_user_id=\(self.to)&message=\(self.txtMessage.text!)&is_first_message=\(self.isTheFirstMessage))"
        let url = AppConfig.APP_URL+"/messages"
        Request().post(url, params: params, controller: self) { (response) -> Void in
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        let padding: CGFloat = 10.0
        sizingCell.bounds.size.width = self.view.bounds.width
        let height = self.sizingCell.setupWithMessage(messages[indexPath.row]).height + padding;
        return height
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LGChatMessageCell
        let message = self.messages[indexPath.row]
        cell.opponentImageView.image = message.sentBy == .Opponent ? self.opponentImage : nil
        cell.setupWithMessage(message)
        return cell;
    }
    
    func findConversation() {
        let url    = AppConfig.APP_URL+"/find_conversation"
        let params = "from=\(self.from)&to=\(self.to)"
        Request().post(url, params: params, controller: self) { (response) -> Void in
            self.loadConversations(response);
        }
    }
    
    func loadConversations(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            if(result["result"].stringValue == "true") {
                for (_,subJson):(String, JSON) in result["messages"] {
                    if(subJson["from_user_id"].stringValue == self.from) {
                        let newMessage = LGChatMessage(content: subJson["message"].stringValue, sentBy: .User)
                        self.addNewMessage(newMessage)
                    } else {
                        self.lastToMessageDate = subJson["created_at"].stringValue
                        let newMessage = LGChatMessage(content: subJson["message"].stringValue, sentBy: .Opponent)
                        self.addNewMessage(newMessage)
                    }
                }
            }
        }
    }
    
    //interval for call new messages
    func internalNewMessages() {
        self.loadMessagesTimer = Timer.scheduledTimer(timeInterval: kTimeoutInSeconds,
            target:self,
            selector:#selector(ChatViewController.findNewMessages),
            userInfo:nil,
            repeats:true)
    }
    
    func stopInterval() {
        self.loadMessagesTimer!.invalidate()
    }
    
    func findNewMessages() {
        self.stopInterval()
        let url    = AppConfig.APP_URL+"/find_new_messages"
        let params = "from=\(self.from)&to=\(self.to)&date=\(self.lastToMessageDate)"
        Request().post(url, params: params, controller: self) { (response) -> Void in
            self.loadNewMessages(response);
        }
    }
    
    func loadNewMessages(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            if(result["result"].stringValue == "true") {
                for (_,subJson):(String, JSON) in result["messages"] {
                    self.lastToMessageDate = subJson["created_at"].stringValue
                    let newMessage = LGChatMessage(content: subJson["message"].stringValue, sentBy: .Opponent)
                    self.addNewMessage(newMessage)
                }
            }
            self.internalNewMessages()
        }
    }

}
