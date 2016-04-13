//
//  MFullScreenView.m
//  MFullScreenFramework
//
//  Created by Micker on 16/2/14.
//  Copyright © 2016年 micker. All rights reserved.
//

#import "MFullScreenView.h"
#import "UIImage+Full.h"

#define kMinZoomScale 1.0f
#define kMaxZoomScale 2.5f

@interface MFullScreenView() <UIScrollViewDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation MFullScreenView

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollview];
    }
    return self;
}

- (UIScrollView *) scrollview {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _scrollView.frame =[[UIScreen mainScreen] bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [_scrollView addSubview:self.imageView];
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
    }
    return _scrollView;
}

- (UIImageView *) imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (UITapGestureRecognizer *) doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired  =1;
    }
    return _doubleTap;
}

- (UITapGestureRecognizer *) singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
        _singleTap.delaysTouchesBegan = YES;
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    return _singleTap;
}

- (void) onDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (!self.isDoubleTapEnabled) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:self];
    if (self.scrollview.zoomScale <= 1.0) {
        CGFloat scaleX = touchPoint.x + self.scrollview.contentOffset.x;
        CGFloat sacleY = touchPoint.y + self.scrollview.contentOffset.y;
        [self.scrollview zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
        
    } else {
        [self.scrollview setZoomScale:1.0 animated:YES];
    }
}

- (void) onSingleTap:(UITapGestureRecognizer *)recognizer {
    if (self.singleTapBlock) {
        self.singleTapBlock(recognizer);
    }
}

- (void) enableDoubleTap:(BOOL)isDoubleTapEnabled {
    _isDoubleTapEnabled = isDoubleTapEnabled;
    if (_isDoubleTapEnabled) {
        [self addGestureRecognizer:self.doubleTap];
        [self addGestureRecognizer:self.singleTap];
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    [self adjustFrame];
}

- (void) adjustFrame {
    CGRect frame = self.scrollview.frame;
    if (self.imageView.image) {
        self.imageView.frame = [self.imageView.image getRectWithSize:[[UIScreen mainScreen] bounds].size];
        self.scrollview.contentSize = self.imageView.frame.size;
        self.imageView.center = [self centerOfScrollViewContent:self.scrollview];
        
        CGSize imageSize = self.imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (frame.size.width<=frame.size.height) {
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        }
        CGFloat maxHeightScale = frame.size.height/imageFrame.size.height;
        if (maxHeightScale < 1.0f) {
            maxHeightScale = 1.0f / maxHeightScale;
        }
        self.scrollview.minimumZoomScale = kMinZoomScale;
        self.scrollview.maximumZoomScale = MAX(kMaxZoomScale, maxHeightScale);
        [self.scrollview setZoomScale:1.0 animated:YES];
    } else {
        frame.origin = CGPointZero;
        self.imageView.frame = frame;
        self.scrollview.contentSize = self.imageView.frame.size;
    }
    self.scrollview.contentOffset = CGPointZero;
}

- (void) reloadData {
    _scrollView.frame = self.bounds;
    [self adjustFrame];
}

#pragma mark ==
#pragma mark UIScrollViewDelegate

- (CGPoint) centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
                        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
                        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark UIScrollViewDelegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

@end
