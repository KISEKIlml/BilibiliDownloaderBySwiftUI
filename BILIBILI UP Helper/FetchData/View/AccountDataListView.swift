//
//  UpDataTestView.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import SwiftUI
import Combine
import CoreData

class CoreDataCombineAuthor: ObservableObject{
    @Published var error: String = ""
    @Published var authors: [Author] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init(){
        addSubscribers()
    }
    
    private func addSubscribers(){
        PersistenceController.shared.authorPassThroughPublisher
            .replaceError(with: [])
            .sink { Completion in
                switch Completion{
                case .finished:
                    break
                case .failure(let error):
                    self.error = "ERROR: \(error)"
                }
            } receiveValue: { [weak self] returnValue in
                self?.authors = returnValue
            }
            .store(in: &cancellables)
    }
}

struct AccountDataListView: View {
    
    @StateObject var cdca = CoreDataCombineAuthor()
    @State var isShowAddView = false
    @Environment(\.refresh) private var refresh: RefreshAction?
    @State var onRefresh: Bool = false
    
    var body: some View {
        NavigationView {
            List{
//                Text("\(PersistenceController.shared.authorsCount())位up主")
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .listRowSeparator(.hidden)
                Section {
                    ForEach($cdca.authors, id: \.self) { value in
                        NavigationLink {
                            AccountVideoListView(account: value)
                        } label: {
                            AccountComponent(author: value)
                                .transition(.move(edge: .leading))
                        }
                    }
                    .onDelete { IndexSet in
                        PersistenceController.shared.authorDeleteByIndex(index: IndexSet)
                    }
                }
            }
            .listStyle(.plain)
            .sheet(isPresented: $isShowAddView, onDismiss: {
                isShowAddView = false
            }, content: {
                AddAcconutSheetView(isShow: $isShowAddView)
            })
            .navigationTitle("Up主列表")
            .toolbar {
                ToolbarItem {
                    HStack(spacing: 0){
                        EditButton()
                        Button {
                            isShowAddView = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .frame(width: 30, height: 30)
                        }
                        
                        Button {
                            Task {
                                withAnimation {
                                    onRefresh = true
                                }
                                for author in cdca.authors {
                                    let updata = await AccountDataModel.fetchUpData(uid: Int(author.uid))
                                    PersistenceController.shared.authorRevise(updata: updata, isSend: false)
                                    //加载头像
                                    if updata.face != ""{
                                        if let data = await PersistenceController.shared.fetchRemotePicture(url: updata.face) {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)){
                                                PersistenceController.shared.authorRevise(data: data, uid: updata.uid, isSend: false)
                                            }
                                        }
                                    }
                                }
                                PersistenceController.shared.parseEntities()
                                withAnimation {
                                    onRefresh = false
                                }
                            }
                        }label: {
                            if !onRefresh {
                                Image(systemName: "goforward")
                                    .transition(.scale)
                                    .frame(width: 25, height: 25)
                            }else{
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                                    .frame(width: 25, height: 25)
                            }
                        }
                        .disabled(onRefresh != false)
                    }
                }
                ToolbarItem {
                    
                }
            }
        }
        .task {
            //初始化列表视图
            PersistenceController.shared.showAllAuthorByCreated()
        }
        .refreshable {
            for author in cdca.authors {
                let updata = await AccountDataModel.fetchUpData(uid: Int(author.uid))
                PersistenceController.shared.authorRevise(updata: updata, isSend: false)
                //加载头像
                if updata.face != ""{
                    if let data = await PersistenceController.shared.fetchRemotePicture(url: updata.face) {
                        PersistenceController.shared.authorRevise(data: data, uid: updata.uid, isSend: false)
                    }
                }
            }
            PersistenceController.shared.parseEntities()
        }
    }
    
    
}

struct UpDataTestView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDataListView()
    }
}
