//
//  ViewController.swift
//  SocketTagrem
//
//  Created by india on 11/03/19.
//  Copyright © 2019 Mahipal Singh. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var hostname: UILabel!
    @IBOutlet weak var portNumber: UILabel!
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var logTextView: UITextView!
    
    @IBOutlet weak var connectionBtn: UIButton!
    @IBOutlet weak var ehloCommandBtn: UIButton!
    @IBOutlet weak var quitBtn: UIButton!
    
    
    var host =  "indition.cc"
    var port = 25
    
    var client: TCPClient?
    var tableArr = [String]()
    
    //MARK: VIEW METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.client = TCPClient(address: self.host, port: Int32(self.port))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        alertPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let client = self.client else { return }
        client.close()
    }
    
    //MARK: - BUTTONS Actions
    @IBAction func connectConnection(_ sender: Any) {
        self.hostname.text = host
        self.portNumber.text = "\(port)"
        self.startConnection()
        self.logTableView.delegate = self
        self.logTableView.dataSource = self
    }
    
    @IBAction func quitConnection(_ sender: Any) {
        self.proceedCommands(command: "quit\r\n")
    }
    
    @IBAction func ehloConnection(_ sender: Any) {
        self.proceedCommands(command: "EHLO\r\n")
    }
    
    //MARK: - START CONNECTIONS AND PASS COMMANDS
    func startConnection() {
        guard let client = self.client else { return }
        switch client.connect(timeout: 10) {
        case .success:
            self.appendToTextField(string: "Connected to host \(client.address)")
            self.proceedCommands(command: "GET / HTTP/1.0\n\n")
        case .failure(let error):
            self.appendToTextField(string: String(describing: error))
        }
        
    }
    
    private func proceedCommands(command:String){
        guard let client = client else { return }
        sendRequest(string: command, using: client)
    }
    
    //MARK: - SEND REQUEST
    private func sendRequest(string: String, using client: TCPClient)   {
        appendToTextField(string: "Sending data ... ")
        
        switch client.send(string: string) {
        case .success:
            if let response = self.readResponse(from: client) {
                print("Success report \(response)")
                self.appendToTextField(string: "Response of \(string) Command: \(response)")
                let charatersCode = String(response.prefix(3))
                
                self.displayAlertResult(charatersCode: charatersCode, command: string)
                
                
            }else {
                //ReTry the same Command if Response is getting Nil.
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.proceedCommands(command: string)
                }
            }
            
        case .failure(let error):
            self.appendToTextField(string: String(describing: error))
        }
    }
    
    private func displayAlertResult(charatersCode:String,command:String){
        if charatersCode == "250" && command == "quit\r\n" {
            //Sometime Commnad return the old logs of previous command.
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.proceedCommands(command: command)
            }
        }else {
            if charatersCode == "220" {
                self.showAlert(title: "👋👋", message: "Connected to \(self.host)", buttonTitle: BUTTON_TITLE.THANKS)
                setButtonStates(connectionBtn: false, ehloCommandBtn: true , quitBtn: true)
            }else if charatersCode == "250" && command == "EHLO\r\n" {
                 setButtonStates(connectionBtn: false, ehloCommandBtn: false , quitBtn: true)
            } else if charatersCode == "502" {
                //ReTry the same Command if Response is 502 from SMTP.
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.proceedCommands(command: command)
                }
            }else if charatersCode == "221" && command == "quit\r\n" {
                client?.close()
               setButtonStates(connectionBtn: true, ehloCommandBtn: false, quitBtn: false)
                self.showAlert(title:"Disconnected from tagrem.cc", message:"",
                               buttonTitle: BUTTON_TITLE.THANKS)
            }else if command != "quit\r\n" && command != "EHLO\r\n" {
                self.showAlert(title: "😞", message: "Greeting failed", buttonTitle: BUTTON_TITLE.TRY_AGAIN)
            }else{
                setButtonStates(connectionBtn: true, ehloCommandBtn: true , quitBtn: true)

            }
        }
    }
    
    private func setButtonStates(connectionBtn:Bool,ehloCommandBtn:Bool,quitBtn:Bool){
        self.connectionBtn.isEnabled = connectionBtn
        self.ehloCommandBtn.isEnabled = ehloCommandBtn
        self.quitBtn.isEnabled = quitBtn
    }
    
    //MARK: COMMAND RESPONSE
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*100) else { print("nil response"); return nil }
        let temparr = String(bytes: response, encoding: .utf8)?.components(separatedBy: "\r\n")
        self.tableArr.append(contentsOf: temparr!)
        self.logTableView.reloadData()
        return String(bytes: response, encoding: .utf8)
    }
    //MARK: - ADD DATA TO LOG WINDOW
    private func appendToTextField(string: String) {
        print(string)
        DispatchQueue.main.async {
            self.logTextView.text = self.logTextView.text.appending("\n\(string)")
        }
    }
    
    
}

