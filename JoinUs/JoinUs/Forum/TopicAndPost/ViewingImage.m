//
//  ViewingImage.m
//  JoinUs
//
//  Created by 杨春贵 on 16/5/23.
//  Copyright © 2016年 North Gate Code. All rights reserved.
//

#import "ViewingImage.h"
#import "Utils.h"
#import "NetworkManager.h"

@implementation ViewingImage

- (UIImage *)image {
    
    //同步操作，等待返回之后才执行下一步
    NSData *data = [[NetworkManager sharedManager] getUploadImageSynchronouslyWithName:_imageName];
    
    if (data != nil) {
        return [UIImage imageWithData:data];
    }
    
    return [UIImage imageNamed:@"no_image"];
}

@end
