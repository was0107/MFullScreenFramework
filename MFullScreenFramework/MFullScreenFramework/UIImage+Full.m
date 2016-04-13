//
//  UIImage+Full.m
//  MFullScreenFramework
//
//  Created by Micker on 16/3/1.
//  Copyright © 2016年 micker. All rights reserved.
//

#import "UIImage+Full.h"

@implementation UIImage (Full)

- (CGRect) getRectWithSize:(CGSize) size {
    CGFloat widthRatio = size.width / self.size.width;
    CGFloat heightRatio = size.height / self.size.height;
    CGFloat scale = MIN(widthRatio, heightRatio);
    CGFloat width = scale * self.size.width;
    CGFloat height = scale * self.size.height;
    return CGRectMake((size.width - width) / 2, (size.height - height) / 2, width, height);
}
@end
