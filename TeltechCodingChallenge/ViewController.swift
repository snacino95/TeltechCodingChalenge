//
//  ViewController.swift
//  TeltechCodingChallenge
//
//  Created by Sergio Načivić on 06.11.2022..
//

import UIKit
import CallerData
import CallKit

enum ViewControllerErrors: Error {
  case invalidPhoneNumber
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var textField: PhoneTextField!
  
  var callersData: [CallerDetail] = []
  var callerDataService = CallerDetailService()
  var selectedStatus: CallerStatus {
    get {
      guard let status = CallerStatus(rawValue: Int16(segmentedControl.selectedSegmentIndex)) else { fatalError("Not handled") }
      return status
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    activityIndicator.isHidden = true
    segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    fetchCallersAndUpdateUi()
  }
  
  
  //MARK: TableViewDelegate
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return callersData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let callerDetail = callersData[indexPath.row]
    
    cell.textLabel?.text = "\(callerDetail.phoneNumber)"
    cell.detailTextLabel?.text = callerDetail.didRemove ? "To be removed": "Active"
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      softDeleteCallerDetail(indexPath)
      fetchCallersAndUpdateUi()
    }
  }
  
  //MARK: TextFieldDelegate
  func textFieldDidEndEditing(_ textField: UITextField) {
    
    guard (textField as! PhoneTextField).didConfirm else { return }
    
    guard
      let phoneString = textField.text,
      let phoneNumber = Int64(phoneString)
    else {
      showError(ViewControllerErrors.invalidPhoneNumber)
      return
    }
    
    createCallerDetail(phoneNumber)
    fetchCallersAndUpdateUi()
  }
  
  
  //MARK: Private functions
  func softDeleteCallerDetail(_ indexPath: IndexPath) {
    let phoneNumber = callersData[indexPath.row]
    phoneNumber.didRemove = true
    phoneNumber.updatedAt = Date()
  }
  
  func createCallerDetail(_ phoneNumber: Int64) {
    callerDataService.createCallerDetailWith(phoneNumber: phoneNumber, status: selectedStatus, details: "Unknown Yet")
    fetchCallersAndUpdateUi()
  }
  
  func fetchCallersAndUpdateUi() {
    textField.text = ""
    callersData = callerDataService.fetchCallersWith(status: selectedStatus)
    tableView.reloadData()
  }
  
  @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    fetchCallersAndUpdateUi()
  }
  
  private func startActivityIndicator() {
    DispatchQueue.main.async {
      self.view.isUserInteractionEnabled = false
      self.activityIndicator.isHidden = false
      self.activityIndicator.startAnimating()
    }
  }
  
  private func stopActivityIndicator() {
    DispatchQueue.main.async {
      self.view.isUserInteractionEnabled = true
      self.activityIndicator.isHidden = true
      self.activityIndicator.stopAnimating()
    }
  }
  
  @IBAction func reloadExtension(_ sender: Any) {
    
    startActivityIndicator()
    try! callerDataService.saveChanges()
    
    CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier:"com.Sergio.TeltechCodingChallenge.CallDirectoryExtension", completionHandler: { (error) in
      DispatchQueue.main.async {
        self.extensionCompleted(error: error)
      }
    })
  }
  
  func extensionCompleted(error: Error? = nil) {
    defer { stopActivityIndicator() }
    
    guard error == nil else {
      showError(error!)
      return
    }
    
    do {
      self.callerDataService.deleteCallersDetailsWhere(andDidRemove: true)
      try self.callerDataService.saveChanges()
      self.fetchCallersAndUpdateUi()
    } catch {
      self.showError(error)
    }
  }
}

