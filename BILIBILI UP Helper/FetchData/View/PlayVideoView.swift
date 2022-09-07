//
//  PlayVideoView.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/17.
//

import SwiftUI
import AVKit

struct PlayVideoView: View {
    @StateObject var customURLSession = CustomURLSession.shared
    @State var videoDetail: VideoDetail = VideoDetail(code: 0, data: VideoDetail.Data(bvid: "NODATA", videos: 1, pic: "NODATA", title: "NODATA", pubdate: 1, desc: "NODATA", stat: VideoDetail.Stat(aid: 0, view: 0, favorite: 0, coin: 0, like: 0), cid: 1))
    @State var videoUrl: VideoURL?
    var bvid: String
    
    var time: String {
        let df = DateFormatter()
        df.doesRelativeDateFormatting = true
        df.locale = Locale(identifier: "zh_CN")
        df.timeStyle = .medium
        df.dateStyle = .medium
        return df.string(from: Date(timeIntervalSince1970: TimeInterval(videoDetail.data.pubdate)))
    }
    
    var body: some View {
        List{
            Section(header: Text("视频封面")){
                AsyncImage(url: URL(string: videoDetail.data.pic)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
            }
            
            Section(header: Text("下载")){
                if customURLSession.allDownloadTask[bvid] != nil {
                    ProgressView(customURLSession.allDownloadTask[bvid]!.progress)
                }else{
                    Button{
                        customURLSession.sessionSeniorDownload(urlStr: (videoUrl?.data.durl[0].backup_url[0])!, bvid: bvid)
                        print(videoUrl?.data.durl[0].url ?? "no url")
                    }label: {
                        Text("下载视频")
                    }
                    .disabled(videoUrl == nil)
                }
            }
            
            Section(header: Text("视频数据")){
                Text(videoDetail.data.title)
                Text(videoDetail.data.desc)
                Text("发布时间:" + time)
                Text(bvid)
                HStack{
                    Text("点赞:\(videoDetail.data.stat.like)")
                    Spacer()
                    Text("硬币:\(videoDetail.data.stat.coin)" )
                    Spacer()
                    Text("收藏:\(videoDetail.data.stat.favorite)")
                }
            }
            
        }
        .listStyle(.sidebar)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let vd = await VideoDetailModel.fetchVideoDetailData(bvid: bvid){
                withAnimation {
                    videoDetail = vd
                }
            }
            videoUrl = await VideoURLModel.fetchVideoURLData(bvid: bvid, cid: videoDetail.data.cid)
        }
        
    }
}

struct PlayVideoView_Previews: PreviewProvider {
    static var previews: some View {
        PlayVideoView(bvid: "BV1gB4y1z7QZ")
    }
}
