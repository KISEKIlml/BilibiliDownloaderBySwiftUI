# BilibiliDownloaderBySwiftUI
全部使用SwiftUI原生实现，没有使用第三方的框架  
此项目可以下载B站的视频，下载的视频可以在iOS原生的文件app中查看，文件名为(视频的bvid).flv  
本项目使用的B站的api均来自<https://github.com/SocialSisterYi/bilibili-API-collect>  
## 将要实现的功能  
- [ ] 登陆，B站不登陆最高只能下载720P的视频，登陆之后可以下载更高清晰度的视频
- [ ] 在线播放，B站的视频流有防盗链，但是我不知道如何修改AVPlayer的http请求头
- [ ] 视频清晰度调整，支持下载多个清晰度版本
- [ ] 搜索
- [ ] 后台下载
- [ ] 下载队列
## 已经实现的功能  
- [x] 保存封面
- [x] 下载视频  
- [x] 中断下载
- [x] 订阅up主，将订阅的数据存放在CoreData中