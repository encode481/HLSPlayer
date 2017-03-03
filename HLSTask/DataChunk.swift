//
//  DataChunk.swift
//  HLSTask
//
//  Created by PavelKnd on 3/3/17.
//  Copyright © 2017 PavelKnd. All rights reserved.
//

import Foundation

protocol DataChunkDelegate: class {
    func dataChunk(_ dataChunk: DataChunk, didChangeState state: ChunkDownloadState)
    func dataChunk(_ dataChunk: DataChunk, didChangeProgress progress: Double)
}

enum ChunkDownloadState {
    case downloading
    case completed
    case pending
}

class DataChunk {
    struct ByteRange {
        let length: Int
        let offset: Int
    }
    
    var url: URL
    var downloadState: ChunkDownloadState = .pending {
        didSet {
            if let delegate = self.delegate {
                delegate.dataChunk(self, didChangeState: downloadState)
            }
        }
    }
    
    var progress: Double = 0.0 {
        didSet {
            if let delegate = self.delegate {
                delegate.dataChunk(self, didChangeProgress: progress)
            }
        }
    }
    
    var downloadTask: URLSessionDataTask?
    var byteRange: ByteRange
    var downloadedData: Data?
    
    weak var delegate: DataChunkDelegate?
    
    init(url: URL, byteRange: ByteRange) {
        self.url = url
        self.byteRange = byteRange
    }
    
    convenience init(url: URL, byteRange: ByteRange, delegate: DataChunkDelegate) {
        self.init(url: url, byteRange: byteRange)
        self.delegate = delegate
    }
}
