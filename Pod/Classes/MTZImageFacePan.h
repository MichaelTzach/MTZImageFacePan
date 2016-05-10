//
//  MTZImageFacePan.h
//  FaceDetection
//
//  Created by Michael Tzach on 4/4/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

@interface MTZImageFacePanOptions : NSObject

-(instancetype)init __unavailable;

-(instancetype)initWithAspectRatio:(CGFloat)aspectRatio;

//Convinience for setting the aspect ratio
-(instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height;

//Required

// width : height
// This will ensure the photo to come back in this aspect ratio
// This does not override the other settings
@property (nonatomic, readonly) CGFloat aspectRatio;

//Optional - default for all is 0
@property (nonatomic) CGFloat minimumWidth; //If possible, will not produce images with smaller width. This is mainly for optimization and it is recommended that you set this to the size of the requested image
@property (nonatomic) CGFloat minimumHeight; //Same as maximumWidth
@property (nonatomic) CGFloat maximumZoomFactor; //Should be bigger than 1.0

@end

@interface MTZImageFacePan : NSObject

//Non-blocking

+(void)renderImageFromImage:(UIImage *)image withOptions:(MTZImageFacePanOptions *)options finishedRenderingBlockOnMainQueue:(void(^)(UIImage *renderedImage))finishedRendering;

+(void)renderImageFromImage:(UIImage *)image withOptions:(MTZImageFacePanOptions *)options finishedRenderingBlock:(void(^)(UIImage *renderedImage))finishedRenderingBlock performBlockOnQueue:(dispatch_queue_t)queue;


//Blocking

+(UIImage *)renderImageFromImage:(UIImage *)image withOptions:(MTZImageFacePanOptions *)options;

+(UIImage *)renderImageFromImage:(UIImage *)image toFitSize:(CGSize)destinationSize;

@end
