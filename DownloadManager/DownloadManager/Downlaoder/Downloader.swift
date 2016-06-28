//
//  Downloader.swift
//  DownloadManager
//
//  Created by A_zhi on 16/6/15.
//  Copyright © 2016年 Azhi. All rights reserved.
//

import UIKit


let DownloaderFinishNotification = "DownloaderFinishNotification"
let InsufficientMemorySpaceNotification = "InsufficientMemorySpaceNotification"
let totalLength="totalLength"
let currentProgress = "currentProgress"


typealias ProgressHandel=(progress:Float,speedStr:String,sizeStr:String)->Void
typealias CompleteHandel=()->Void
typealias FailureHandel=(error:NSError)->Void

class Downloader: NSObject {

    var progress :ProgressHandel?
    var  completion : CompleteHandel?
    var failure = FailureHandel?()
    var growSize : NSInteger?
    var lastSize = NSInteger()
    var destionation_path: String?
    var urlString:String?
    var con : NSURLConnection?
    var  writeHandel = NSFileHandle()
    private var timer:NSTimer?
    
    override init() {
        super.init()
        growSize=0
        lastSize=0;
        timer=NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(Downloader.getGrowthSize), userInfo: nil, repeats: true)
    }
    
    func cancel(){
        self.con?.cancel()
        self.con=nil
        if (self.timer != nil) {
            
        }
    }
    
   @objc private func getGrowthSize()  {
        do{
            let dict :NSDictionary=try NSFileManager.defaultManager().attributesOfItemAtPath(self.destionation_path!)
            let size = dict.objectForKey(NSFileSize)?.integerValue
            self.growSize=size!-self.lastSize
            self.lastSize=size!
            
        }
        catch{
            
        }
       
        
    }
    
    class func downloader() -> Downloader {
        
        let downloader=Downloader();
        return downloader;
    }
    
    //MARK:开始下载任务
    func download(urlString:String?,toPath:String?,progress:ProgressHandel,complete:CompleteHandel,failure:FailureHandel) {
        if toPath==nil || urlString==nil{
            return;
        }
        destionation_path=toPath;
        self.urlString=urlString;
        self.progress=progress;
        self.completion=complete;
        self.failure=failure
        
        let url = NSURL(string:urlString!)
        let request = NSMutableURLRequest(URL: url!)
        let isExist = NSFileManager.defaultManager().fileExistsAtPath(toPath!)
        // 判断是否断点续传
        if isExist {
            do{
                let dict:NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(toPath!)
                let length = dict.objectForKey(NSFileSize)?.integerValue
                let rangeString = String.init(format:"bytes=%ld-",length!)
                request .setValue(rangeString, forHTTPHeaderField: "Range")

            }
            catch{
                
            }
        }
        
        self.con=NSURLConnection(request: request, delegate: self)!
        
    }
    
  
    class func lastProgress(urlString:String?)->Float{
        if urlString==nil {
            return 0;
        }
        return NSUserDefaults.standardUserDefaults().floatForKey("progress"+urlString!)
    }
    
    class  func lastSizeString(urlString:String?)->String{
        if urlString==nil {
            return "0/0"
        }
        let lengthKey = "totalLength"+urlString!
        let totalLength = NSUserDefaults.standardUserDefaults().integerForKey(lengthKey)
        let progressKey = "progress"+urlString!
        let progress = NSUserDefaults.standardUserDefaults().floatForKey(progressKey)
        let currentSize = Int(Float(totalLength) * progress)
        
        return transformSize(currentSize)+"/"+transformSize(totalLength)
  
    }
    
    class func transformSize(length:NSInteger?)->String{
        if length<1024 {
            return String(format: "%ldB",length!)
        }
        else if length>=1024&&length<1024*1024 {
            return String(format: "%.0fK",Float(length!/1024))
        }
        else if length>=1024*1024&&length<1024*1024*1024 {
            
            return String(format: "%.1fM",Float(length!)/(1024.0*1024.0))
        }
        else{
            return String(format: "%.1fG",Float(length!/(1024*1024*1024)))
        }
    }
    
    private func availableSpace()->NSInteger{
        var freeSpace = 0
        let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        
        do
        {
            let dict:NSDictionary = try NSFileManager.defaultManager().attributesOfFileSystemForPath(docPath!)
            freeSpace=(dict.objectForKey(NSFileSystemFreeSize)?.integerValue)!
            
        }
        catch{
            
        }
        return freeSpace
        
    }
    
}

extension Downloader :NSURLConnectionDelegate,NSURLConnectionDataDelegate{
    // 收到响应
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        let  lengthKey = "totalLength"+self.urlString!
        let length = NSUserDefaults.standardUserDefaults().integerForKey(lengthKey)
        if length==0 {
            let totalLength = response.expectedContentLength
            NSUserDefaults.standardUserDefaults().setInteger(Int(totalLength), forKey: lengthKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        let isExists = NSFileManager.defaultManager().fileExistsAtPath(self.destionation_path!)
        if isExists==false  {
            NSFileManager.defaultManager().createFileAtPath(self.destionation_path!, contents: nil, attributes: nil)
        }
        self.writeHandel=NSFileHandle(forWritingAtPath: self.destionation_path!)!
        
    }
    
    // 下载过程会不停调用
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.writeHandel.seekToEndOfFile()
        self.writeHandel.writeData(data)
        
        // 判断系统空间是否足够
        let freeSpace = availableSpace()
        if freeSpace<1024*1024*10 {
            let alert = UIAlertView.init(title: "警告", message: "系统空间不足10M", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            let dict = ["urlString":self.urlString!]
            NSNotificationCenter.defaultCenter().postNotificationName(InsufficientMemorySpaceNotification, object: nil, userInfo: dict)
            return
           
        }
        
        
        do{
            let dict:NSDictionary=try NSFileManager.defaultManager().attributesOfItemAtPath(self.destionation_path!)
            let currentLength = dict.objectForKey(NSFileSize)?.integerValue
            let totallength = NSUserDefaults.standardUserDefaults().integerForKey("totalLength"+self.urlString!)
            
            let progress = Float(currentLength!)/Float(totallength)
            let currentSize = Downloader.lastSizeString(self.urlString!)
            let speed = Downloader.transformSize(self.growSize!*2)
            
            let progressKey = "progress"+self.urlString!
            NSUserDefaults.standardUserDefaults().setFloat(progress, forKey: progressKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if self.progress != nil {
                self.progress!(progress:progress,speedStr: speed+"/s",sizeStr: currentSize)
               
            }
        }
       
        catch{
            
        }
        
    }
    
    // 下载完成
    func connectionDidFinishLoading(connection: NSURLConnection) {
        let dict:Dictionary<String,String>=["urlString":self.urlString!]
        
        NSNotificationCenter.defaultCenter().postNotificationName(DownloaderFinishNotification, object: nil, userInfo: dict)
        if (self.completion != nil) {
            self.completion!()
        }
    }
    
    // 下载失败
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        if (self.failure != nil) {
            self.failure!(error:error)
        }
    }
}