//
//  HYSavePhotoManager.m
//  PhotosDemo1
//
//  Created by HY on 16/6/12.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "HYSavePhotoManager.h"

@implementation HYSavePhotoManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


/**
 *  获得刚才添加到【相机胶卷】中的图片
 */
- (PHFetchResult<PHAsset *> *)createdAssetsWithImage:(UIImage *)saveImage
{
    __block NSString *createdAssetId = nil;
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:saveImage].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

/**
 *  获得【自定义相册】
 */
- (PHAssetCollection *)createdCollectionWithTitle:(NSString *)albumTitle
{
    // 获取软件的名字作为相册的标题
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    title = @"就是这么任性";
    title = albumTitle;
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    // 代码执行到这里，说明还没有自定义相册
    
    __block NSString *createdCollectionId = nil;
    
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil) return nil;
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}


/**
 *  保存图片到相册
 */
- (void)saveImageIntoAlbum:(UIImage *)saveImg albumName:(NSString *)albumName
{
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = [self createdAssetsWithImage:saveImg];
    
    // 获得相册
    PHAssetCollection *createdCollection = [self createdCollectionWithTitle:albumName];
    
    if (createdAssets == nil || createdCollection == nil) {
        //        [SVProgressHUD showErrorWithStatus:@"保存失败！"];
        NSLog(@"保存失败！");
        return;
    }
    
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 保存结果
    if (error) {
        //        [SVProgressHUD showErrorWithStatus:@"保存失败！"];
        NSLog(@"保存失败！");
    } else {
        //        [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
        NSLog(@"保存成功！");
    }
}
/**
 *  执行保存操作
 *
 *  @param saveImg   要保存的图片
 *  @param albumName 要创建的相册名字
 */
- (void)saveImage:(UIImage *)saveImg albumName:(NSString *)albumName {
    /*
     requestAuthorization方法的功能
     1.如果用户还没有做过选择，这个方法就会弹框让用户做出选择
     1> 用户做出选择以后才会回调block
     
     2.如果用户之前已经做过选择，这个方法就不会再弹框，直接回调block，传递现在的授权状态给block
     */
    
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    //  保存图片到相册
                    [self saveImageIntoAlbum:saveImg albumName:albumName];
                    break;
                }
                    
                case PHAuthorizationStatusDenied: {
                    if (oldStatus == PHAuthorizationStatusNotDetermined)
                    NSLog(@"提醒用户打开相册的访问开关");
                     return;
                    break;
                }
                    
                case PHAuthorizationStatusRestricted: {
                    //                    [SVProgressHUD showErrorWithStatus:@"因系统原因，无法访问相册！"];
                    NSLog(@"因系统原因，无法访问相册！");
                    break;
                }
                    
                default:
                    break;
            }
        });
    }];
}

@end
