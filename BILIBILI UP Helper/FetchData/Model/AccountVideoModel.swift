//
//  DetailDataModel.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import Foundation

struct VideoListData: Codable{
    let code: Int
    let message: String
    let ttl: Int
    let data: Data
}

struct Vlist: Codable, Hashable{
    var comment: Int
    var play: Int
    var pic: String
    var title: String
    var mid: Int
    var created: Int
    var length: String
    var video_review: Int
    var bvid: String
}
struct Page: Codable{
    var pn: Int//当前页码
    let ps: Int//每页项数
    let count: Int//总稿件数
}
extension VideoListData{
    struct Data: Codable{
        struct VedioList: Codable{
            var vlist: [Vlist]
        }
        let list: VedioList
        let page: Page
    }
}

class AccountVideoListDataModel{
    
    static func fetchVideoListData(uid: Int, page: Int, ps: Int = 20) async -> ([Vlist], Page) {
        do{
            let urlString = "http://api.bilibili.com/x/space/arc/search?mid=" + String(uid) + "&pn=" + String(page) + "&ps=" + String(ps)
            let url = URL(string: urlString)!
            let (data, _) = try await URLSession.shared.data(from: url)
            print("fetch data succes")
            let videoList = try JSONDecoder().decode(VideoListData.self, from: data)
            return (videoList.data.list.vlist, videoList.data.page)
        }catch{
            print("FetchError")
            return ([], Page(pn: 0, ps: 0, count: 0))
        }
    }
    
}
