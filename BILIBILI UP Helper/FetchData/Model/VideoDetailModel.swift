//
//  VideoDetailModel.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/9/8.
//

import Foundation

struct VideoDetail: Codable{
    let code: Int
    let data: Data
}
extension VideoDetail{
    struct Data: Codable{
        let bvid: String
        let videos: Int
        let pic: String
        let title: String
        let pubdate: Int
        let desc: String
        let stat: Stat
        let cid: Int
    }
    struct Stat: Codable{
        let aid: Int
        let view: Int
        let favorite: Int
        let coin: Int
        let like: Int
    }
}

class VideoDetailModel{
    static func fetchVideoDetailData(bvid: String) async -> VideoDetail? {
        do{
            let urlString = "http://api.bilibili.com/x/web-interface/view?bvid=" + bvid
            let url = URL(string: urlString)!
            let (data, _) = try await URLSession.shared.data(from: url)
            print("fetch VideoDetaildata succes")
            let videoDetail = try JSONDecoder().decode(VideoDetail.self, from: data)
            return videoDetail
        }catch{
            print("FetchError")
            return nil
        }
    }
}
