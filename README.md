# MediaSwitch

After watching my Dad meticulously rip his entire CD collection onto his laptop with the goal of transferring them to his iTunes library, the idea for MediaSwitch was ignited. Similar to how Shazam finds songs through audio, MediaSwitch finds albums from images, enabling users to quickly transfer their entire CD collection to Spotify or Apple Music. Using Google’s ML Kit cloud text-recognition API, album titles are extracted from images of stacks of CDs; the app then searches Spotify or Apple Music catalogs for these albums, the results are displayed and the user can add them all to their library with one tap.

<img align="center" src="gifs/gif1.gif" data-canonical-src="gifs/gif1.gif" width="400" height="800" />

## Pre-requisites

~ Paid Apple Music or Spotify subscription.     
~ CDs, cassettes or images of CD's or cassettes.        

Required SDK's:

  pod 'Alamofire'     
  pod 'Firebase/Core'     
  pod 'Firebase/Database'     
  pod 'Firebase/MLVision'       
  pod 'Firebase/MLVisionTextModel'      
  pod 'FSPagerView'     
  pod 'Kingfisher', '~> 5.0'      
  pod 'NVActivityIndicatorView'     
  pod 'SwiftyJSON'      
  pod 'SwiftJWT'    
  pod 'QCropper'    
  

## Getting Started
Clone or download the project and run the xcworkspace file. Install the podfiles listed above. 

On first launch the app presents a choice of connecting to an Apple Music or Spotify account. If a paid Apple Music subscription is detected, a User Token is requested and stored for API calls. If no subscription is detected, the user is presented with an option to subscribe. Tapping the Spotify button will switch to the Spotify app and ask the user to authorise MediaSwitch. Once the user has successfully connected to either service, an image can be added from the users library or through taking a photo. The image should be of a stack of up to 25 CD’s (spines) where the album title and artist is visible. 

Tapping the ‘Extract albums from image’ button will make multiple calls to the Spotify or Apple Music search API, parsing JSON album results into Album objects. The album results are displayed on the next view controller in a collection view using the album’s artwork and titles data. Searches that returned multiple results are indicated with a plus (+) button on the album cover. Tapping the plus button displays a secondary collection view - allowing the user to swap the album for an alternative one. Selecting cells (album objects) and tapping the trash button will remove those albums from the results array. The user can then tap the Spotify/Apple Music button to add the albums to their library. 

Spotify will add the albums to a user’s library immediately, Apple Music needs to be refreshed for the new albums to appear. To force the update:

Mac: File menu -> Library -> Update Cloud Library.
                
iPhone: add a new track or album / amend a playlist manually in the Music app and your albums added from MediaSwitch will appear.


## Support
[MediaSwitch Website](https://wilmslo.wixsite.com/mediaswitch)

Watch demo video on [YouTube](https://youtu.be/Up6liYU-bpk)

## License
RentSpace is Copyright © 2020 Sean Williams. It is free software, and may be redistributed under the terms specified in the LICENSE file.
