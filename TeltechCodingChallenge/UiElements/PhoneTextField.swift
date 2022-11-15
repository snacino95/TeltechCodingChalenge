//
//  PhoneTextField.swift
//  TeltechCodingChallenge
//
//  Created by Sergio Načivić on 13.11.2022..
//
import UIKit
import Foundation


class PhoneTextField: UITextField {
  
  
  var didConfirm: Bool = false
  
  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
  }
  
  private func setupView() {
    let toolbarDone = UIToolbar()
    toolbarDone.sizeToFit()
    
    let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                          target: self, action: #selector(doneButtonClicked))
    let barBtnCancel = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,
                                            target: self, action: #selector(cancelButtonClicked))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil);
    
    toolbarDone.items = [barBtnDone, flexibleSpace ,barBtnCancel]
    self.inputAccessoryView = toolbarDone
    self.keyboardType = .phonePad
  }
  
  @objc private func doneButtonClicked() {
    self.didConfirm = true
    self.resignFirstResponder()
  }
  
  @objc private func cancelButtonClicked() {
    self.didConfirm = false
    self.resignFirstResponder()
  }
}
