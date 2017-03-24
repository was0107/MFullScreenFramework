//
//  UIScrollPageControlView.m
//  DW
//
//  Created by boguang on 15/6/25.
//  Copyright (c) 2015年 micker. All rights reserved.
//

#import "UIScrollPageControlView.h"
#import <objc/runtime.h>

NSString * const __CONST_REUSE_SEPERATE = @"==bg==";  //复用拆分项


#pragma mark --
#pragma mark -- UIView(_reuseIdentifier)

static char UIViewReuseIdentifier;

@implementation UIView(_reuseIdentifier)

- (void) setReuseIdentifier:(NSString *)reuseIdentifier {
    objc_setAssociatedObject(self, &UIViewReuseIdentifier, reuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *) reuseIdentifier {
    return objc_getAssociatedObject(self, &UIViewReuseIdentifier);
}

@end


#pragma mark --
#pragma mark -- UIView(_reuseIdentifier)

@interface UIScrollPageControlView()
@property (nonatomic, assign) NSInteger                     reuseStartIndex;    //复用的起始值，一般为-_maxReuseCount/2
@property (nonatomic, strong) NSMutableDictionary           *reuseDictioary;    //复用的视图
@property (nonatomic, strong) NSMutableArray                *deletateViewArrays;//超出展示区域，需要删除以备复用的视图集
@property (nonatomic, assign) NSInteger                     totalCount;
@property (nonatomic, strong) UIPanGestureRecognizer        *pangesture;        //缩放手势

@end


@implementation UIScrollPageControlView {
    NSInteger   _maxReuseCount;
    NSInteger   _totalCount;
    CGSize      _contentSize;
    NSInteger   _oldIndex;
    CGFloat     _itemSpace;
    CGRect      _screenBounds;
    CGFloat     _trigger;
    BOOL        _reloading;
}
@synthesize currentView = _currentView;

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _totalCount = 0;
        _maxReuseCount = 3;
        _currentIndex = 0;
        _oldIndex = -1;
        _contentSize = frame.size;
        _enablePageControl = YES;
        _reloading = NO;
        _reuseStartIndex = NSIntegerMin;
        
        _trigger = 0.1;
        _screenBounds = [[UIScreen mainScreen] bounds];
        [self addSubview:self.scrollView];
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
        [self addGestureRecognizer:self.pangesture];

    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    _contentSize = frame.size;
}

- (void) dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    _delegate = nil;
}

#pragma mark --
#pragma mark -- getter

- (NSMutableDictionary *) reuseDictioary {
    if (!_reuseDictioary) {
        _reuseDictioary = [NSMutableDictionary dictionaryWithCapacity:_maxReuseCount];
    }
    return _reuseDictioary;
}

- (NSMutableArray *) deletateViewArrays {
    if (!_deletateViewArrays) {
        _deletateViewArrays = [NSMutableArray array];
    }
    return _deletateViewArrays;
}

- (UIScrollView *) scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}


- (void) setCurrentIndex:(NSInteger)currentIndex {
    @synchronized(self) {
        if (_currentIndex != currentIndex && (currentIndex - self.totalCount) < 0) {
            
            [self willChangeValueForKey:@"currentIndex"];
            _oldIndex = _currentIndex;
            _currentIndex = currentIndex;
            [self didChangeValueForKey:@"currentIndex"];
            [self modifyCurrentIndex:(_currentIndex - _maxReuseCount / 2)];
            
            if (self.enablePageControl) {
                [self.scrollView.pageControl setCurrentPage:currentIndex];
            }
        }
    }
}

- (NSString *) keyAtIndex:(NSUInteger) index {
    for (NSString *key in [self.reuseDictioary allKeys]) {
        if (index == [self indexAtString:key]) {
            return key;
        }
    }
    return @"";
}


- (NSInteger) indexAtString:(NSString *) key {
    NSRange rang = [key rangeOfString:__CONST_REUSE_SEPERATE options:NSBackwardsSearch];
    if (rang.location != NSNotFound) {
        NSInteger value = [[key substringFromIndex:rang.location +rang.length] integerValue];
        return value;
    }
    return NSNotFound;
}

- (void) setReuseStartIndex:(NSInteger)reuseStartIndex {
    
    @synchronized(self) {
        _reuseStartIndex = reuseStartIndex;
        NSInteger _minIndex = MAX(self.currentIndex - _maxReuseCount/2, 0);
        NSInteger _maxIndex = MIN(self.currentIndex + _maxReuseCount/2, _totalCount-1);
        
        NSMutableArray *addKeys = [NSMutableArray array];
        NSMutableArray *outData = [NSMutableArray array];
        
        //deal with add items
        for (NSInteger index = _minIndex; index <= _maxIndex; index++) {
            NSString *key = [self keyAtIndex:index];
            if ([key length] == 0) {
                [addKeys addObject:[NSString stringWithFormat:@"%@", @(index)]];
            }
        }
        
        //remove unused items
        for (NSString *key in [self.reuseDictioary allKeys]) {
            NSInteger value = [self indexAtString:key];
            if (!(value != NSNotFound && value >= _minIndex && value <= _maxIndex)) {
                [outData addObject:key];
                UIView *viewObject = [self.reuseDictioary valueForKey:key];
                [self.deletateViewArrays addObject:viewObject];
                [self.reuseDictioary removeObjectForKey:key];
            }
        }
        
        NSMutableDictionary *reuseDic = [self.reuseDictioary mutableCopy];

        //deal with new items
        for (NSString *key in addKeys) {
            [self __configItemAt:[key integerValue]];
        }
        
        
        //reconfig reuse items
        if (self.delegate && [self.delegate respondsToSelector:@selector(reconfigItemOfControl:at:withView:)]) {
            for (NSString *key in [reuseDic allKeys]) {
                UIView *view = [reuseDic valueForKey:key];
                NSInteger index = [self indexAtString:key];
                [self.delegate reconfigItemOfControl:self
                                                at:index
                                          withView:view];
            }
        }
        [self computeCurrentView];
    }
}

- (void) computeCurrentView {
    UIView *currentViewWithIndex = [self.reuseDictioary objectForKey:[self keyAtIndex:self.currentIndex]];
    if (currentViewWithIndex) {
        self.currentView = currentViewWithIndex;
    }
}

- (void) setCurrentView:(UIView *)currentView {
    if (_currentView != currentView && currentView) {
        [self willChangeValueForKey:@"currentView"];
        _currentView = currentView;
        [self didChangeValueForKey:@"currentView"];
    }
}

- (void) modifyCurrentIndex:(NSInteger) value {
    NSInteger index = value;
    if (((index + _maxReuseCount/2) >= 0) && ((_totalCount - 1 - index) >=0) ) {
        self.reuseStartIndex = index;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([@"contentOffset" isEqualToString:keyPath] && !_reloading) {
        CGFloat contentOffsetX = self.scrollView.contentOffset.x;
        if (contentOffsetX >= 0 || contentOffsetX <= [self itemWidth] * (_totalCount - 1)) {
            self.currentIndex = (contentOffsetX  + [self itemWidth]/ 2) / [self itemWidth];
        }
    }
}

- (NSString *) reuseIdentifier:(NSString *) identifier index :(NSUInteger) index {
    return [NSString stringWithFormat:@"%@%@%@",identifier,__CONST_REUSE_SEPERATE, @(index)];
}

- (CGFloat) itemWidth {
    return (_contentSize.width + _itemSpace);
}

#pragma mark --
#pragma mark -- Action

- (void) __configItemAt:(NSUInteger) index {
    UIView *view = [self.delegate configItemOfControl:self at:index];
    CGRect viewFrame = view.frame;
    viewFrame.origin.x = index * _contentSize.width + (1 + index) * _itemSpace;
    viewFrame.origin.y = (_contentSize.height - viewFrame.size.height)/2.0f;
    view.frame = viewFrame;
    if (view.reuseIdentifier) {
        [self.reuseDictioary setObject:view forKey:[self reuseIdentifier:view.reuseIdentifier index:index]];
        view.userInteractionEnabled = YES;
        [self.scrollView addSubview:view];
    }
}

- (NSInteger) totalCount {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfView:)]) {
        _totalCount = [self.delegate numberOfView:self];
    }
    return _totalCount;
}


- (void) reloadData {
    _reloading = YES;
    [[self.scrollView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reuseIdentifier length] > 0) {
            [obj removeFromSuperview];
        }
    }];
    [self.deletateViewArrays removeAllObjects];
    [self.reuseDictioary removeAllObjects];
    
    [self setTransform:CGAffineTransformIdentity];
    self.center = CGPointMake(_screenBounds.size.width/2 ,  _screenBounds.size.height/2 );
    
    [self setTransform:CGAffineTransformIdentity];
    CGRect _screenBounds = [[UIScreen mainScreen]  bounds];
    self.center = CGPointMake(_screenBounds.size.width/2 ,  _screenBounds.size.height/2 );
    [self.scrollView.pageControl setHidden:NO];
    
    _totalCount = [self.delegate numberOfView:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(minimumRowSpacing:)]) {
        _itemSpace = [self.delegate minimumRowSpacing:self];
    }
    CGRect rect = CGRectMake(-_itemSpace, 0, _contentSize.width + 1 *_itemSpace, _contentSize.height);
    [self.scrollView setFrame:rect];
    [self.scrollView setContentSize:CGSizeMake(_totalCount * [self itemWidth]  + _itemSpace + 1, _contentSize.height)];
    
    _reloading = NO;
    if (self.enablePageControl) {
        [self.scrollView showPageControl];
        [self.scrollView.pageControl setNumberOfPages:_totalCount];
        [self.scrollView.pageControl setCurrentPage:_currentIndex];
    }
    _currentView = nil;
    [self.scrollView setContentOffset:CGPointMake([self itemWidth] * self.currentIndex, 0)];
    [self setReuseStartIndex: -_maxReuseCount / 2 + _currentIndex];
}

- (UIView *) dequeueReusableViewWithIdentifier:(NSString *) identifier {
    if (!identifier || 0 == [identifier length]) {
        return nil;
    }
    for (UIView *view in self.deletateViewArrays) {
        if ([view.reuseIdentifier isEqualToString:identifier]) {
            [self.deletateViewArrays removeObject:view];
            return view;
        }
    }
    return nil;
}


#pragma mark --
#pragma mark -- Pangesture

- (UIPanGestureRecognizer *) pangesture {
    if (!_pangesture) {
        _pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAction:)];
    }
    return _pangesture;
}


- (void) enablePanGesture:(BOOL) enable {
    [self.pangesture setEnabled:enable];
}

- (void) onPanAction:(UIPanGestureRecognizer *) gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    CGSize size = _screenBounds.size;
    float trans = 1 * translation.y/size.height;
    trans = ((translation.y < 0 ) ? 2/3 : 1) * trans;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.scrollView.pageControl setHidden:YES];
        if (self.panDelegate && [self.panDelegate respondsToSelector:@selector(onPanGestureStateChanged:isFinshed:trans:)]) {
            [self.panDelegate onPanGestureStateChanged:UIGestureRecognizerStateBegan isFinshed:NO trans:trans];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1-trans, 1-trans)];
        self.center = CGPointMake(size.width/2 + translation.x,  size.height/2 + translation.y);
        if (self.panDelegate && [self.panDelegate respondsToSelector:@selector(onPanGestureStateChanged:isFinshed:trans:)]) {
            [self.panDelegate onPanGestureStateChanged:UIGestureRecognizerStateChanged isFinshed:NO trans:trans];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (trans > _trigger) {
            if (self.panDelegate && [self.panDelegate respondsToSelector:@selector(onPanGestureStateChanged:isFinshed:trans:)]) {
                [self.panDelegate onPanGestureStateChanged:UIGestureRecognizerStateEnded isFinshed:YES trans:trans];
            }
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
            [self setTransform:CGAffineTransformIdentity];
            self.center = CGPointMake(size.width/2 ,  size.height/2 );
            if (self.panDelegate && [self.panDelegate respondsToSelector:@selector(onPanGestureStateChanged:isFinshed:trans:)]) {
                [self.panDelegate onPanGestureStateChanged:UIGestureRecognizerStateEnded isFinshed:NO trans:trans];
            }
            [self.scrollView.pageControl setHidden:NO];
        }];
    }
    
}


@end
