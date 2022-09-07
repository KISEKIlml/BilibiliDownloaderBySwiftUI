//
//  VideoURLModel.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/9/8.
//

import Foundation

struct VideoURL: Codable{
    let code: Int
    let data: Data
}
extension VideoURL{
    struct Data: Codable{
        let accept_quality: [Int]
        let durl: [Durl]
    }
    struct Durl: Codable{
        let size: Int
        let url: String
        let backup_url: [String]
    }
}




class VideoURLModel{
    static func fetchVideoURLData(bvid: String, cid: Int) async -> VideoURL? {
        do{
            let urlString = "http://api.bilibili.com/x/player/playurl?bvid=" + bvid + "&cid=" + String(cid) + "&qn=64"
            let url = URL(string: urlString)!
            let (data, _) = try await URLSession.shared.data(from: url)
            print("fetch data succes")
            let videoUrl = try JSONDecoder().decode(VideoURL.self, from: data)
            print(videoUrl)
            return videoUrl
        }catch{
            print("FetchError")
            return nil
        }
    }
}
