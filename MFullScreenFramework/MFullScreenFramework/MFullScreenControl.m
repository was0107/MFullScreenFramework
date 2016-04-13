//
//  MFullScreenControl.m
//  MFullScreenFramework
//
//  Created by boguang on 15/8/20.
//  Copyright (c) 2015年 micker. All rights reserved.
//

#import "MFullScreenControl.h"
#import "MFullScreenView.h"
#import "UIImage+Full.h"

#pragma mark --
#pragma mark -- MFullScreenControl


@interface MFullScreenControl()

@property (nonatomic, strong) UIWindow                      *screenWindow;      //全屏窗体
@property (nonatomic, strong) UIView                        *contentView;       //视图容器
@property (nonatomic, strong) UIView                        *fromView;          //启动视图
@property (nonatomic, strong) UIImageView                   *sourceImageView;   //克隆的启动视图，用于动画展示

@end

@implementation MFullScreenControl {
    BOOL _isGoingOut;
    CGRect _originRect;
}

- (void) dealloc {
    _screenPageView.delegate = nil;
    _screenPageView = nil;
}

- (UIView *) contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _contentView.backgroundColor = [UIColor blackColor];
    }
    return _contentView;
}

- (UIWindow *) screenWindow {
    if (!_screenWindow) {
        _screenWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _screenWindow;
}

- (UIImageView *) sourceImageView {
    if(!_sourceImageView) {
        _sourceImageView =  [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _sourceImageView;
}


- (UIScrollPageControlView *) screenPageView {
    if(!_screenPageView) {
        _screenPageView = [[UIScrollPageControlView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _screenPageView;
}


- (void) disAppearOnView:(UIView *) view {
    [self __imageViewHideTapAction:(UIView *) view];
}


- (void) appearOnView:(UIView *) view {
    self.isAppear = YES;
    self.fromView = (UIView *)view;;
    CGRect viewFrame = [_fromView.superview convertRect:_fromView.frame toView:self.screenWindow];
    [self.screenPageView.scrollView setContentOffset:CGPointMake([self.screenPageView itemWidth] * self.screenPageView.currentIndex, 0)];

    self.sourceImageView.frame = viewFrame;
    _originRect = viewFrame;
    [self.screenWindow addSubview:self.contentView];
    
    if ([view isKindOfClass:[UIImageView class]]) {
        self.sourceImageView.image = ((UIImageView *)_fromView).image;
    }
    self.sourceImageView.backgroundColor = _fromView.backgroundColor;
    self.sourceImageView.contentMode = _fromView.contentMode;
    self.sourceImageView.clipsToBounds = _fromView.clipsToBounds;
    
    [self.screenWindow addSubview:self.sourceImageView];
    [self.screenWindow makeKeyAndVisible];
    
    viewFrame = [_sourceImageView.image getRectWithSize:[[UIScreen mainScreen] bounds].size];
    _sourceImageView.alpha = 1.0f;
    [self.screenPageView reloadData];
    [UIView animateWithDuration:0.35f animations:^{
        _sourceImageView.frame = viewFrame;
        _contentView.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [_contentView addSubview:_screenPageView];
        [_sourceImageView removeFromSuperview];
    }];
}


- (void) __imageViewHideTapAction:(UIView *) view {
    self.isAppear = NO;
    if(_screenWindow && !_isGoingOut) {
        _isGoingOut = YES;
        if(view) {
            if ([view isKindOfClass:[UIImageView class]]) {
                _sourceImageView.image = ((UIImageView *)view).image;
            }
            else if ([view isKindOfClass:[MFullScreenView class]]) {
                _sourceImageView.image = ((MFullScreenView *) view).imageView.image;
            }
            _sourceImageView.frame = [_sourceImageView.image getRectWithSize:[[UIScreen mainScreen] bounds].size];
            [_screenWindow addSubview:_sourceImageView];
            [_screenPageView removeFromSuperview];
        }
        
        [UIView animateWithDuration:view ? 0.35f : 0.0f animations:^{
            _contentView.backgroundColor = [UIColor clearColor];
            _sourceImageView.frame = _originRect;
            _sourceImageView.alpha = 0.85f;
        } completion:^(BOOL finished) {
            [_sourceImageView removeFromSuperview];
            [_screenPageView removeFromSuperview];
            [_contentView removeFromSuperview];
            [_screenWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_screenWindow removeFromSuperview];
            _screenWindow = nil;
            _isGoingOut = NO;
        }];
    }
}
@end
