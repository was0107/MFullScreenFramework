#MFullScreenFramework控件
##前言
[MFullScreenFramework](https://github.com/was0107/MFullScreenFramewok),为实现淘宝中的商品详情页面中， 图片点击全屏展示而设计

##简介
*  支持任意视图的循环复用;
*  支持滚动视图自动添加Page展示;
*  支持图片视图的手势放大及缩小；此子视图已经进行了封装，即代码中的`MFullScreenView`
*  支持展开、关闭以动画形式进行；
*  支持设置子视图之间的间隙；


##举例
```
- (MFullScreenControl *) control {
    if(!_control) {
        _control = [[MFullScreenControl  alloc] init];
        _control.screenPageView.delegate = self;
    }
    return _control;
}

- (void) imageView2DidTaped:(UIGestureRecognizer *) recognizer {
    self.control.screenPageView.currentIndex = recognizer.view.tag - 10000;
    [self.control appearOnView:recognizer.view];
}

- (NSUInteger) numberOfView:(UIScrollPageControlView *) control {
    return 10;
}

- (UIView *) configItemOfControl:(UIScrollPageControlView *) control at:(NSUInteger) index  {
    UIImageView *cellItem = (UIImageView *)[control dequeueReusableViewWithIdentifier:@"reuse"];
    NSString *reuse = @"复用来的";
    UILabel *label  = nil;
    if (!cellItem) {
        cellItem = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
        cellItem.userInteractionEnabled = YES;
        [cellItem addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappear:)]];
        cellItem.backgroundColor  = [UIColor colorWithWhite:0.7f alpha:0.4f];
        cellItem.reuseIdentifier = @"reuse";
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
        reuse = @"=====新生成的";
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 1000;
        [cellItem addSubview:label];
        [cellItem enableDoubleTap:YES];
        cellItem.singleTapBlock = ^(UIGestureRecognizer * recognizer) {
            [_control disAppearOnView:recognizer.view];
        };
    } else {
        label = (UILabel *) [cellItem viewWithTag:1000];
    }
    
    label.text = [NSString stringWithFormat:@"item = %ld || reuse = %@", index,reuse];
    return cellItem;
}
```
##效果图展示
为更好的展示效果，GIF图片使用了黑白效果
<img src="https://raw.githubusercontent.com/was0107/MFullScreenFramework/master/images/full.gif" width="50%">


