//
//  Persistence.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import CoreData
import Combine
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer
    
    let authorPassThroughPublisher = PassthroughSubject<[Author], Error>()
    
    let videoPassThroughPublisher = PassthroughSubject<[Video], Error>()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newAuthor = NSEntityDescription.insertNewObject(forEntityName: "Author", into: viewContext) as! Author
        newAuthor.uid = 433351
        newAuthor.follower = 114514
        newAuthor.name = "EdmundDZhang"
        newAuthor.face = ""
        newAuthor.time = Date()
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "BILIBILI_UP_Helper")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    
    func fetchRemotePicture(url: String) async -> Data?{
        do{
            if case let (data?, _) = try await URLSession.shared.data(from: URL(string: url)!) {
                return data
            }
            return nil
        }catch{
            print("头像获取失败")
            return nil
        }
    }
}

//Author增删改查函数实现
extension PersistenceController {
    
    //创建新的订阅Up
    func createAuthor(updata: UpData) {
        let authorsByUid = fetchAuthorByUid(uid: updata.uid)
        if authorsByUid == []{
            let context = container.viewContext
            let fetchAuthor = NSFetchRequest<Author>(entityName: "Author")
            let newAuthor = NSEntityDescription.insertNewObject(forEntityName: "Author", into: context) as! Author
            newAuthor.name = updata.name
            newAuthor.face = updata.face
            newAuthor.follower = Int64(updata.follower)
            newAuthor.uid = Int64(updata.uid)
            newAuthor.time = Date()
            if context.hasChanges {
                do {
                    try context.save()
                    //发送新保存的数据
                    self.authorPassThroughPublisher.send(try context.fetch(fetchAuthor))
                    print("Insert new book(\(updata.name)) successful.")
                } catch {
                    print("\(error)")
                }
            }
        }else {
            return
        }
    }
    
    //修改up数据
    func authorRevise(updata: UpData, isSend: Bool = true){
        let context = container.viewContext
        
        let authors = fetchAuthorByUid(uid: updata.uid)
        if authors == []{
            print("修改操作：没有找到uid：\(updata.uid)")
            return
        }else {
            for i in authors {
                i.name = updata.name
                i.face = updata.face
                i.follower = Int64(updata.follower)
                i.uid = Int64(updata.uid)
                i.time = Date()
                i.picture = nil
            }
            do{
                try context.save()
                if isSend {
                    let fetchRequst = NSFetchRequest<Author>(entityName: "Author")
                    let allAuthor = try context.fetch(fetchRequst)
                    self.authorPassThroughPublisher.send(allAuthor)
                    print("发送成功")
                }
            }catch{
                print("修改操作：保存失败uid：\(updata.uid)")
            }
            print("修改uid:\(updata.uid)成功")
        }
    }
    
    //修改up头像
    func authorRevise(data: Data, uid: Int, isSend: Bool = true){
        let context = container.viewContext
        
        
        let authors = fetchAuthorByUid(uid: uid)
        if authors == []{
            print("保存头像：没有找到uid：\(uid)项目")
            return
        }else{
            for author in authors{
                author.picture = data
            }
        }
        do{
            try context.save()
            if isSend {
                let fetchRequst = NSFetchRequest<Author>(entityName: "Author")
                let authors = try context.fetch(fetchRequst)
                self.authorPassThroughPublisher.send(authors)
                print("发送成功")
            }
        }
        catch{
            print("保存头像：保存失败")
        }
    }
    
    //按照uid查找up
    func fetchAuthorByUid(uid: Int) -> [Author]{
        let context = container.viewContext
        let fetchRequstByUid = NSFetchRequest<Author>(entityName: "Author")
        fetchRequstByUid.predicate = NSPredicate(format: "uid = \"" + String(uid) + "\"")
        do{
            let authors = try context.fetch(fetchRequstByUid)
            return authors
        }catch{
            print("requst \(uid) author error")
            return []
        }
    }
    
    //删除up
    func authorDelete(uid: Int){
        let context = container.viewContext
        let fetchRequst = NSFetchRequest<Author>(entityName: "Author")
        withAnimation {
            do{
                let authors = fetchAuthorByUid(uid: uid) //try context.fetch(fetchRequstByUid)
                for i in authors {
                    context.delete(i)
                }
                try context.save()
                self.authorPassThroughPublisher.send(try context.fetch(fetchRequst))
            }catch{
                print("fetch \(uid) error")
            }
        }
    }
    
    //按照获取的下标删除up
    func authorDeleteByIndex(index: IndexSet){
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequst = NSFetchRequest<Author>(entityName: "Author")
        withAnimation {
            do {
                let authors = try viewContext.fetch(fetchRequst)
                index.map { authors[$0] }.forEach(viewContext.delete)
                try viewContext.save()
                self.authorPassThroughPublisher.send(try viewContext.fetch(fetchRequst))
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    //按照返回的Author对象删除up
    func authorDeleteByAuthor(index: Author){
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequst = NSFetchRequest<Author>(entityName: "Author")
        withAnimation(.spring()) {
            do {
                //let authors = try viewContext.fetch(fetchRequst)
                viewContext.delete(index)
                try viewContext.save()
                self.authorPassThroughPublisher.send(try viewContext.fetch(fetchRequst))
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    //获取up的数量
    func authorsCount() -> Int{
        let context = container.viewContext
        let fetchAuthor = NSFetchRequest<Author>(entityName: "Author")
        do {
            let authors = try context.fetch(fetchAuthor)
            return authors.count
        } catch {
            print("Fetch Author Error")
            return 0
        }
    }
    
    //遍历数据库，用于初始化视图
    func parseEntities() {
        let entities = container.managedObjectModel.entities
        let context = container.viewContext
        let fetchRequst = NSFetchRequest<Author>(entityName: "Author")
        do{
            self.authorPassThroughPublisher.send(try context.fetch(fetchRequst))
        }
        catch{
            print("PublisherSendERROR")
        }
        print("Entity count = \(entities.count)\n")
        for entity in entities {
            print("Entity: \(entity.name!)")
            for property in entity.properties {
                print("Property: \(property.name)")
            }
            print("")
        }
    }
    
    func showAllAuthorByCreated() {
        let viewContext = container.viewContext
        let fetchAuthor = NSFetchRequest<Author>(entityName: "Author")
        fetchAuthor.sortDescriptors = [NSSortDescriptor(key: "uid", ascending: true)]
        
        do{
            self.authorPassThroughPublisher
                .send( try viewContext.fetch(fetchAuthor))
        }catch {
            print("howAllVideoByCreated")
        }
    }
}

//Video增删改查函数实现
extension PersistenceController{
    func createVideoItem(video: Vlist) {
        
        let context = container.viewContext
        let fetchVideo = NSFetchRequest<Video>(entityName: "Video")
        let newVideoItem = NSEntityDescription.insertNewObject(forEntityName: "Video", into: context) as! Video
        let author = fetchAuthorByUid(uid: video.mid)
        if author == [] {
            return
        }else{
            newVideoItem.author = author[0]
        }
        newVideoItem.bvid = video.bvid
        newVideoItem.mid = Int64(video.mid)
        newVideoItem.created = Int64(video.created)
        newVideoItem.comment = Int64(video.comment)
        newVideoItem.play = Int64(video.play)
        newVideoItem.pic = video.pic
        newVideoItem.length = video.length
        newVideoItem.title = video.title
        newVideoItem.time = Date()
        
        
        if context.hasChanges {
            do {
                try context.save()
                //发送新保存的数据
                self.videoPassThroughPublisher.send(try context.fetch(fetchVideo))
                print("Insert new book(\(video.bvid)) successful.")
            } catch {
                print("\(error)")
            }
        }
    }
    
    func showAllVideoByCreated() {
        let viewContext = container.viewContext
        let fetchVideo = NSFetchRequest<Video>(entityName: "Video")
        fetchVideo.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        
        do{
            self.videoPassThroughPublisher.send( try viewContext.fetch(fetchVideo))
        }catch {
            print("howAllVideoByCreated")
        }
    }
}
