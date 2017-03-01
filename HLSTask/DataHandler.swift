//
//  DataHandler.swift
//  HLSTask
//
//  Created by PavelKnd on 2/28/17.
//  Copyright © 2017 PavelKnd. All rights reserved.
//

import Foundation

class DataHandler: NSObject {
    
    enum ChunkDownloadState {
        case downloading
        case completed
        case pending
    }
    
    class DataChunk {
        var url: URL
        var downloadState: ChunkDownloadState = .pending
        var progress: Double = 0.0
        
        var downloadTask: URLSessionDataTask?
        var byteRange: ByteRange
        var downloadedData: Data?
        
        
        init(url: URL, byteRange: ByteRange) {
            self.url = url
            self.byteRange = byteRange
        }
    }
    
    struct ByteRange {
        let length: Int
        let offset: Int
    }
    
    let playlistURL: URL
    let segmentedDownloadURL: URL?
    var chunks : [DataChunk]?
    
    let numberOfConcurrentTasks = 2;
    let downloadSemaphore: DispatchSemaphore
    
    init(playlistURL: URL) {
        self.downloadSemaphore = DispatchSemaphore(value: self.numberOfConcurrentTasks)
        self.playlistURL = playlistURL
        self.segmentedDownloadURL = playlistURL.deletingLastPathComponent().appendingPathComponent("hls_a256K.ts")
        print("\(self.segmentedDownloadURL)")
    }
    
    func startDownloading() {
        self.downloadPlaylistFrom(url: playlistURL) { [weak self] (response, error) in
            guard let response = response, self != nil else {
                return
            }
            self?.chunks = DataHandler.parseByteRangesFrom(response: response).map { byteRange in
                return DataChunk(url: (self?.segmentedDownloadURL)!, byteRange: byteRange)
            }
            if let chunks = self?.chunks {
                self?.download(dataChunks: chunks)
            }
        }
    }
    
    class func parseByteRangesFrom(response: String) -> [ByteRange] {
        let byteRangePattern = "(?<=BYTERANGE:)(.*)"
        
        let regex = try! NSRegularExpression(pattern: byteRangePattern, options: [])
        
        let matches = regex.matches(in: response, options: [], range: NSRange(location: 0, length: response.characters.count))
        let results = matches.map { (match) -> ByteRange in
            let matchedByteRange: [Int] = (response as NSString)
                .substring(with: match.range)
                .components(separatedBy: "@")
                .map { Int($0)! }
            return ByteRange(length: matchedByteRange[0], offset: matchedByteRange[1])
        }
        return results
    }
    
    func downloadPlaylistFrom(url: URL, completion: @escaping (String?, Error?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            if let data = data {
                completion(String(data: data, encoding: .utf8), nil)
            }
        }
        
        task.resume()
    }
    

    
    func download(dataChunks: [DataChunk]) {
        let downloadingQueue = DispatchQueue(label: "com.elinext.downloadQueue", qos: .background, attributes: .concurrent)

        for dataChunk in dataChunks {
            _ = self.downloadSemaphore.wait(timeout: .distantFuture)
            downloadingQueue.async {
                self.download(dataChunk: dataChunk)
            }
            
        }
    }
    
    func download(dataChunk: DataChunk) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        var request = URLRequest(url: dataChunk.url)
        request.addValue("bytes=\(dataChunk.byteRange.offset)-\(dataChunk.byteRange.offset + dataChunk.byteRange.length)", forHTTPHeaderField: "Range")
        let task = session.dataTask(with: request)
        dataChunk.downloadTask = task;
        task.resume()
    }
    
}

extension DataHandler: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let chunk = chunks?.first(where: {$0.downloadTask == dataTask}) {
            chunk.downloadState = .downloading
            chunk.downloadedData = Data()
            completionHandler(.allow)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let chunk = chunks?.first(where: {$0.downloadTask == dataTask}) {
            chunk.downloadedData?.append(data)
            let percentageDownloaded = Double((chunk.downloadedData?.count)!) / Double(chunk.byteRange.length)
            chunk.progress = percentageDownloaded
            print("downloading \(chunk.byteRange) percentageDownloaded: \(percentageDownloaded)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let chunk = chunks?.first(where: {$0.downloadTask == task}) {
            chunk.progress = 1.0
            chunk.downloadState = .completed
            
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(chunk.byteRange.offset)")
            do {
                try chunk.downloadedData?.write(to: fileURL, options: .atomic)
            } catch {
                print(error)
            }
            downloadSemaphore.signal()
        }
    }
}
