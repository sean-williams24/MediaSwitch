# MediaSwitch

After watching my Dad meticulously rip his entire CD collection onto his laptop with the goal of transferring them to his iTunes library, the idea for MediaSwitch was ignited. Similar to how Shazam finds songs through audio, MediaSwitch finds albums from images, enabling users to quickly transfer their entire CD collection to Spotify or Apple Music. Using Google’s ML Kit cloud text-recognition API, album titles are extracted from images of stacks of CDs; the app then searches Spotify or Apple Music catalogs for these albums, the results are displayed and the user can add them all to their library with one tap.

<img align="center" src="gifs/gif1.gif" data-canonical-src="gifs/gif1.gif" width="400" height="800" />

## Pre-requisites
SDK's included in repo:
- Firebase
- YPImagePicker
- GoogleSignIn
- Facebook login 
- NVActivityIndicatorView
- FSPagerView

## Getting Started
Clone or download the project and run the xcworkspace file. Podfiles are included but if there are any issues the required pods are listed above. 

On first launch the app will establish the users location and search for spaces within a 100 mile radius; these parameters can be adjusted byt tapping on the location displayed on the navigation bar, once a category has been selected. Spaces are ordered in distance from the user. When viewing a spaces' details, the user has various options of actions they can perform; add it to favourites, in-app message, call or email space owner, obtain directions via Apple maps.

Users can access full functionality by registering an email address and password or signing in with Facebook or Google. This will enable the user to post/advertise their own spaces. On successful post the adverts will immediately appear in the 'MySpaces' tab. By selecting a space in MySpaces, the user is able to edit or delete their advert. Chats appear in the 'Messages' tab and can be removed by swiping to delete. 

RentSpace is availabe to download from the [App Store.](https://apps.apple.com/gb/app/rentspace/id1500549065#?platform=iphone)

## Support
[RentSpace Website](https://wilmslo.wixsite.com/rentspace)

Watch demo video on [YouTube](https://www.youtube.com/watch?v=44AcKI1WNXg&feature=youtu.be)

## License
RentSpace is Copyright © 2020 Sean Williams. It is free software, and may be redistributed under the terms specified in the LICENSE file.
