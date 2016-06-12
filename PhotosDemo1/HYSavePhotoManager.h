//
//  HYSavePhotoManager.h
//  PhotosDemo1
//
//  Created by HY on 16/6/12.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface HYSavePhotoManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  执行保存操作
 *
 *  @param saveImg   要保存的图片
 *  @param albumName 要创建的相册名字
 */
- (void)saveImage:(UIImage *)saveImg albumName:(NSString *)albumName;
@end
