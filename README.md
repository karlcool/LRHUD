# LRHUD

`LRHUD` 是老牌项目SVProgressHUD的纯swift完整实现。但是编写过程中灵感迸发，所以进行了一系列的改写。
主要改进如下:

1.主要样式可以通过协议实现深度定制

2.支持swift异步编程

3.去除原项目对切片的依赖，使项目更轻量化

## Demo		

就在这里

## 集成

### 使用CocoaPods集成

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like `SVProgressHUD` in your projects. First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'LRHUD'
```
### 手动集成

* Drag the `LRHUD/Class` folder into your project.

## 快速上手

### Show
```swift
LRHUD.show()
await LRHUD.show()
```
```swift
LRHUD.show(status: "loading")
await LRHUD.show(status: "loading")
```
```swift
LRHUD.show(progress: 0.5, status: "loading")
await LRHUD.show(progress: 0.5, status: "loading")
```
```swift
LRHUD.show(image: some, status: "loading")
await LRHUD.show(image: some, status: "loading")
```
```swift
LRHUD.show(info: "this is info")
await LRHUD.show(info: "this is info")
```
```swift
LRHUD.show(success: "this is success")
await LRHUD.show(success: "this is success")
```
```swift
LRHUD.show(error: "this is error")
await LRHUD.show(error: "this is error")
```

### Dismiss
```swift
LRHUD.dismiss()
await LRHUD.dismiss()
await LRHUD.dismissWaitCompletion()
```

## 个性化定制

### 通过协议进行深度定制化

#### 实现此协议可以定制HUD的loading样式
内置了IndefiniteAnimatedView和UIActivityIndicatorView
```swift
public protocol IndefiniteAnimated where Self: UIView 

static func register(indefiniteAnimatedViewClass: IndefiniteAnimated.Type)
```

#### 实现此协议可以定制HUD的progress样式
```swift
public protocol ProgressAnimated where Self: UIView 

static func register(progressAnimatedViewClass: ProgressAnimated.Type)
```

#### 实现此协议可以定制HUD的status样式
内置了ImageAnimatedView和LRImageView

```swift
public protocol ImageAnimated where Self: UIView 

static func register(imageAnimatedViewClass: ImageAnimated.Type)
```

### 设置属性实现简单定制化
```swift
static func set(status: String) 

static func set(style: Style)
	
static func set(maskStyle: MaskStyle)
	
static func register(indefiniteAnimatedViewClass: IndefiniteAnimated.Type)
	
static func register(progressAnimatedViewClass: ProgressAnimated.Type)
	
static func register(imageAnimatedViewClass: ImageAnimated.Type)
	
static func set(containerView: UIView?)
	
static func set(minimumSize: CGSize)
	
static func set(ringThickness: CGFloat)
	
static func set(ringRadius: CGFloat)
	
static func set(ringNoTextRadius: CGFloat)
	
static func set(cornerRadius: CGFloat)
	
static func set(borderColor: UIColor?)
	
static func set(borderWidth: CGFloat) 
	
static func set(font: UIFont)
	
static func set(hudForegroundColor: UIColor)
	
static func set(hudBackgroundColor: UIColor)

static func set(backgroundColor: UIColor)

static func set(imageViewSize: CGSize)

static func set(graceTimeInterval: TimeInterval)

static func set(minimumDismissTimeInterval: TimeInterval)

static func set(maximumDismissTimeInterval: TimeInterval) 

static func set(fadeInAnimationDuration: TimeInterval) 

static func set(fadeOutAnimationDuration: TimeInterval)

static func set(maxSupportedWindowLevel: UIWindow.Level) 

static func set(hapticsEnabled: Bool)

static func setOffsetFromCenter(offset: UIOffset) 

static func resetOffsetFromCenter() 
```

## License

MIT License

Copyright (c) 2021 Related Code

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
