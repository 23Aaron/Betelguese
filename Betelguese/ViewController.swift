//
//  ViewController.swift
//  Odysseyra1n
//
//  Created by 23 Aaron on 11/06/2020.
//  Copyright © 2020 23 Aaron. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var goButton: NSButton!
    @IBOutlet weak var statusBox: NSBox!
    @IBOutlet var logView: NSTextView!
    @IBOutlet var statusLabel: NSTextField!
    
    var goTouchBarButton: NSButton!
    var progressTouchBarLabel: NSTextField!
    
    @IBOutlet weak var sileoCheckbox: NSButton!
    @IBOutlet weak var zebraCheckbox: NSButton!
    @IBOutlet weak var cydiaCheckbox: NSButton!
    @IBOutlet weak var newTermCheckbox: NSButton!

    var isBusy = false

    override func viewWillAppear() {
        super.viewWillAppear()

        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidConnect), name: MobileDeviceHelper.deviceDidConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidDisconnect), name: MobileDeviceHelper.deviceDidDisconnectNotification, object: nil)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.styleMask.remove(.resizable)
        
        if let windowController = view.window?.windowController as? WindowController {
            goTouchBarButton = windowController.goTouchBarButton
            progressTouchBarLabel = windowController.progressTouchBarLabel
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setStatus("Ready!")

        Timer.scheduledTimer(timeInterval: 1 / 60, target: self, selector: #selector(self.refreshStatus), userInfo: nil, repeats: true)
    }

    @objc private func deviceDidConnect() {
        guard let name = MobileDeviceHelper.deviceName,
              let firmware = MobileDeviceHelper.deviceFirmware else {
            deviceDidDisconnect()
            return
        }

        if firmware.compare("12.0") == .orderedAscending {
            statusLabel.stringValue = "\(name) (iOS \(firmware)) is not compatible."
            goButton.isEnabled = false
            goTouchBarButton?.isEnabled = false
        } else {
            statusLabel.stringValue = "Ready to install on \(name) (iOS \(firmware))"
            goButton.isEnabled = !isBusy
            goTouchBarButton?.isEnabled = !isBusy
        }
    }

    @objc private func deviceDidDisconnect() {
        statusLabel.stringValue = "Connect your device to continue."
        goButton.isEnabled = false
        goTouchBarButton?.isEnabled = false
    }
    
    @objc func refreshStatus() {
        if isBusy {
            self.logView.scrollToEndOfDocument(self)
        }
    }
    
    func setStatus(_ status: String, isLogOutput: Bool = false) {
        let font: NSFont
        if #available(macOS 10.15, *) {
            font = NSFont.monospacedSystemFont(ofSize: 0, weight: .regular)
        } else {
            font = NSFont.userFixedPitchFont(ofSize: 0)!
        }

        let attributedString = NSAttributedString(string: status, attributes: [
            .font: font,
            .foregroundColor: NSColor.white
        ])
        if isLogOutput {
            logView.textStorage?.append(attributedString)
        } else {
            logView.textStorage?.setAttributedString(attributedString)
        }
    }
    
    @IBAction func saveLog(_ sender: Any) {
        do {
            let desktopURL = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let url = desktopURL.appendingPathComponent("Betelguese Log.txt")
            try logView.string.write(to: url, atomically: true, encoding: .utf8)
            NSWorkspace.shared.activateFileViewerSelecting([ url ])
        } catch {
            NSAlert(error: error as NSError).beginSheetModal(for: view.window!)
        }
    }
    
    @IBAction func installCheckboxChanged(_ sender: NSButton) {
        let checkboxes = [ sileoCheckbox, zebraCheckbox, cydiaCheckbox, newTermCheckbox ]
        let numberSelected = checkboxes
            .filter { item in item!.state == .on }
            .count

        for checkbox in checkboxes {
            if numberSelected == 1 {
                checkbox?.isEnabled = checkbox?.state == .off
            } else {
                checkbox?.isEnabled = true
            }
        }

        if numberSelected == 1 && newTermCheckbox.state == .on {
            let newTermAlert = NSAlert()
            newTermAlert.messageText = "Disclaimer"
            newTermAlert.informativeText = """
            Please make sure selecting only NewTerm is the right option for you before continuing.

            This is an advanced option that will not include a regular package manager of any kind, and is intended for users familiar with the command line.
            """
            newTermAlert.addButton(withTitle: "Continue")
            newTermAlert.addButton(withTitle: "Cancel")
            newTermAlert.beginSheetModal(for: view.window!) { (response) in
                if response == .alertSecondButtonReturn {
                    sender.state = .on
                    self.installCheckboxChanged(sender)
                }
            }
        }
    }
    
    @IBAction func startButtonClick(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "quickMode") {
            doStuff()
            return
        }
        
        let confirmAlert = NSAlert()
        confirmAlert.messageText = "Important"
        confirmAlert.informativeText = """
        Before you begin: ENSURE YOU ARE JAILBROKEN WITH CHECKRA1N BEFORE USING!
        
        If you have already installed Cydia using Loader, please use the Restore System option, then re-jailbreak before continuing.
        
        DISCLAIMER: Use at your own risk. None of the people associated with this project are liable for any damage caused to your device.
        """
        confirmAlert.addButton(withTitle: "Continue")
        confirmAlert.addButton(withTitle: "Cancel")
        confirmAlert.beginSheetModal(for: view.window!) { (response) in
            if response == .alertFirstButtonReturn {
                self.doStuff()
            }
        }
        
    }
    
    func doStuff() {
        isBusy = true
        setStatus("Downloading…\n")
        goButton.isEnabled = false
        goTouchBarButton?.isEnabled = false
        statusLabel.isHidden = true
        progressBar.startAnimation(nil)
        
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory() + "/betelguese")
        try? FileManager.default.removeItem(at: tempDir)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        
        URLSession.shared.downloadTask(with: URL(string: "https://taurine.app/docs/betelguese-1.1.sh")!) { (url, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    NSAlert(error: error!).beginSheetModal(for: self.view.window!, completionHandler: nil)
                    self.stopDoingStuff()
                }
                return
            }
            
            let scriptData = try! Data(contentsOf: url!)
            let firmware = MobileDeviceHelper.deviceFirmware ?? "0"

            let path = ProcessInfo.processInfo.environment["PATH"]! + ":" + Bundle.main.resourcePath!
            let process = Process()
            process.launchPath = "/bin/bash"
            process.arguments = [ "/dev/stdin", "-y", firmware ]
            process.environment = [
                "PATH": path,
                "SSHPASS": "alpine"
            ]
            process.currentDirectoryPath = tempDir.path
            
            let inputPipe = Pipe()
            process.standardInput = inputPipe
            inputPipe.fileHandleForWriting.write(scriptData)
            inputPipe.fileHandleForWriting.closeFile()
            
            let outputPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = outputPipe
            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    let text = String(data: handle.availableData, encoding: .utf8) ?? ""
                    DispatchQueue.main.async {
                        self.setStatus(text, isLogOutput: true)
                    }
                }
            }
            
            process.launch()
            
            DispatchQueue.global(qos: .userInitiated).async {
                process.waitUntilExit()
                
                DispatchQueue.main.async {
                    let isError = process.terminationStatus != 0
                    self.stopDoingStuff(isError: isError)
                    
                    let alert = NSAlert()
                    if isError {
                        self.setStatus("\nError \(process.terminationStatus)", isLogOutput: true)
                        alert.messageText = "Error \(process.terminationStatus)"
                        
                        if process.terminationStatus == 1 {
                            alert.informativeText = "This can happen when your device isn’t detected. Try disconnecting and reconnecting your device, then try again."
                        }
                    } else {
                        alert.messageText = "Done!"
                    }
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
            }
        }.resume()
    }
    
    func stopDoingStuff(isError: Bool = false) {
        isBusy = false
        if !isError {
            setStatus("Ready!")
        }
        progressBar.stopAnimation(nil)
        goButton.isEnabled = true
        goTouchBarButton?.isEnabled = true
        statusLabel.isHidden = false
    }

}

