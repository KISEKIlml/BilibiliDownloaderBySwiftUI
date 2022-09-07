//
//  CustomURLSession.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/9/7.
//
import SwiftUI
import Foundation

class CustomURLSession: NSObject, URLSessionDownloadDelegate, ObservableObject {
     
    static var shared = CustomURLSession()
    
    @Published var allDownloadTask = [String: URLSessionDownloadTask]()
    
    var fileName: String = ""
    
    private lazy var session:URLSession = {
        //只执行一次
        let config = URLSessionConfiguration.default
        let currentSession = URLSession(configuration: config, delegate: self,
                                        delegateQueue: nil)
        return currentSession
 
    }()
    
    //下载文件
    func sessionSeniorDownload(urlStr: String, bvid: String){
        
        //下载地址
        let url = URL(string: urlStr)
        //请求
        var request = URLRequest(url: url!)
        request.addValue("https://www.bilibili.com", forHTTPHeaderField: "Referer")
        
        //下载任务
        let downloadTask = session.downloadTask(with: request)
        
        allDownloadTask[bvid] = downloadTask
        
        //使用resume方法启动任务
        downloadTask.resume()
    }
 
     
    //下载代理方法，下载结束
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        //下载结束
        print("下载结束")
         
        //输出下载文件原来的存放目录
        print("location:\(location)")
        //location位置转换
        let locationPath = location.path
        
        for (id, task) in allDownloadTask{
            if task == downloadTask{
                //拷贝到用户目录
                let documnets:String = NSHomeDirectory() + "/Documents/" + id + ".flv"
                //创建文件管理器
                let fileManager = FileManager.default
                do{
                    try fileManager.moveItem(atPath: locationPath, toPath: documnets)
                    print("new location:\(documnets)")
                }catch{
                    print("移动失败")
                }
            }
        }
    }
     
    //下载代理方法，监听下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        //获取进度
        let written:CGFloat = (CGFloat)(totalBytesWritten)
        let total:CGFloat = (CGFloat)(totalBytesExpectedToWrite)
        let pro:CGFloat = written/total
        print("下载进度：\(pro)")
    }
     
    //下载代理方法，下载偏移
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        //下载偏移，主要用于暂停续传
    }
     
}
