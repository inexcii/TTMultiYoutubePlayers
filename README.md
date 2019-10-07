# TTMultiYoutubePlayers
A project that shows multiple youtube players that is natively(no Webview) implemented. Made, by a friend's idea, in Japan:p

### Environment
* macOS 10.14(Mojave)~
* Xcode 10.0~
* iPhone with iOS 11.0~

### Build Step
1. Clone the project.
1. Run `pod install` in command line at the root of the project path.
1. Replace the access key of YouTube Data API [here](https://github.com/inexcii/TTMultiYoutubePlayers/blob/master/TTMultiYoutubePlayers/Constants.swift#L21) by yours.
1. Hit 'Run' button in Xcode.

### Frameworks
* GoogleAPIClientForREST: to fetch Youtube video data
* RxSwift/RxCocoa: to bind data and UI
* R.swift: to manage resources
* Nuke: to handle image-related tasks
* XCDYouTubeKit: to transfer `videoId` fetched from GoogleAPIClientForREST to a AVPlayer-usable streaming URL

