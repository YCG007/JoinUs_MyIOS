//
//  NetworkManager.h
//  JoinUs
//
//  Created by Liang Qian on 19/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModels.h"

@interface NetworkManager : NSObject

@property (nonatomic) UserProfile* myProfile;
@property (nonatomic) UserToken* token;

+ (NetworkManager*)sharedManager;

- (BOOL)isLoggedIn;
- (void)logout;

- (NSURLSessionDataTask*)getDataWithUrl:(NSString*)url completionHandler:(void(^)(long statusCode, NSData* data, NSString* errorMessage))completionHandler;

- (NSURLSessionDataTask*)postDataWithUrl:(NSString*)url data:(NSData*)data completionHandler:(void(^)(long statusCode, NSData* data, NSString* errorMessage))completionHandler;

- (NSURLSessionDataTask*)putDataWithUrl:(NSString*)url data:(NSData*)data completionHandler:(void(^)(long statusCode, NSData* data, NSString* errorMessage))completionHandler;

- (NSURLSessionDataTask*)deleteDataWithUrl:(NSString*)url data:(NSData*)data completionHandler:(void(^)(long statusCode, NSData* data, NSString* errorMessage))completionHandler;

- (NSURLSessionDataTask*)requestDataWithUrl:(NSString*)url method:(NSString*)method data:(NSData*)data completionHandler:(void(^)(long statusCode, NSData* data, NSString* errorMessage))completionHandler;

- (NSURLSessionDataTask*)uploadImageWithUrl:(NSString*)url data:(NSData*)data completionHandler:(void(^)(long statusCode, NSData* data, NSString* errorMessage))completionHandler;

- (NSURLSessionDataTask *)getUploadImageWithName:(NSString *)name completionHandler:(void (^)(long statusCode, NSData * data))completionHandler;

- (NSData*)getUploadImageSynchronouslyWithName:(NSString *)name;

- (NSURLSessionDataTask *)getResizedImageWithName:(NSString *)name dimension:(int)dimension completionHandler:(void (^)(long statusCode, NSData * data))completionHandler;

- (NSURLSessionDataTask *)getResizedImageWithName:(NSString *)name width:(int)width completionHandler:(void (^)(long, NSData *))completionHandler;


@end
