//
//  UIScrollView+PageControl.m
//  DW
//
//  Created by boguang on 15/7/3.
//  Copyright (c) 2015年 micker. All rights reserved.
//

#import "UIScrollView+PageControl.h"
#import <objc/runtime.h>

#pragma mark --
#pragma mark DetailPageControl

@interface DetailPageControl : UIPageControl

@end

@implementation DetailPageControl

- (void) setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];    
    for (NSUInteger subViewIndex = 0 ; subViewIndex < [self.subviews count]; subViewIndex ++) {
        UIImageView *imageView = [self.subviews objectAtIndex:subViewIndex];
        CGRect rect = imageView.frame;
        rect.size.width = rect.size.height = 7.5f;
        imageView.layer.cornerRadius = 4.0f;
        imageView.layer.masksToBounds = YES;
        [imageView setFrame:rect];
    }
}

@end

#pragma mark --
#pragma mark UIScrollView (PageControl)

@implementation UIScrollView (PageControl)

- (UIPageControl *) pageControl {
    return  objc_getAssociatedObject(self, _cmd);
}

- (void) setPageControl:(UIPageControl *)pageControl {
    [self willChangeValueForKey:@"pageControl"];
    objc_setAssociatedObject(self, @selector(pageControl), pageControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"pageControl"];
}

- (void) showPageControl {
    if (!self.pageControl) {
        UIPageControl *control = [[DetailPageControl alloc]
                                  initWithFrame:CGRectMake(0, self.frame.origin.y + self.bounds.size.height - 40, self.bounds.size.width, 20)];
        control.backgroundColor = [UIColor clearColor];
        [control setEnabled:NO];
        control.pageIndicatorTintColor = [UIColor colorWithWhite:0.7 alpha:1];;
        control.currentPageIndicatorTintColor = [UIColor redColor];
        [self.superview addSubview:control];
        [self setPageControl:control];
    }
    [self.superview bringSubviewToFront:self.pageControl];
}


- (void) computePageControlPages {
    self.pageControl.numberOfPages = self.contentSize.width / self.frame.size.width;
    [self.pageControl setCurrentPage:(self.contentOffset.x + self.frame.size.width/2)/ self.frame.size.width];
}

@end
