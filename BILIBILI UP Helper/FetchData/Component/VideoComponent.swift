//
//  VideoComponent.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/16.
//

import SwiftUI

extension Int{
    var intToString: String{
        switch self.magnitude{
        case 1..<10000:
            return String(self.magnitude)
        case 10000... :
            let float = Float(self.magnitude%10000)
            let num: Float = Float(self.magnitude/10000) + float/10000
            return String(format: "%.1f", num) + "万"
        default:
            return String(self.magnitude)
        }
    }
}

struct VideoComponent: View {
    @Environment(\.colorScheme) var colorScheme
    @State var video: Vlist
    @State var picData: Data?
    @State var picIsLoad: Bool = true
    var overpicBackgroundColor: Color{
        if colorScheme == .light {
            return .black
        }else if colorScheme == .dark{
            return .white
        }else{
            return .black
        }
    }
    let uiWidth = (UIScreen.main.bounds.width - 24) / 2
    
    var body: some View {
        VStack{
            videoPic
                .frame(width: uiWidth, height: uiWidth * ( 9 / 16))
                .overlay{
                    picOverlay(video: video)
                }
            VStack(spacing: 4){
                Text("\(video.title)")
                    .lineLimit(1)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(time)")
                    .lineLimit(1)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .background()
        .mask({
            RoundedRectangle(cornerRadius: 10, style: .continuous)
        })
        .transition(.scale)
        .task{
            if let data = await PersistenceController.shared.fetchRemotePicture(url: video.pic){
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    picData = data
                }
            }else{
                //加载失败
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    picIsLoad = false
                }
            }
        }
    }
    
    var time: String {
        let df = DateFormatter()
        df.doesRelativeDateFormatting = true
        df.locale = Locale(identifier: "zh_CN")
        df.timeStyle = .medium
        df.dateStyle = .short
        return df.string(from: Date(timeIntervalSince1970: TimeInterval(video.created)))
    }
    
    var videoPic: some View{
        Group{
            if picIsLoad {
                if picData != nil {
                    let uiImage = UIImage(data: picData!)?.preparingThumbnail(of: CGSize(width: 320, height: 180))
                    Image(uiImage: uiImage!)
                        .resizable()
                        .interpolation(.low)
                        .transition(.scale)
                }else{
                    ProgressView()
                        .transition(.scale)
                }
            }else{
                Image(systemName: "exclamationmark.icloud")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 5, y: 5)
                    .transition(.scale)
            }
        }
    }
    
    private func picOverlay(video: Vlist) -> some View{
        var overlay: some View{
            HStack(alignment: .center, spacing: 2){
                Image(systemName: "play.rectangle")
                Text("\(video.play.intToString)")
                Image(systemName: "list.bullet.indent")
                Text("\(String(video.comment))")
                Spacer()
                Text("\(video.length)")
            }
            .foregroundStyle(.regularMaterial)
            .font(.caption2)
            .frame(height: 10)
            .padding(8)
            .background{
                Rectangle()
                    .foregroundStyle(.linearGradient(colors: [overpicBackgroundColor.opacity(0.7), overpicBackgroundColor.opacity(0.4), overpicBackgroundColor.opacity(0.2), overpicBackgroundColor.opacity(0)], startPoint: .bottom, endPoint: .top))
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        return overlay
    }
    
}

struct VideoComponent_Previews: PreviewProvider {
    static var previews: some View {
        VideoComponent(video: Vlist(comment: 1000, play: 10000, pic: "jhgjhgjgj", title: "asdad", mid: 0, created: 0, length: "dfs", video_review: 0, bvid: "hgfhgfhg"))
    }
}
