//
//  ContentView.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var cu = CustomURLSession.shared
    
    var body: some View {
        TabView{
            AccountDataListView()
                .tabItem {
                    Label {
                        Text("关注")
                    } icon: {
                        Image(systemName: "person.2")
                    }
                }
            DownloadListView()
                .badge(cu.allDownloadTask.count)
                .tabItem {
                    Label {
                        Text("下载")
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
