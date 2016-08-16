//
//  ViewingImage.h
//  JoinUs
//
//  Created by 杨春贵 on 16/5/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYTPhoto.h"

@interface ViewingImage : NSObject<NYTPhoto>

@property (nonatomic) NSString* imageName;

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
