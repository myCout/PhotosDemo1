//
//  ViewController.m
//  PhotosDemo1
//
//  Created by HY on 16/6/12.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "ViewController.h"
#import "HYSavePhotoManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)save {
    [[HYSavePhotoManager sharedInstance] saveImage:self.imageView.image albumName:@"就是这么任性"];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
