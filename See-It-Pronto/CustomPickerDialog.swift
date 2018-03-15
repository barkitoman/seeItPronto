//
//  CustomPickerDialog.swift
//
//  Created by hwj4477 on 2016. 3. 16..
//

import UIKit

class CustomPickerDialog: UIView {

    typealias CustomPickerCallback = (_ result: String) -> Void
    
    // constants
    fileprivate let componentNum: Int = 1
    
    fileprivate let titleHeight: CGFloat = 30
    fileprivate let buttonHeight: CGFloat = 50
    fileprivate let doneButtonTag: Int = 1
    
    // view
    fileprivate var dialogView:   UIView!
    fileprivate var titleLabel:   UILabel!
    fileprivate var pickerView: UIPickerView!
    
    fileprivate var cancelButton: UIButton!
    fileprivate var doneButton:   UIButton!
    
    // callback
    fileprivate var callback: CustomPickerCallback?
    
    // data
    fileprivate var dataSelcted: String?
    fileprivate var dataSource = [String]()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        initView()
    }
    
    init(dataSource: [String]) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        initView()
        setDataSource(dataSource)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    fileprivate func initView() {
        
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.dialogView = createDialogView()
        
        self.addSubview(self.dialogView!)
    }
    
    fileprivate func createDialogView() -> UIView {
        
        let dialogSize = CGSize(width: 300, height: 250 + buttonHeight)
        
        let dialogContainer = UIView(frame: CGRect(x: (self.frame.size.width - dialogSize.width) / 2, y: (self.frame.size.height - dialogSize.height) / 2, width: dialogSize.width, height: dialogSize.height))
        
        dialogContainer.backgroundColor = UIColor.white
        dialogContainer.layer.shouldRasterize = true
        dialogContainer.layer.rasterizationScale = UIScreen.main.scale
        dialogContainer.layer.cornerRadius = 7
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = 12
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSize(width: -6, height: -6)
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).cgPath
        
        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 280, height: titleHeight))
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        dialogContainer.addSubview(self.titleLabel)
        
        // PickerView
        pickerView = UIPickerView.init(frame: CGRect(x: 0, y: titleHeight, width: dialogSize.width, height: dialogSize.height - buttonHeight - 10))
        pickerView.delegate = self
        
        dialogContainer.addSubview(pickerView)
        
        // Line
        let lineView = UIView(frame: CGRect(x: 0, y: dialogContainer.bounds.size.height - buttonHeight, width: dialogContainer.bounds.size.width, height: 1))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        
        // Button
        let buttonWidth = dialogContainer.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButtonType.custom) as UIButton
        self.cancelButton.frame = CGRect(x: 0, y: dialogContainer.bounds.size.height - buttonHeight, width: buttonWidth, height: buttonHeight)
        self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), for: UIControlState())
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: UIControlState.highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.cancelButton.layer.cornerRadius = 7
        self.cancelButton.addTarget(self, action: #selector(CustomPickerDialog.clickButton(_:)), for: UIControlEvents.touchUpInside)

        dialogContainer.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: UIButtonType.custom) as UIButton
        self.doneButton.tag = doneButtonTag
        self.doneButton.frame = CGRect(x: buttonWidth, y: dialogContainer.bounds.size.height - buttonHeight, width: buttonWidth, height: buttonHeight)
        self.doneButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), for: UIControlState())
        self.doneButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), for: UIControlState.highlighted)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        self.doneButton.layer.cornerRadius = 7
        self.doneButton.addTarget(self, action: #selector(CustomPickerDialog.clickButton(_:)), for: UIControlEvents.touchUpInside)
        dialogContainer.addSubview(self.doneButton)
        
        self.doneButton.setTitle("OK", for: UIControlState())
        self.cancelButton.setTitle("Cancel", for: UIControlState())

        return dialogContainer
    }
    
    // MARK: public func
    func setDataSource(_ source: [String]) {
        
        self.dataSource = source
        
        dataSelcted = self.dataSource[0]
    }
    
    func selectRow(_ row: Int) {

        self.dataSelcted = self.dataSource[row]
        
        self.pickerView.selectRow(row, inComponent: 0, animated: true)
    }
    
    func selectValue(_ value: String) {
        
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
    
    func showDialog(_ title: String, doneButtonTitle: String = "OK", cancelButtonTitle: String = "Cancel", callback: @escaping CustomPickerCallback) {
        
        self.titleLabel.text = title
        self.doneButton.setTitle(doneButtonTitle, for: UIControlState())
        self.cancelButton.setTitle(cancelButtonTitle, for: UIControlState())
        self.callback = callback
        
        UIApplication.shared.windows.first!.addSubview(self)
        UIApplication.shared.windows.first!.endEditing(true)
        
        // Animation
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
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
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
                self.dialogView!.layer.opacity = 0.1
                self.dialogView!.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            }) { (finished: Bool) -> Void in
                
                self.removeFromSuperview()
        }
    }
    
    // MARK: Button Event
    func clickButton(_ sender: UIButton!) {
        if sender.tag == doneButtonTag {
            
            self.callback?(dataSelcted!)
        }
        
        close()
    }
}

extension CustomPickerDialog: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return componentNum
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        dataSelcted = self.dataSource[row]
    }
}
