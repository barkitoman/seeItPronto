//
//  CustomPickerDialog.swift
//
//  Created by hwj4477 on 2016. 3. 16..
//

import UIKit

class CustomPickerDialog: UIView {

    typealias CustomPickerCallback = (result: String) -> Void
    
    // constants
    private let componentNum: Int = 1
    
    private let titleHeight: CGFloat = 30
    private let buttonHeight: CGFloat = 50
    private let doneButtonTag: Int = 1
    
    // view
    private var dialogView:   UIView!
    private var titleLabel:   UILabel!
    private var pickerView: UIPickerView!
    
    private var cancelButton: UIButton!
    private var doneButton:   UIButton!
    
    // callback
    private var callback: CustomPickerCallback?
    
    // data
    private var dataSelcted: String?
    private var dataSource = [String]()
    
    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        
        initView()
    }
    
    init(dataSource: [String]) {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        
        initView()
        setDataSource(dataSource)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    private func initView() {
        
        self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        self.dialogView = createDialogView()
        
        self.addSubview(self.dialogView!)
    }
    
    private func createDialogView() -> UIView {
        
        let dialogSize = CGSizeMake(300, 250 + buttonHeight)
        
        let dialogContainer = UIView(frame: CGRectMake((self.frame.size.width - dialogSize.width) / 2, (self.frame.size.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height))
        
        dialogContainer.backgroundColor = UIColor.whiteColor()
        dialogContainer.layer.shouldRasterize = true
        dialogContainer.layer.rasterizationScale = UIScreen.mainScreen().scale
        dialogContainer.layer.cornerRadius = 7
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).CGColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = 12
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSizeMake(-6, -6)
        dialogContainer.layer.shadowColor = UIColor.blackColor().CGColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).CGPath
        
        //Title
        self.titleLabel = UILabel(frame: CGRectMake(10, 10, 280, titleHeight))
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.font = UIFont.boldSystemFontOfSize(17)
        dialogContainer.addSubview(self.titleLabel)
        
        // PickerView
        pickerView = UIPickerView.init(frame: CGRectMake(0, titleHeight, dialogSize.width, dialogSize.height - buttonHeight - 10))
        pickerView.delegate = self
        
        dialogContainer.addSubview(pickerView)
        
        // Line
        let lineView = UIView(frame: CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight, dialogContainer.bounds.size.width, 1))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        
        // Button
        let buttonWidth = dialogContainer.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.cancelButton.frame = CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)
        self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.cancelButton.layer.cornerRadius = 7
        self.cancelButton.addTarget(self, action: "clickButton:", forControlEvents: UIControlEvents.TouchUpInside)

        dialogContainer.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.doneButton.tag = doneButtonTag
        self.doneButton.frame = CGRectMake(buttonWidth, dialogContainer.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)
        self.doneButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.doneButton.layer.cornerRadius = 7
        self.doneButton.addTarget(self, action: "clickButton:", forControlEvents: UIControlEvents.TouchUpInside)
        dialogContainer.addSubview(self.doneButton)
        
        self.doneButton.setTitle("OK", forState: .Normal)
        self.cancelButton.setTitle("Cancel", forState: .Normal)

        return dialogContainer
    }
    
    // MARK: public func
    func setDataSource(source: [String]) {
        
        self.dataSource = source
        
        dataSelcted = self.dataSource[0]
    }
    
    func selectRow(row: Int) {

        self.dataSelcted = self.dataSource[row]
        
        self.pickerView.selectRow(row, inComponent: 0, animated: true)
    }
    
    func selectValue(value: String) {
        
        var index: Int = 0
        
        for i in 0...self.dataSource.count-1 {
            let val = self.dataSource[i]
            
            if(val == value) {
                self.dataSelcted = val
                index = i
                break;
            }
        }
        
        self.pickerView.selectRow(index, inComponent: 0, animated: true)
    }
    
    func showDialog(title: String, doneButtonTitle: String = "OK", cancelButtonTitle: String = "Cancel", callback: CustomPickerCallback) {
        
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, forState: .Normal)
        self.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        self.callback = callback
        
        UIApplication.sharedApplication().windows.first!.addSubview(self)
        UIApplication.sharedApplication().windows.first!.endEditing(true)
        
        // Animation
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    func close() {
        
        // Animation
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
                self.dialogView!.layer.opacity = 0.1
                self.dialogView!.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            }) { (finished: Bool) -> Void in
                
                self.removeFromSuperview()
        }
    }
    
    // MARK: Button Event
    func clickButton(sender: UIButton!) {
        if sender.tag == doneButtonTag {
            
            self.callback?(result: dataSelcted!)
        }
        
        close()
    }
}

extension CustomPickerDialog: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return componentNum
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.dataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        dataSelcted = self.dataSource[row]
    }
}