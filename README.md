# TTMultiYoutubePlayers
A project that shows multiple youtube players that is natively(no Webview) implemented. Made, by a friend's idea, in Japan:p

### Environment
* macOS 10.14(Mojave)~
* Xcode 10.0~
* iPhone with iOS 11.0~

### Build Step
1. Clone the project.
1. Run `pod install` in command line at the root of the project path.
1. Run `carthage bootstrap --platform ios` at the same path above.(see [Install Carthage](https://github.com/Carthage/Carthage#installing-carthage) if necessary)
1. Replace the access key of YouTube Data API [here](https://github.com/inexcii/TTMultiYoutubePlayers/blob/master/TTMultiYoutubePlayers/Constants.swift#L21) by yours.
1. Hit 'Run' button in Xcode.

### Frameworks
* GoogleAPIClientForREST: to fetch Youtube video data
* RxSwift/RxCocoa: to bind data and UI
* R.swift: to manage resources
* Nuke: to handle image-related tasks
* XCDYouTubeKit: to transfer `videoId` fetched from GoogleAPIClientForREST to a AVPlayer-usable streaming URL

### Functions
Major:
- [X] show and play multiple(currently 2) YouTube videos on the same scene
- [X] each video can be played/paused, seeked, display current playing time and duration
- [X] a mute button for controlling each audio's on-and-off
- [X] User can draw lines, by their finger, on the screen(inside the video area) while playing the video. Also, The line degree should be displayed somewhere and is calculated between start x,y and end x,y.
- [X] user can seek video at a rate as low as 1 frame
- [X] support dark-mode
- [X] user can access to the watched-video history, and quickly replay it from there
- [X] a single play/pause button to control both players
---
v2.0.0
- [ ] user can input a time value and video should be played from that point
- [ ] when in landscape mode, app should also support two video players side-by-side

Minor:
- [ ] User can pick a color to draw lines on the screen. Also, the lines drawn by user before should be shown again once the same video is selected later.
- [ ] The app remembers the angle and the color of the lines. This is an app-based parameter, not a video based parameter.
- [ ] the playback rate can be set to 0.5x, 1.0x ~ 10.0x at a gap per 0.5x to play video as slow as 0.5x and as fast till 10.0x
- [ ] a seek-bar to control multiple videos at the same time
- [ ] each video can be played in slow-mode
