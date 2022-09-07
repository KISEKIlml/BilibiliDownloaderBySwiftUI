//
//  AccountDetailView.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import SwiftUI
import CoreData
import Combine

struct LoadVideoListPrefenceKey: PreferenceKey{
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SafeAreaBottomPreferenceKey: PreferenceKey{
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

class CoreDataCombineVideo: ObservableObject{
    @Published var error: String = ""
    @Published var videos: [Video] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init(){
        addSubscribers()
    }
    
    private func addSubscribers(){
        PersistenceController.shared.videoPassThroughPublisher
            .replaceError(with: [])
            .sink { Completion in
                switch Completion{
                case .finished:
                    break
                case .failure(let error):
                    self.error = "ERROR: \(error)"
                }
            } receiveValue: { [weak self] returnValue in
                self?.videos = returnValue
            }
            .store(in: &cancellables)
    }
}

struct AccountVideoListView: View {
    let image: Image = Image("")
    
    @Binding var account: Author
    let uiWidth = (UIScreen.main.bounds.width - 24) / 2
    
    @State var vlist: [Vlist] = []
    @State var page: Page = Page(pn: 0, ps: 0, count: 0)
    @State var isload: Bool = false
    @State var scrollValue: CGFloat = .zero
    @State var noVideo = false
    @State var safeAreaBottom: CGFloat = .zero
    var dregess: CGFloat {
        let value = (UIScreen.main.bounds.height - (scrollValue + safeAreaBottom + 32))/100 * 180
        if value <= 0 {
            return 0
        }else {
            return value
        }
    }
    
    var body: some View {
        ZStack{
//            VStack{
//                Text("\(scrollValue)")
//                Text("\(UIScreen.main.bounds.height)")
//                Text("\(dregess)")
//            }
//            .background(.red)
//                .zIndex(1)
            if noVideo {
                defaultView
            }else{
                videoItems
            }
        }
        .overlay{
            GeometryReader{ proxy in
                Color.clear.preference(key: SafeAreaBottomPreferenceKey.self, value: proxy.safeAreaInsets.bottom)
            }
            .onPreferenceChange(SafeAreaBottomPreferenceKey.self) { value in
                self.safeAreaBottom = value
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarTitle(Text(account.name!))
        .refreshable {
            let (newvlist, newPage) = await AccountVideoListDataModel.fetchVideoListData(uid: Int(account.uid), page: 1)
            page = newPage
            if newvlist == [] {
                noVideo = true
            }else{
                for i in newvlist{
                    vlist.append(i)
                }
            }
        }
        .task {
            let (newvlist, newPage) = await AccountVideoListDataModel.fetchVideoListData(uid: Int(account.uid), page: 1)
            page = newPage
            if newvlist == [] {
                noVideo = true
            }else{
                for i in newvlist{
                    vlist.append(i)
                }
            }
        }
    }

    private var defaultView: some View{
        ScrollView{
            if let face = account.picture {
                Image(uiImage: UIImage(data: face)!)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial, in: Circle())
                    .padding(.vertical,5)
                
            }else{
                Image(systemName: "person")
                    .font(.largeTitle)
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial, in: Circle())
                    .padding(.vertical,5)
            }
            Text("这个UP还没有上传任何视频")
                .font(.title)
            
        }
    }
    
    private var videoItems: some View{
        ScrollView{
            let gridItem = Array(repeating: GridItem(GridItem.Size.adaptive(minimum: 120, maximum: 200), spacing: 8, alignment: .leading), count: 2)
            LazyVGrid(columns: gridItem, spacing: 8){
                ForEach(vlist, id: \.self) { video in
                    NavigationLink {
                        PlayVideoView(bvid: video.bvid)
                    } label: {
                        VideoComponent(video: video)
                    }

                }
            }
            .overlay(content: {
                if !(vlist.count < 10) {
                    GeometryReader{ proxy in
                        Color.clear.preference(key: LoadVideoListPrefenceKey.self, value: proxy.frame(in: .global).maxY)
                    }.onPreferenceChange(LoadVideoListPrefenceKey.self) { value in
                        scrollValue = value
                    }
                }
            })
            .padding(.horizontal, 8)
            
            HStack{
                if dregess < 180 {
                    Text("上拉刷新")
                }else {
                    Text("松开刷新")
                        .foregroundColor(.blue)
                }
                Image(systemName: "arrow.up.circle")
                    .rotationEffect(.degrees(dregess > 180 ? 180 : dregess))
                    .foregroundColor(dregess > 180 ? .blue : .secondary)
            }
            .frame(height: 24)
            .frame(maxWidth: .infinity, alignment: .bottom)
            
        }
        .background(Color("background"))
        /*.onChange(of: scrollValue, perform: { newValue in
            scrollViewLoad(newValue: newValue)
            if newValue > 1300 {
                refreash = true
            }
        })*/
        .onChange(of: dregess) { newValue in
            if vlist != [] {
                if newValue > 180 {
                    isload = true
                }
                if isload {
                    if newValue == 0 {
                        isload = false
                        Task.init {
                            self.page.pn = self.page.pn + 1
                            if page.pn < (maxPage() + 1) {
                                let (newvlist, _) = await AccountVideoListDataModel.fetchVideoListData(uid: Int(account.uid), page:  page.pn)
                                withAnimation(.spring(response: 1, dampingFraction: 0.8)){
                                    for i in newvlist{
                                        vlist.append(i)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*private func scrollViewLoad(newValue: CGFloat) {
        if isload {
            Task.init {
                if await (newValue + safeAreaBottom + 32) < (UIScreen.main.bounds.height - 100) {
                    isload = false
                    self.page.pn = self.page.pn + 1
                    if page.pn < (maxPage() + 1) {
                        let (newvlist, _) = await AccountVideoListDataModel.fetchVideoListData(uid: Int(account.uid), page:  page.pn)
                        for i in newvlist{
                            vlist.append(i)
                        }
                    }
                }
            }
        }
    }*/
    
    private func maxPage() -> Int {
        if page.count%20 == 0{
            return page.count/20
        }else{
            return page.count/20 + 1
        }
    }

}

//struct AccountDetailView_Previews: PreviewProvider {
//    
//    
//    static var previews: some View {
//        AccountVideoListView(account: )
//            .previewInterfaceOrientation(.portrait)
//    }
//}
