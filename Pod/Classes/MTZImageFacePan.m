//
//  MTZImageFacePan.m
//  FaceDetection
//
//  Created by Michael Tzach on 4/4/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "MTZImageFacePan.h"


@implementation MTZImageFacePanOptions

#pragma mark - Initializers

-(instancetype)initWithAspectRatio:(CGFloat)aspectRatio {
    if (aspectRatio <= 0) return nil;
    
    self = [super init];
    if (self) {
        _aspectRatio = aspectRatio;
        [self commonInitialized];
    }
    return self;
}

-(instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height {
    if (width <= 0 || height <= 0) return nil;
    
    self = [super init];
    if (self) {
        _aspectRatio = width / height;
        [self commonInitialized];
    }
    return self;
}

-(void)commonInitialized {
    self.minimumWidth = 0;
    self.minimumHeight = 0;
    self.maximumZoomFactor = 0;
}

#pragma mark - Setters

-(void)setMaximumZoomFactor:(CGFloat)maximumZoomFactor {
    if (maximumZoomFactor >= 1.0) {
        _maximumZoomFactor = maximumZoomFactor;
    }
}

-(void)setMinimumWidth:(CGFloat)minimumWidth {
    if (minimumWidth > 0) {
        _minimumWidth = minimumWidth;
    }
}

-(void)setMinimumHeight:(CGFloat)minimumHeight {
    if (minimumHeight > 0) {
        _minimumWidth = minimumHeight;
    }
}

-(NSString *)description {
    NSArray<NSString *> *desc = @[[NSString stringWithFormat:@"Aspect ratio: %@", @(self.aspectRatio)],
                                  [NSString stringWithFormat:@"Minimum Width: %@", self.minimumWidth == 0 ? @"Not set" : [@(self.minimumWidth) stringValue]],
                                  [NSString stringWithFormat:@"Minimum Height: %@", self.minimumHeight == 0 ? @"Not set" : [@(self.minimumHeight) stringValue]],
                                  [NSString stringWithFormat:@"Maximum Zoom Factor: %@", self.maximumZoomFactor == 0 ? @"Not set" : [@(self.maximumZoomFactor) stringValue]]
                                  ];
    return [desc componentsJoinedByString:@"\n"];
}

@end


@implementation MTZImageFacePan

#pragma mark - Public

+(UIImage *)renderImageFromImage:(UIImage *)image withOptions:(MTZImageFacePanOptions *)options {
    NSArray<CIFaceFeature *> *faceFeatures = [self faceFeaturesInImage:image];
    if (![faceFeatures count]) {
        return image;
    }
    
    CGSize imageSizeWithFixedScale = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    
    faceFeatures = [self filterFaceFeatures:faceFeatures];
    
    CGRect ciCoordnatesAllFacesRect = [self rectContainingAllFaceBounds:faceFeatures];
    CGRect uiKitCoordinatesAllFacesRect = [self CICoordinatesRectToUIKitCoordinatesRect:ciCoordnatesAllFacesRect inReferenceHeight:imageSizeWithFixedScale.height];
    
    CGRect correctRatioRect = [self expandRect:uiKitCoordinatesAllFacesRect toMatchAspectRatio:options.aspectRatio withMaximumSize:imageSizeWithFixedScale];
    
    CGRect filledRect = [self expandRect:correctRatioRect minimumWidth:options.minimumWidth withOriginalImageSize:imageSizeWithFixedScale];
    filledRect = [self expandRect:filledRect minimumHeight:options.minimumHeight withOriginalImageSize:imageSizeWithFixedScale];
    filledRect = [self expandRect:filledRect maximumScalingFactor:options.maximumZoomFactor withOriginalImageSize:imageSizeWithFixedScale];
    
    return [self cropImage:image toRect:filledRect];
}

+(UIImage *)renderImageFromImage:(UIImage *)image toFitSize:(CGSize)destinationSize {
    NSArray<CIFaceFeature *> *faceFeatures = [self faceFeaturesInImage:image];
    if (![faceFeatures count]) {
        return image;
    }
    
    CGSize imageSizeWithFixedScale = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    
    faceFeatures = [self filterFaceFeatures:faceFeatures];
    
    CGRect ciCoordnatesAllFacesRect = [self rectContainingAllFaceBounds:faceFeatures];
    CGRect uiKitCoordinatesAllFacesRect = [self CICoordinatesRectToUIKitCoordinatesRect:ciCoordnatesAllFacesRect inReferenceHeight:imageSizeWithFixedScale.height];
    
    CGFloat destinationSizeAspectRatio = destinationSize.width / destinationSize.height;
    CGRect correctRatioRect = [self expandRect:uiKitCoordinatesAllFacesRect toMatchAspectRatio:destinationSizeAspectRatio withMaximumSize:imageSizeWithFixedScale];
    
    CGRect filledRect = [self expandRect:correctRatioRect toFillSize:imageSizeWithFixedScale inAspectRatio:destinationSizeAspectRatio];
    
    return [self cropImage:image toRect:filledRect];
}



#pragma mark - Private

+(NSArray<CIFaceFeature *> *)filterFaceFeatures:(NSArray<CIFaceFeature *> *)faceFeatures {
    NSMutableArray<CIFaceFeature *> *faces = [[NSMutableArray alloc] init];
    
    CGFloat biggestFace = 0;
    for (CIFaceFeature *face in faceFeatures) {
        biggestFace = MAX(biggestFace, face.bounds.size.width);
    }
    
    for (CIFaceFeature *face in faceFeatures) {
        if (face.bounds.size.width >= biggestFace / 2.5) {
            [faces addObject:face];
        }
    }
    return faces;
}

//rectToExpand should be in the correct aspect ratio
+(CGRect)expandRect:(CGRect)rectToExpand minimumWidth:(CGFloat)minimumWidth withOriginalImageSize:(CGSize)originalImageSize {
    if (minimumWidth <= 0) return rectToExpand;
    
    minimumWidth = MIN(minimumWidth, originalImageSize.width);
    if (minimumWidth <= rectToExpand.size.width) return rectToExpand; //Breaking point: the function cant shrink
    
    CGFloat scalingFactor = minimumWidth / rectToExpand.size.width;
    CGFloat finalHeight = rectToExpand.size.height * scalingFactor;
    if (finalHeight > originalImageSize.height) { //Case where using the width scaling factor makes the height bigger than the original image size
        CGFloat heightScalingFactor = originalImageSize.height / rectToExpand.size.height;
        if (heightScalingFactor < 1) return rectToExpand; //Breaking point
        scalingFactor = heightScalingFactor;
    }
    
    //At this point scalingFactor is the only certain variable. we know for sure that it is bigger than 1
    finalHeight = rectToExpand.size.height * scalingFactor;
    CGFloat finalWidth = rectToExpand.size.width * scalingFactor;
    
    CGFloat heightToAdd = finalHeight - rectToExpand.size.height;
    CGFloat widthToAdd = finalWidth - rectToExpand.size.width;
    
    CGRect retRect = CGRectMake(rectToExpand.origin.x - (widthToAdd / 2), rectToExpand.origin.y - (heightToAdd / 2), finalWidth, finalHeight);
    retRect = [self moveRect:retRect intoBounds:originalImageSize];
    
    return retRect;
}

//rectToExpand should be in the correct aspect ratio
+(CGRect)expandRect:(CGRect)rectToExpand minimumHeight:(CGFloat)minimumHeight withOriginalImageSize:(CGSize)originalImageSize {
    if (minimumHeight <= 0) return rectToExpand;
    
    minimumHeight = MIN(minimumHeight, originalImageSize.height);
    if (minimumHeight <= rectToExpand.size.height) return rectToExpand; //Breaking point: the function cant shrink
    
    CGFloat scalingFactor = minimumHeight / rectToExpand.size.height;
    CGFloat finalWidth = rectToExpand.size.width * scalingFactor;
    if (finalWidth > originalImageSize.width) { //Case where using the height scaling factor makes the width bigger than the original image size
        CGFloat widthScalingFactor = originalImageSize.width / rectToExpand.size.width;
        if (widthScalingFactor < 1) return rectToExpand; //Breaking point
        scalingFactor = widthScalingFactor;
    }
    
    //At this point scalingFactor is the only certain variable. we know for sure that it is bigger than 1
    finalWidth = rectToExpand.size.width * scalingFactor;
    CGFloat finalHeight = rectToExpand.size.height * scalingFactor;
    
    CGFloat widthToAdd = finalWidth - rectToExpand.size.width;
    CGFloat heightToAdd = finalHeight - rectToExpand.size.height;
    
    CGRect retRect = CGRectMake(rectToExpand.origin.x - (widthToAdd / 2), rectToExpand.origin.y - (heightToAdd / 2), finalWidth, finalHeight);
    retRect = [self moveRect:retRect intoBounds:originalImageSize];
    
    return retRect;
}

+(CGRect)expandRect:(CGRect)rectToExpand maximumScalingFactor:(CGFloat)maximumScalingFactor withOriginalImageSize:(CGSize)originalImageSize {
    if (maximumScalingFactor < 1) return rectToExpand;
    
    //both scaling factors should be bigger than 1
    CGFloat heightScalingFactor = originalImageSize.height / rectToExpand.size.height;
    CGFloat widthScalingFactor = originalImageSize.width / rectToExpand.size.width;
    
    if (heightScalingFactor <= maximumScalingFactor && widthScalingFactor <= maximumScalingFactor) return rectToExpand; //No need to expand
    
    CGFloat maxExpandScale = MIN(heightScalingFactor, widthScalingFactor); //The scale we should expand the rect to
    CGFloat expandScale = maxExpandScale / maximumScalingFactor;
    
    //At this point we know we should expand the rect with expandScale and that it is bigger than 1
    CGFloat finalWidth = rectToExpand.size.width * expandScale;
    CGFloat finalHeight = rectToExpand.size.height * expandScale;
    
    CGFloat widthToAdd = finalWidth - rectToExpand.size.width;
    CGFloat heightToAdd = finalHeight - rectToExpand.size.height;
    
    CGRect retRect = CGRectMake(rectToExpand.origin.x - (widthToAdd / 2), rectToExpand.origin.y - (heightToAdd / 2), rectToExpand.origin.x + rectToExpand.size.width + (widthToAdd / 2), rectToExpand.origin.y + rectToExpand.size.height + (heightToAdd / 2));
    
    retRect = [self moveRect:retRect intoBounds:originalImageSize];
    
    return retRect;
}

//Returns a new rect that has the same aspect ratio as the destionation rect which is at least as big as the interest rect and with the same origin
+(CGRect)expandRect:(CGRect)rectToExpand toMatchAspectRatio:(CGFloat)destinationAspedctRatio withMaximumSize:(CGSize)maximumSize {
    CGFloat rectToExpandAR = rectToExpand.size.width / rectToExpand.size.height;
    CGRect retRect;
    
    //No need to expand
    if (rectToExpandAR == destinationAspedctRatio) return rectToExpand;
    
    //Need to add height
    if (rectToExpandAR > destinationAspedctRatio) {
        CGFloat destinationHeight = rectToExpand.size.width / destinationAspedctRatio;
        
        //Case where to expand, you p
        if (destinationHeight > maximumSize.height) {
            return CGRectMake(0, 0, maximumSize.width, maximumSize.height);
        }
        
        CGFloat heightToAdd = destinationHeight - rectToExpand.size.height;
        retRect = CGRectMake(rectToExpand.origin.x, rectToExpand.origin.y - (heightToAdd / 2), rectToExpand.size.width, rectToExpand.size.height + heightToAdd);
    }
    
    //Need to add width
    else {
        CGFloat destinationWidth = rectToExpand.size.height * destinationAspedctRatio;
        
        //Case where to expand, you p
        if (destinationWidth > maximumSize.width) {
            return CGRectMake(0, 0, maximumSize.width, maximumSize.height);
        }
        
        CGFloat widthToAdd = destinationWidth - rectToExpand.size.width;
        retRect = CGRectMake(rectToExpand.origin.x - (widthToAdd / 2), rectToExpand.origin.y, rectToExpand.size.width + widthToAdd, rectToExpand.size.height);
    }
    
    //Put retRect in frame bounds if expand put it out
    retRect = [self moveRect:retRect intoBounds:maximumSize];
    
    return retRect;
}

+(CGRect)moveRect:(CGRect)rectToMove intoBounds:(CGSize)boundSize {
    CGRect retRect = CGRectMake(rectToMove.origin.x, rectToMove.origin.y, rectToMove.size.width, rectToMove.size.height);
    retRect.origin.x = MAX(0, retRect.origin.x);
    retRect.origin.y = MAX(0, retRect.origin.y);
    
    CGFloat horizontalOutOfBounds = boundSize.width - (retRect.origin.x + retRect.size.width);
    if (horizontalOutOfBounds < 0) {
        retRect.origin.x += horizontalOutOfBounds;
    }
    
    CGFloat verticalOutOfBounds = boundSize.height - (retRect.origin.y + retRect.size.height);
    if (verticalOutOfBounds < 0) {
        retRect.origin.y += verticalOutOfBounds;
    }
    
    return retRect;
}

+(CGSize)shrinkSize:(CGSize)sizeToShrink toAspectRatio:(CGFloat)aspectRatio {
    CGFloat sizeToShrinkAspectRatio = sizeToShrink.width / sizeToShrink.height;
    
    CGSize retSize;
    
    if (sizeToShrinkAspectRatio > aspectRatio) {
        retSize = CGSizeMake(aspectRatio * sizeToShrink.height, sizeToShrink.height);
    } else {
        retSize = CGSizeMake(sizeToShrink.width, sizeToShrink.width / aspectRatio);
    }
    
    return retSize;
}

//Either the height or the width of the rectToExpand will match sizeToFill while maintaining the original aspect ratio
//rectToExpand should be in the correct aspect ratio
+(CGRect)expandRect:(CGRect)rectToExpand toFillSize:(CGSize)sizeToFill inAspectRatio:(CGFloat)aspectRatio {
    //Resize sizeToFill to correct aspect ratio
    sizeToFill = [self shrinkSize:sizeToFill toAspectRatio:aspectRatio];
    
    CGFloat heightToAddToFill = sizeToFill.height - rectToExpand.size.height;
    CGFloat widthToAddToFill = sizeToFill.width - rectToExpand.size.width;
    
    CGRect retRect;
    
    //Expand to fill width
    if (heightToAddToFill > widthToAddToFill) {
        CGFloat resizeFactor = sizeToFill.width / rectToExpand.size.width;
        CGFloat finalHeight = rectToExpand.size.height * resizeFactor;
        CGFloat heightToAdd = finalHeight - rectToExpand.size.height;
        
        retRect = CGRectMake(rectToExpand.origin.x - (widthToAddToFill / 2), rectToExpand.origin.y - (heightToAdd / 2), sizeToFill.width, finalHeight);
    }
    
    //Expand to fill height
    else {
        CGFloat resizeFactor = sizeToFill.height / rectToExpand.size.height;
        CGFloat finalWidth = rectToExpand.size.width * resizeFactor;
        CGFloat widthToAdd = finalWidth - rectToExpand.size.width;
        
        retRect = CGRectMake(rectToExpand.origin.x - (widthToAdd / 2), rectToExpand.origin.y - (heightToAddToFill / 2), finalWidth, sizeToFill.height);
    }
    
    //Put retRect in frame bounds if expand put it out
    retRect = [self moveRect:retRect intoBounds:sizeToFill];
    
    return retRect;
}


+(NSArray<CIFaceFeature *> *)faceFeaturesInImage:(UIImage *)image {
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    NSArray *features = [detector featuresInImage:ciImage options:nil];
    return features;
}

+(UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
    UIImage *imageRet = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, rect)];
    return imageRet;
}

//Returned rect has core image coordinate system (y from bottom)
//If faces is empty, returns CGRectZero
+(CGRect)rectContainingAllFaceBounds:(NSArray<CIFaceFeature *> *)faces {
    CGRect containingRect = CGRectZero;
    
    if (![faces count]) {
        return CGRectZero;
    }
    
    for (CIFaceFeature *faceFeature in faces) {
        if (CGRectEqualToRect(containingRect, CGRectZero)) {
            containingRect = faceFeature.bounds;
        }
        containingRect = CGRectUnion(containingRect, faceFeature.bounds);
    }
    
    return containingRect;
}

+(CGRect)CICoordinatesRectToUIKitCoordinatesRect:(CGRect)rect inReferenceHeight:(CGFloat)height {
    //Copy rect
    CGRect returnRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    returnRect.origin.y = height - rect.origin.y - rect.size.height;
    return returnRect;
}

@end
