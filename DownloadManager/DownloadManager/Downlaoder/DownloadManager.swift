//
//  DownloadManager.swift
//  DownloadManager
//
//  Created by A_zhi on 16/6/15.
//  Copyright © 2016年 Azhi. All rights reserved.
//

import UIKit
import Foundation
class DownloadManager: NSObject {
    static var sharedManager:DownloadManager=DownloadManager()
    
    var taskDict : NSMutableDictionary?
    var bgId : UIBackgroundTaskIdentifier?
    
    override init() {
        super.init()
        taskDict=NSMutableDictionary()
        bgId=UIBackgroundTaskInvalid
        
        [NSNotificationCenter.defaultCenter() .addObserver(self, selector:#selector(downloadComplet(_:)), name: DownloaderFinishNotification, object: nil)]
        
        [NSNotificationCenter.defaultCenter() .addObserver(self, selector:#selector(spareWarning(_:)), name: InsufficientMemorySpaceNotification, object: nil)]
        
        
    }
    
    
    func downloadComplet(sender:NSNotification)  {
        
    }
    
    func spareWarning(sender:NSNotification){
        
    }
    
    func download(urlString:String?,toPath:String?,progress:ProgressHandel,complete:CompleteHandel,failure:FailureHandel){
        let downloader = Downloader.downloader()
        lockFunc(self) {
            self.taskDict?.setObject(downloader, forKey: urlString!)
        }
        downloader.download(urlString, toPath: toPath, progress: progress, complete:complete, failure: failure)
        
    }
    
    func pauseTask(urlString:String?) {
        let downloader = taskDict?.objectForKey(urlString!)
        downloader?.cancel()
        lockFunc(self) {
            self.taskDict!.removeObjectForKey(urlString!)
        }
        
    }
    
    
    func deleteTask(urlString:String?,filePath:String?)  {
        pauseTask(urlString)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("progress"+urlString!)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("totalLength"+urlString!)
        NSUserDefaults.standardUserDefaults().synchronize()
        let isExistsFile = NSFileManager.defaultManager().fileExistsAtPath(filePath!)
        if isExistsFile {
            do{
                try NSFileManager.defaultManager().removeItemAtPath(filePath!)
                
            }
            catch{
                
            }
        }
        
    }
    
    func pauseAllTasks(){
        taskDict?.enumerateKeysAndObjectsUsingBlock({ (key, value, stop) in
            value .cancel()
            self.taskDict?.removeObjectForKey(key)
        })
    }
    
    func currentDownloadProgress(urlString:String?)->Float{

        return Downloader.lastProgress(urlString!)
    }
    
    func currentFileSize(urlString:String?)->String{
        return Downloader.lastSizeString(urlString!)
    }
    
    // 模拟线程锁
    private func lockFunc(lock:AnyObject?,fun:()->()){
        objc_sync_enter(lock)
        fun()
        objc_sync_exit(lock)
    }
}
