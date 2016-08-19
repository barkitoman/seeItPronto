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
    
    private let kTimeoutInSeconds:NSTimeInterval = 8
    private var loadMessagesTimer: NSTimer?
    
    private let sizingCell = LGChatMessageCell()
    var opponentImage: UIImage?
    
    private struct Constants {
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
        print(lastToMessageDate)
        self.txtMessage.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None 
        // Keep message field visible
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil
        )
        // Hide keyboard on tap
        let taps = UITapGestureRecognizer( target: self, action: "handleSingleTap:" )
        taps.numberOfTapsRequired = 1
        self.view.addGestureRecognizer( taps )
        
        // Format message field
        self.txtMessage.leftViewMode = UITextFieldViewMode.Always
        self.txtMessage.leftView = UIView( frame: CGRect( x: 0, y: 0, width: 10, height: 35 ) )
        self.txtMessage.layer.masksToBounds = true
        self.txtMessage.layer.borderColor = UIColor( red: 0, green: 0, blue: 0, alpha: 0.20 ).CGColor
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
        NSNotificationCenter.defaultCenter().removeObserver( self )
    }
    
    // Animate message field to accomodate for keyboard
    func animateViewMoving( up: Bool, move: CGFloat ) {
        dispatch_async(dispatch_get_main_queue()) {
            self.chatContent.setContentOffset(CGPointMake(0,  up ? ( 0 - move ) : move ), animated: true)
        }
    }
    
    // Handler for tap outside keyboard
    func handleSingleTap( recognizer: UITapGestureRecognizer ) {
        self.view.endEditing( true )
    }
    
    // Handler to put field back when done editing
    func keyboardWillHide( notification: NSNotification ) {
        dispatch_async(dispatch_get_main_queue()) {
            self.chatContent.setContentOffset(CGPointMake(0, 0), animated: true)
        }
    }
    
    // Handler to keep field visible when editing
    func keyboardWillShow( notification: NSNotification ) {
        self.chatContent.setContentOffset(CGPointMake(0, 270), animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBarHidden = false
        }
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func scrollToBottom() {
        if messages.count > 0 {
            var lastItemIdx = self.tableView.numberOfRowsInSection(Constants.MessagesSection) - 1
            if lastItemIdx < 0 {
                lastItemIdx = 0
            }
            let lastIndexPath = NSIndexPath(forRow: lastItemIdx, inSection: Constants.MessagesSection)
            self.tableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: false)
        }
    }
    
    func addNewMessage(message: LGChatMessage) {
        messages += [message]
        tableView.reloadData()
        self.scrollToBottom()
    }
    
    @IBAction func btnSend(sender: AnyObject) {
        let message = self.txtMessage.text!
        if(!message.isEmpty) {
            let newMessage = LGChatMessage(content: self.txtMessage.text!, sentBy: .User)
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let padding: CGFloat = 10.0
        sizingCell.bounds.size.width = CGRectGetWidth(self.view.bounds)
        let height = self.sizingCell.setupWithMessage(messages[indexPath.row]).height + padding;
        return height
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! LGChatMessageCell
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
    
    func loadConversations(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
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
        self.loadMessagesTimer = NSTimer.scheduledTimerWithTimeInterval(kTimeoutInSeconds,
            target:self,
            selector:Selector("findNewMessages"),
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
    
    func loadNewMessages(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
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
