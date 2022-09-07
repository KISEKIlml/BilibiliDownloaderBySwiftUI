//
//  AccountComponent.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import SwiftUI

struct AccountComponent: View {
    
    @State var image: Image = Image("")
    @Binding var author: Author
    
    var date: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_CN")
        df.doesRelativeDateFormatting = true
        df.timeStyle = .short
        df.dateStyle = .short
        return df.string(from: author.time!)
    }
    
    var authorimage: some View {
        Group{
            if author.picture != nil {
                let uiImage = UIImage(data: author.picture!)
                Image.init(uiImage: uiImage!)
                    .resizable()
                    .clipShape(Circle())
                    .transition(.scale)
            }else{
                ProgressView()
                    .clipShape(Circle())
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            authorimage
                .padding(5)
                .frame(width: 80, height: 80)
                .background(.ultraThinMaterial, in: Circle())
            
            VStack(alignment: .leading){
                Text("\(author.name!)")
                    .lineLimit(1)
                    .font(.body)
                Text("UID:\(author.uid)")
                    .font(.body)
                Text("粉丝:\(author.follower)")
                    .font(.body)
                Text(date + " 更新")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
        .transition(.move(edge: .leading))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

