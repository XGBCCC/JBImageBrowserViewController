# JBImageBrowserViewController
JBImageBrowserViewController is a library enables a user to present images in fullscreen like twitter. Besides the typical pinch and double tap to zoom, we also provide a vertical swipe to dismiss. 

![](Documentation/preview.gif)

##Usage

create some images 

```swift
let image_1 = JBImage(url: NSURL(string: "http://images.apple.com/cn/chinese-new-year/images/style_large_2x.jpg"))
let image_2 = JBImage(filePathURL: NSBundle.mainBundle().URLForResource("IMG_5445", withExtension: "JPG"))
let image_3 = JBImage(image: UIImage(named: "IMG_5429"))
let failedImage = UIImage(named: "error_place_image")
```
<br/>create an instance view controller for parsent images

```swift
let imageBrowserVC = JBImageBrowserViewController(frame:CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.bounds), height: CGRectGetHeight(self.view.bounds)),imageArray: [image_1,image_2,image_3],failedPlaceholderImage:failedImage)
self.presentViewController(imageBrowserVC, animated: true, completion: nil)
```