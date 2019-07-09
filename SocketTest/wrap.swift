//
//  wrap.swift
//  SocketTagrem
//
//  Created by india on 11/03/19.
//  Copyright © 2019 Mahipal Singh. All rights reserved.
//

import Foundation
import UIKit

var delegate:AlertActionsDelegate?
protocol AlertActionsDelegate {
    func retryAnyAction()
}

enum BUTTON_TITLE {
    case THANKS
    case CONTINUE
    case TRY_AGAIN
    case CONNECT_AGAIN
    func value() -> String {
        switch self {
        case .THANKS :
            return "Thanks"
        case .CONTINUE :
            return "Continue"
        case .TRY_AGAIN:
            return "Try Again"
        case .CONNECT_AGAIN:
            return "Connect Again"
        }
    }
}

extension ViewController:UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ViewController : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = tableArr[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
}

extension UIViewController {
    
    func showAlert(title:String?,message:String?,buttonTitle:BUTTON_TITLE){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message:  message , preferredStyle: .alert)
            let action = UIAlertAction( title: buttonTitle.value(), style: .default) { (_) in
                if buttonTitle == .TRY_AGAIN {
                    delegate?.retryAnyAction()
                }
            }
            alert.addAction(action)
            self.present(alert, animated: true) {}
        }
    }
    
    func checkEmptyField(textField:UITextField)->Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            var errorTitle = ""
            if textField.tag == 1 {
                errorTitle = "Please enter your hostname."
            }
            if textField.tag == 2 {
                errorTitle = "Please enter your port number."
            }
            self.showAlert(title: errorTitle, message: "", buttonTitle:BUTTON_TITLE.TRY_AGAIN)
            return false
        }
        return true
    }
}
