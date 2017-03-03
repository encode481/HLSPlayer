//
//  ViewController.swift
//  HLSTask
//
//  Created by PavelKnd on 2/28/17.
//  Copyright © 2017 PavelKnd. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var playerView: PlayerView!

    let dataHandler = DataHandler(playlistURL: URL(string: "http://pubcache1.arkiva.de/test/hls_a256K_v4.m3u8")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView = PlayerView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 150)), audioPath: dataHandler.contentPath)
        playerView.delegate = self
        playerView.progressSource = dataHandler
        playerView.backgroundColor = .purple
        playerView.center = self.view.center
        self.view.addSubview(playerView)
        
    }
}

extension ViewController: PlayerDelegate {
    func player(_ player: PlayerView, didChangeState state: PlayerState) {
        switch state {
        case .uninitialized:
            self.dataHandler.clearLocalData()
            break
        case .fetching:
            self.dataHandler.startDownloading()
            break
        case .playing: break
        case .paused: break
        case .completed:
            self.dataHandler.clearLocalData()
            break
        }
    }
}
