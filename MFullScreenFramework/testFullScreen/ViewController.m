//
//  ViewController.m
//  testFullScreen
//
//  Created by Micker on 16/4/14.
//  Copyright © 2016年 micker. All rights reserved.
//

#import "ViewController.h"
#import "MFullScreenControl.h"
#import "MFullScreenView.h"

@interface ViewController ()<UIScrollPageControlViewDelegate>

@property (nonatomic, strong) MFullScreenControl *control;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView1;
@property (nonatomic, strong) IBOutlet UIImageView *imageView2;
@property (nonatomic, strong) IBOutlet UIImageView *imageView3;
@property (nonatomic, strong) IBOutlet UIImageView *imageView4;
@end

@implementation ViewController

#pragma mark LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.imageView1];
    [self.view addSubview:self.imageView2];
    [self.view addSubview:self.imageView3];
    [self.view addSubview:self.imageView4];
    self.imageView.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark getter&setter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 100, 100, 100)];
        _imageView.backgroundColor = [UIColor redColor];
        _imageView.userInteractionEnabled = YES;
        _imageView.tag  = 10000;
        _imageView.image = [UIImage imageNamed:@"1"];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView  addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidTaped:)]];
    }
    return _imageView;
}

- (UIImageView *)imageView1 {
    if (!_imageView1) {
        _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _imageView1.backgroundColor = [UIColor greenColor];
        _imageView1.userInteractionEnabled = YES;
        _imageView1.tag  = 10001;
        _imageView1.clipsToBounds = YES;
        _imageView1.contentMode = UIViewContentModeScaleAspectFill;
        _imageView1.image = [UIImage imageNamed:@"l"];
        [_imageView1  addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageView2DidTaped:)]];
    }
    return _imageView1;
}

- (UIImageView *)imageView2 {
    if (!_imageView2) {
        _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, 0, 100, 100)];
        _imageView2.backgroundColor = [UIColor greenColor];
        _imageView2.userInteractionEnabled = YES;
        _imageView2.tag  = 10002;
        _imageView2.clipsToBounds = YES;
        _imageView2.contentMode = UIViewContentModeScaleAspectFill;
        _imageView2.image = [UIImage imageNamed:@"w"];
        [_imageView2  addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageView2DidTaped:)]];
    }
    return _imageView2;
}

- (UIImageView *)imageView3 {
    if (!_imageView3) {
        _imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 100, 100, 100)];
        _imageView3.backgroundColor = [UIColor greenColor];
        _imageView3.userInteractionEnabled = YES;
        _imageView3.tag  = 10003;
        _imageView3.clipsToBounds = YES;
        _imageView3.contentMode = UIViewContentModeScaleAspectFill;
        _imageView3.image = [UIImage imageNamed:@"xt"];
        [_imageView3  addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageView2DidTaped:)]];
    }
    return _imageView3;
}

- (UIImageView *)imageView4 {
    if (!_imageView4) {
        _imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, self.view.bounds.size.height - 100, 100, 100)];
        _imageView4.backgroundColor = [UIColor greenColor];
        _imageView4.userInteractionEnabled = YES;
        _imageView4.tag  = 10004;
        _imageView4.clipsToBounds = YES;
        _imageView4.contentMode = UIViewContentModeScaleAspectFill;
        _imageView4.image = [UIImage imageNamed:@"1"];
        [_imageView4  addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageView2DidTaped:)]];
    }
    return _imageView4;
}

- (MFullScreenControl *) control {
    if(!_control) {
        _control = [[MFullScreenControl  alloc] init];
        _control.screenPageView.delegate = self;
    }
    return _control;
}

#pragma mark action

- (void) imageViewDidTaped:(UIGestureRecognizer *) recognizer {
    self.control.screenPageView.currentIndex = 0;
    [self.control appearOnView:recognizer.view];
}

- (void) imageView2DidTaped:(UIGestureRecognizer *) recognizer {
    self.control.screenPageView.currentIndex = recognizer.view.tag - 10000;
    [self.control appearOnView:recognizer.view];
}

#pragma mark UIScrollPageControlViewDelegate

- (CGFloat) minimumRowSpacing:(UIScrollPageControlView *) control {
    return 10.0f;
}

- (void) reconfigItemOfControl:(UIScrollPageControlView *)control at:(NSUInteger) index withView:(UIView *)view {
    MFullScreenView *cellItem = (MFullScreenView *)view;
    [cellItem reloadData];
}

- (NSUInteger) numberOfView:(UIScrollPageControlView *) control {
    return 6;
}

- (UIView *) configItemOfControl:(UIScrollPageControlView *) control at:(NSUInteger) index  {
    MFullScreenView *cellItem = (MFullScreenView *)[control dequeueReusableViewWithIdentifier:@"reuse"];
    NSString *reuse = @"复用来的";
    UILabel *label  = nil;
    if (!cellItem) {
        cellItem = [[MFullScreenView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        cellItem.userInteractionEnabled = YES;
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
    static NSString * images[] = {@"1", @"l", @"w",@"xt"};
    cellItem.imageView.image = [UIImage imageNamed:images[index % 4]];
    [cellItem reloadData];
    label.text = [NSString stringWithFormat:@"item = %ld || reuse = %@", index,reuse];
    return cellItem;
}

@end
