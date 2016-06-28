//
//  DownloadCell.swift
//  DownloadManager
//
//  Created by A_zhi on 16/6/16.
//  Copyright © 2016年 Azhi. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {
    var downloadBtn = UIButton()
    var progressView = UIProgressView()
    var nameLabel=UILabel()
    var progressLabel=UILabel()
    var sizeLabel=UILabel()
    var speedLabel=UILabel()

    var downloadBlock:((btn:UIButton)->Void)!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle=UITableViewCellSelectionStyle.None
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func addSubviews() {
        nameLabel.font=UIFont.systemFontOfSize(15)
        nameLabel.adjustsFontSizeToFitWidth=true
        nameLabel.frame=CGRectMake(0, 0, kScreenW/2, 20)
        self.contentView.addSubview(nameLabel)
        
        sizeLabel.font=UIFont.systemFontOfSize(13)
        sizeLabel.adjustsFontSizeToFitWidth=true
        sizeLabel.frame=CGRectMake(kScreenW-100, 0, 100, 20)
        sizeLabel.textAlignment=NSTextAlignment.Right
        self.contentView.addSubview(sizeLabel)
        
        progressView.frame=CGRectMake(60, 30, kScreenW-120, 10)
        progressView.progress=0.0
        self.contentView.addSubview(self.progressView)
        
        progressLabel.font=UIFont.systemFontOfSize(12)
        progressLabel.textAlignment=NSTextAlignment.Right
        progressLabel.adjustsFontSizeToFitWidth=true
        progressLabel.frame=CGRectMake(kScreenW-60, 20, 50, 20)
        self.contentView.addSubview(progressLabel)
        
        speedLabel.font=UIFont.systemFontOfSize(12)
        speedLabel.textAlignment=NSTextAlignment.Right
        speedLabel.textColor=UIColor.redColor()
        speedLabel.frame=CGRectMake(10, 40, 100, 20)
        self.contentView.addSubview(speedLabel)
        speedLabel.hidden=true
        
        downloadBtn.frame=CGRectMake(10, 20, 40, 20)
        downloadBtn.setTitle("开始", forState: UIControlState.Normal)
        downloadBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        downloadBtn.addTarget(self, action: #selector(downloadBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(downloadBtn)
        
    }
    
    func downloadBtnClicked(btn:UIButton){
        if downloadBlock != nil {
            downloadBlock(btn:btn)
        }
    }
    
    func cellWithModel(model:DownloadModel) {
        nameLabel.text=model.name
        let isExists = NSFileManager.defaultManager().fileExistsAtPath(model.destion_path)
        if isExists {
            progressView.progress=DownloadManager.sharedManager.currentDownloadProgress(model.urlString)
            sizeLabel.text=DownloadManager.sharedManager.currentFileSize(model.urlString)
          
        }
        if progressView.progress==1.0 {
            downloadBtn.setTitle("完成", forState: UIControlState.Normal)
            downloadBtn.userInteractionEnabled=false
        }else if progressView.progress>0{
            downloadBtn.setTitle("恢复", forState: UIControlState.Normal)
        }else{
            downloadBtn.setTitle("开始", forState: UIControlState.Normal)
        }
        
    }

}
