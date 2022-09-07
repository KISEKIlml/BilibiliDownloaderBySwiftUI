//
//  AddAcconutSheetView.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/17.
//

import SwiftUI

struct AddAcconutSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State var uid: Int = 433351
    @Binding var isShow: Bool
    
    var body: some View {
        NavigationView{
            List{
                HStack{
                    Text("UID:")
                    TextField("Uid", value: $uid, format: .number)
                }
                Section{
                    Button {
                        Task.init {
                            //列表响应
                            PersistenceController.shared.createAuthor(updata: UpData(name: "加载中", face: "", follower: 0, uid: uid))
                            //异步加载
                            let updata = await AccountDataModel.fetchUpData(uid: uid)
                            PersistenceController.shared.authorRevise(updata: updata)
                            //加载头像
                            if updata.face != ""{
                                if let data = await PersistenceController.shared.fetchRemotePicture(url: updata.face) {
                                    PersistenceController.shared.authorRevise(data: data, uid: updata.uid)
                                }
                            }
                        }
                        dismiss()
                    } label: {
                        Text("添加")
                    }
                    .frame(width: 100, height: 30)
                    .background(.cyan)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Button {
                        PersistenceController.shared.authorDelete(uid: uid)
                        dismiss()
                    } label: {
                        Text("删除")
                    }
                    .frame(width: 100, height: 30)
                    .background(.cyan)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(Text("按UID添加"))
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "multiply")
                }

            }
        }
        .onDisappear {
            isShow = false
        }
    }
    
    
}

struct AddAcconutSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AddAcconutSheetView(isShow: .constant(false))
    }
}
