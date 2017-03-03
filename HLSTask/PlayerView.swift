//
//  PlayerView.swift
//  HLSTask
//
//  Created by PavelKnd on 3/3/17.
//  Copyright © 2017 PavelKnd. All rights reserved.
//

import UIKit
import AVFoundation

enum PlayerState {
    case uninitialized
    case fetching
    case playing
    case paused
    case completed
}

protocol PlayerDelegate: class {
    func player(_ player: PlayerView, didChangeState state: PlayerState)
}

protocol PlayerProgressSource: class {
    func currentDownload() -> Double
}

class PlayerView: DragNDropView {
    
    fileprivate var playerState: PlayerState = .uninitialized {
        didSet {
            if let delegate = self.delegate {
                delegate.player(self, didChangeState: playerState)
                print(playerState)
            }
        }
    }
    
    private var halfHeight: CGFloat {
        get {
            return self.bounds.height / 2
        }
    }
    private var halfWidth: CGFloat {
        get {
             return self.bounds.width / 2
        }
    }
    
    private var playButton: UIButton!
    private var audioPlayer: AVAudioPlayer?
    private var audioPath: String!
    private var progressUpdaterTimer: Timer!
    private var progress: Double = 0.0
    private var spinner = UIActivityIndicatorView()
    
    weak var delegate: PlayerDelegate?
    weak var progressSource: PlayerProgressSource?
  
    init(frame: CGRect, audioPath: String) {
        super.init(frame:frame)
        self.audioPath = audioPath
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.halfHeight
        
        playButton = UIButton(type: .system)
        playButton.frame.size = CGSize(width: self.frame.width * 0.5, height: self.frame.height * 0.5)
        playButton.center = self.center
        playButton.layer.masksToBounds = true
        playButton.layer.cornerRadius = playButton.frame.height * 0.5
        playButton.addTarget(self, action: #selector(PlayerView.didPressPlay(button:)), for: .touchUpInside)
        playButton.setTitle("▷", for: .normal)
        playButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        playButton.setTitleColor(.purple, for: .normal)
        playButton.backgroundColor = .white
        self.addSubview(playButton)
    }
    
    func handleUpdateTimer () {
        if let progressSource = self.progressSource {
            self.progress = progressSource.currentDownload()
            
            self.updateProgressWith(progress: progress)
            if progress >= 1 {
                self.hideSpinner()
                self.stopProgressUpdate()
                self.playerState = .playing
                try? self.audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                self.validatePlayerState()
            }
        }
    }
    
    private func updateProgressWith(progress: Double) {
        self.currentAngle = (progress * (maxAngle - minAngle)) + minAngle
        print(currentAngle)
        setNeedsDisplay()
    }
    
    fileprivate func validatePlayerState() {
        switch self.playerState {
        case .uninitialized:
            self.playerState = .fetching
            self.startProgressUpdate()
            self.showSpinner()
        case .fetching:
            break
        case .playing:
            audioPlayer?.play()
            playButton.setTitle("||", for: .normal)
            playButton.setTitleColor(.purple, for: .normal)
            break
        case .paused:
            audioPlayer?.stop()
            playButton.setTitle("▷", for: .normal)
            playButton.setTitleColor(.purple, for: .normal)
            break
        case .completed:
            playButton.setTitle("▷", for: .normal)
            playButton.setTitleColor(.purple, for: .normal)
            break
        }
    }
    
    func didPressPlay(button: UIButton) {
        self.togglePlay(button: button)
        self.validatePlayerState()
        
    }
    
    private func togglePlay(button: UIButton) {
        switch self.playerState {
        case .playing:
            self.playerState = .paused
            break
        case .paused:
            self.playerState = .playing
        default:
            break
        }
    }
    
    func startProgressUpdate() {
        self.progressUpdaterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PlayerView.handleUpdateTimer), userInfo: nil, repeats: true)
    }
    
    func stopProgressUpdate() {
        self.progressUpdaterTimer.invalidate()
    }
    
    private func showSpinner() {
        self.prepareActivityIndicator(for: self.playButton)
        
        spinner.startAnimating()
        
    }
    private func hideSpinner() {
        spinner.removeFromSuperview()
    }
    
    private func prepareActivityIndicator(for uiView: UIView) {
        spinner.frame = CGRect.init(x: halfWidth - 20, y: halfHeight - 20, width: 40, height: 40)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.color = UIColor.purple
        spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        self.addSubview(spinner)
        self.bringSubview(toFront: spinner)
    }
    
    // MARK: Properties

    private let radius: CGFloat = 50
    private var currentAngle: Double = -90
    private let minAngle: Double = -90
    private let maxAngle: Double = 270
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let path = CGMutablePath()
        let center = CGPoint(x: halfWidth, y: halfHeight)
        path.addArc(center: center, radius: radius, startAngle: CGFloat(minAngle * M_PI / 180.0 ), endAngle: CGFloat(currentAngle * M_PI / 180.0), clockwise: false)
        context.addPath(path)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(15)
        context.strokePath()
    }
}

extension PlayerView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playerState = .completed
        self.validatePlayerState()
    }
}
