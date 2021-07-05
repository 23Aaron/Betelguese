//
//  AboutViewController.swift
//  Betelguese
//
//  Created by 23 Aaron on 12/06/2020.
//  Copyright © 2020 23 Aaron. All rights reserved.
//

import Foundation
import SDWebImage

class AboutViewController: NSViewController {
    
    @IBOutlet weak var aaronImageView: NSImageView!
    @IBOutlet weak var adamImageView: NSImageView!
    @IBOutlet weak var diatrusImageView: NSImageView!
    @IBOutlet weak var coolstarImageView: NSImageView!
    
    @IBOutlet weak var quickCheckbox: NSButton!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        quickCheckbox.state = UserDefaults.standard.bool(forKey: "quickMode") ? .on : .off
        
        SDImageCache.shared.config.maxDiskSize = 1

        aaronImageView.sd_setImage(with: URL(string: "https://github.com/23aaron.png"), placeholderImage: nil, options: .refreshCached, context: nil)
        adamImageView.sd_setImage(with: URL(string: "https://github.com/kirb.png"), placeholderImage: nil, options: .refreshCached, context: nil)
        diatrusImageView.sd_setImage(with: URL(string: "https://github.com/diatrus.png"), placeholderImage: nil, options: .refreshCached, context: nil)
        coolstarImageView.sd_setImage(with: URL(string: "https://github.com/coolstar.png"), placeholderImage: nil, options: .refreshCached, context: nil)
    }
    
    @IBAction func aaronTwitterButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.twitter.com/23Aaron_")!)
    }
    @IBAction func kirbTwitterButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.twitter.com/hbkirb")!)
    }
    @IBAction func haydenTwitterButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.twitter.com/Diatrus")!)
    }
    @IBAction func csTwitterButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.twitter.com/CStar_OW")!)
    }
    
    @IBAction func aaronGitHubButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.github.com/23Aaron")!)
    }
    @IBAction func kirbGitHubButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.github.com/kirb")!)
    }
    @IBAction func haydenGitHubButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.github.com/Diatrus")!)
    }
    @IBAction func csGitHubButton(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://www.github.com/coolstar")!)
    }
    
    @IBAction func quickCheckboxChanged(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state == .on, forKey: "quickMode")
    }
}

