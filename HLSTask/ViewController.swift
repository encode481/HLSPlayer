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

    func injected() {
        self.dismiss(animated: false, completion: nil)
        self.navigationController?.present(ViewController(), animated: true, completion: nil)
        print("✅")
    }
    
    let dataHandler = DataHandler(playlistURL: URL(string: "http://pubcache1.arkiva.de/test/hls_a256K_v4.m3u8")!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("✅")
        
//        self.dataHandler.startDownloading()
        
        
        
//        let path = Bundle.main.path(forResource: "hls_a256K_v4", ofType: "m3u8")
//        let response = try! String(contentsOfFile: path!)
        
        //let byteRanges = DataHandler.parseByteRangesFrom(response: response)
//        print(byteRanges)
//        let testUrl = URL(string: "http://pubcache1.arkiva.de/test/hls_a256K_v4.m3u8")
        
        
        
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
//        for dataChunk in self.dataHandler.chunks! {
//            print(dataChunk.downloadState)
//        }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let filePath = path.appending("/output.mp3")
       
//        let player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
        player.play()
            
    }

    @IBAction func pressed(_ sender: Any) {
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

