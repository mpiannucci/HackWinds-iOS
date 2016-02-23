HackWinds-iOS
=====================

![icon](https://raw.githubusercontent.com/mpiannucci/HackWinds-iOS/master/HackWindsWatchApp/Assets.xcassets/CircleWatchLogo.imageset/88x88.png)

[Download from the App Store now!](https://itunes.apple.com/us/app/hackwinds/id945847570?ls=1&mt=8)

Displays the live HD feed and the live still images from the surf camera at [Narragansett Town Beach](http://www.warmwinds.com/surf-cam/) in Rhode Island. Also scrapes wave forecast information from [RhodyCast](http://forecast.mpiannucci.com), [NOAA](http://www.ndbc.noaa.gov) and [Wunderground](http://www.wunderground.com/?apiref=b80661e4fc362f50).

Project Layout
----------------
By folder, here is a description of the top level directories:
`HackWinds`: The main iOS Application Target.
`HackWindsCommon`: All shared code between targets. The internal folders specify what targets it is shared by (eg. The `DataKit` folder is shared by all the DataKit Framework targets, while the `Extensions` folder is shared by the Swift widgets and extensions. 

`HackWindsTodayWidget`: "Today" notification center widget for iOS

`HackWindsWatchApp`: The WatchOS 2 Bundle target

`HackWindsWatchApp Extension`: The extension that the WatchOS APP launches. 

`HackWindsTodayOSX`: OSX Notification center widget target

`HackWindsDataKit`: iOS data kit target

`HackWindsDataKitOSX`: OSX data kit target

`HackWindsDataKitWatchOS`: WatchOS 2 data kit target

Status
---------------
Current status by platform

`iOS`: In production, live on the App Store

`WatchOS`: In production! 

`OSX`: In beta, just needs icons and stuff.

Disclaimer 
----------------

I do not own or claim to own neither the wave camera images or the forecast information displayed in this app. This app is simply an interface to make checking the waves easier for surfers when using a phone. I am speifically operating within the user licensing for the MagicSeaweed and Wunderground API's.

License
-----------------
This project is realeased under the [MIT License](https://github.com/mpiannucci/HackWinds-iOS/blob/master/LICENSE).
