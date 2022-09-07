//
//  DownloadListView.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/9/8.
//

import SwiftUI

struct DownloadListView: View {
    @StateObject var customURLSession = CustomURLSession.shared
    var key: [String] {
        var ary:[String] = []
        for (i, _) in customURLSession.allDownloadTask{
            ary.append(i)
        }
        return ary
    }
    
    var body: some View {
        NavigationView{
            List{
                if customURLSession.allDownloadTask.isEmpty {
                    Text("没有下载任务")
                }else{
                    ForEach(key, id: \.self) { keyValue in
                        VStack{
                            Text(keyValue)
                            ProgressView(customURLSession.allDownloadTask[keyValue]!.progress)
                        }
                        .swipeActions {
                            Button{
                                customURLSession.allDownloadTask[keyValue]?.cancel()
                                customURLSession.allDownloadTask[keyValue] = nil
                            }label: {
                                Image(systemName: "delete.backward")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .navigationTitle(Text("下载列表"))
        }
    }
}

struct DownloadListView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadListView()
    }
}
