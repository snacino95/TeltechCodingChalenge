//
//  UIViewController + Extension.swift
//  TeltechCodingChallenge
//
//  Created by Sergio Načivić on 13.11.2022..
//

import Foundation
import UIKit

extension UIViewController {
  func showError(_ error: Error) {
    DispatchQueue.main.async {
      let nsError = error as NSError
      let alert = UIAlertController(title: "Error", message: nsError.description, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
}
