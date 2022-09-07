//
//  UpData.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import Foundation
import SwiftUI

//获取up主粉丝数量
struct Follower: Codable{
    let code: Int
    let message: String
    let ttl: Int
    let data: Data?
}
extension Follower{
    struct Data: Codable{
        let mid: Int
        let follower: Int
    }
}

//获取up主昵称和头像等基础信息
struct UpFaceAndName: Codable{
    let code: Int
    let message: String
    let ttl: Int
    let data: Data?
}
extension UpFaceAndName{
    struct Data: Codable{
        let mid: Int
        let name: String
        let face: String
    }
}

struct UpData: Hashable{
    var name: String
    var face: String
    var follower: Int
    var uid: Int
}

class AccountDataModel{
    static func fetchUpData(uid: Int) async -> UpData{
        do{
            let urlStringData = "https://api.bilibili.com/x/space/acc/info?mid=" + String(uid) + "&jsonp=jsonp"
            let urlStringFollower = "https://api.bilibili.com/x/relation/stat?vmid=" + String(uid) + "&jsonp=jsonp"
            let url = URL(string: urlStringData)!
            let urlFollower = URL(string: urlStringFollower)!
            let (data, _) = try await URLSession.shared.data(from: url)
            let (follower, _) = try await URLSession.shared.data(from: urlFollower)
            let bilibiliUpData = try JSONDecoder().decode(UpFaceAndName.self, from: data)
            let bilibiliFollower = try JSONDecoder().decode(Follower.self, from: follower)
            if bilibiliUpData.code == 0{
                let updata = UpData(name: bilibiliUpData.data!.name, face: bilibiliUpData.data!.face, follower: bilibiliFollower.data!.follower, uid: uid)
                return updata
            }else{
                let updata = UpData(name: bilibiliUpData.message, face: "", follower: -400, uid: uid)
                return updata
            }
        }catch{
            print("FetchError")
            return UpData(name: "获取失败，请刷新", face: "", follower: -400, uid: uid)
        }
    }
    
}
