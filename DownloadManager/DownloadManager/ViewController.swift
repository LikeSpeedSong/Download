//
//  ViewController.swift
//  DownloadManager
//
//  Created by A_zhi on 16/6/15.
//  Copyright © 2016年 Azhi. All rights reserved.
//

import UIKit

let kScreenW=UIScreen.mainScreen().bounds.size.width
let kScreenH=UIScreen.mainScreen().bounds.size.height
let kCachePath=NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last

class ViewController: UIViewController {
    lazy var tableView:UITableView={
        let temTableView=UITableView(frame: CGRectMake(0, 0, kScreenW, kScreenH), style: UITableViewStyle.Plain)
        temTableView.delegate=self
        temTableView.dataSource=self
        return temTableView
    }()
    
    lazy var dataArr:NSMutableArray={
        let arr=NSMutableArray()
        return arr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        self.view.addSubview(self.tableView)
    }

    func initData(){
        let model1 = DownloadModel()
        model1.urlString="http://imgcache.qq.com/qzone/biz/gdt/dev/sdk/ios/release/GDT_iOS_SDK.zip"
        model1.name="呵呵呵呵"
        model1.destion_path=kCachePath!+"/"+model1.name
        self.dataArr.addObject(model1)

        let model2 = DownloadModel()
        model2.urlString="http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar"
        model2.name="哈哈哈哈哈"
        model2.destion_path=kCachePath!+"/"+model2.name
        self.dataArr.addObject(model2)
        
        let model3 = DownloadModel()
        model3.urlString="http://dota2.dl.wanmei.com/dota2/client/DOTA2Setup20160329.zip"
        model3.name="啦啦啦啦啦"
        model3.destion_path=kCachePath!+"/"+model3.name
        self.dataArr.addObject(model3)
    }

}


extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return self.dataArr.count;
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID="downloadCellID"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? DownloadCell
        if cell==nil {
            cell=DownloadCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellID) 
        }
        let model = self.dataArr.objectAtIndex(indexPath.row)
        
        cell?.cellWithModel(model as! DownloadModel)
        cell?.downloadBlock={(btn)->Void in
            self.downloadWithTitle(btn, model: model as! DownloadModel, cell: cell!)
        }
        return cell!
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Delete"
    }
    
      func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let model = self.dataArr.objectAtIndex(indexPath.row)
        DownloadManager.sharedManager.deleteTask(model.urlString, filePath: model.destion_path)
        self.dataArr.removeObject(model)
        self.tableView.reloadData()
        
    }
    
    func downloadWithTitle(btn:UIButton,model:DownloadModel,cell:DownloadCell){
        let title = btn.currentTitle
        if title == "开始" || title == "恢复"{
            btn.setTitle("暂停", forState: UIControlState.Normal)
            DownloadManager.sharedManager.download(model.urlString, toPath: model.destion_path, progress: { (progress, speedStr, sizeStr) in
                cell.progressView.progress=progress
                cell.sizeLabel.text=sizeStr
                cell.speedLabel.text=speedStr
                cell.speedLabel.hidden=false
                }, complete: { 
                    cell.speedLabel.hidden=true
                    btn.userInteractionEnabled=false
                    let alert=UIAlertView.init(title:String(format: "%@下载完成",(model.name)), message: nil, delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                }, failure: { (error) in
                    
            })
        }else if title == "暂停"{
            btn.setTitle("恢复", forState: UIControlState.Normal)
            DownloadManager.sharedManager.pauseTask(model.urlString)
            cell.speedLabel.hidden=true
        }
    }
    
}
    