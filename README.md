# MTZImageFacePan

[![CI Status](http://img.shields.io/travis/Michael Tzach/MTZImageFacePan.svg?style=flat)](https://travis-ci.org/Michael Tzach/MTZImageFacePan)
[![Version](https://img.shields.io/cocoapods/v/MTZImageFacePan.svg?style=flat)](http://cocoapods.org/pods/MTZImageFacePan)
[![License](https://img.shields.io/cocoapods/l/MTZImageFacePan.svg?style=flat)](http://cocoapods.org/pods/MTZImageFacePan)
[![Platform](https://img.shields.io/cocoapods/p/MTZImageFacePan.svg?style=flat)](http://cocoapods.org/pods/MTZImageFacePan)

## Usage

**ImageFacePan** is easy to use. It has two class methods that render a UIImage from another UIImage.
The simple way to use it, is to use
```objectivec
+(UIImage *)renderImageFromImage:(UIImage *)image toFitSize:(CGSize)destinationSize;
```
When using this method, all you have to do is pass the image and the destination size of the image. the rendering will crop the image to put all faces in the frame without zooming. This method uses the destination size's aspect ratio.

**If cropping without a zoom is not enough**, you should use
```objectivec
+(UIImage *)renderImageFromImage:(UIImage *)image withOptions:(MTZImageFacePanOptions *)options;
```
This method requires you to pass it an options object where you can set a minimumWidth, minimumHeight and maximumZoomFactor. This allows panning with zooming.

#Purpose
This library is for all the cases where when you are using fill in an imageView and some of the faces in the image are left out of the frame.

#Use Examples
**Original Image**
<p align=center>
    <img src="https://raw.githubusercontent.com/MichaelTzach/MTZImageFacePan/master/Pod/Assets/IMG_0406.jpg" width=200 />
</p>

## Installation

**ImagePicker** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MTZImageFacePan"
```

## Author

Michael Tzach, michael.tzach@jivesoftware.com

##License

```
Copyright 2013-2016 Jive Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```