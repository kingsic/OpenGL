//
//  SplitScreenVC.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/3.
//

#import "SplitScreenVC.h"
#import "SplitScreenView.h"
#import "SGTagsView.h"

@interface SplitScreenVC ()
@property (weak, nonatomic) IBOutlet SplitScreenView *splitScreenView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, strong) SGTagsView *tagsView;
@end

@implementation SplitScreenVC

- (void)dealloc {
    NSLog(@"SplitScreenVC - - dealloc");
}

- (SGTagsView *)tagsView {
    if (!_tagsView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = self.bottomView.frame.size.height;
        CGFloat y = 0;
        CGRect frame = CGRectMake(0, y, width, height);
        
        SGTagsViewConfigure *config = [SGTagsViewConfigure configure];
        config.tagsStyle = SGTagsStyleHorizontal;
        config.cornerRadius = 15;
        config.contentInset = UIEdgeInsetsMake(30, 20, 30, 20);
        config.selectedColor = [UIColor whiteColor];
        config.selectedBackgroundColor = [UIColor blackColor];
        _tagsView = [SGTagsView tagsViewWithFrame:frame configure:config];
        NSArray *tags = @[@"原图", @"二分屏", @"三分屏", @"四分屏", @"六分屏", @"九分屏", @"灵魂出窍", @"抖动", @"闪白", @"毛刺", @"灰度", @"颠倒", @"漩涡", @"马赛克", @"马赛克2", @"马赛克3", @"缩放"];
        _tagsView.tags = tags;
        _tagsView.tagIndexs = @[@0];
        __weak typeof(self) weakSelf = self;
        _tagsView.singleSelectBlock = ^(SGTagsView *tagsView, NSString *tag, NSInteger index) {
            if (index == 0) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"SplitScreenFS"];
            } else if (index == 1) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"SplitScreenFS2"];
            } else if (index == 2) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"SplitScreenFS3"];
            } else if (index == 3) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"SplitScreenFS4"];
            } else if (index == 4) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"SplitScreenFS6"];
            } else if (index == 5) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"SplitScreenFS9"];
            } else if (index == 6) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"SoulOutFS"];
            } else if (index == 7) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"ShakeFS"];
            } else if (index == 8) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"ShineWhiteFS"];
            } else if (index == 9) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"GlitchFS"];
            }  else if (index == 10) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"GrayscaleFS"];
            } else if (index == 11) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"InvertFS"];
            } else if (index == 12) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"VortexFS"];
            } else if (index == 13) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"MosaicFS1"];
            } else if (index == 14) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"MosaicFS2"];
            } else if (index == 15) {
                [weakSelf.splitScreenView splitScreenViewFragment:@"MosaicFS3"];
            } else if (index == 16) {
                [weakSelf.splitScreenView splitScreenViewScaleAnimator];
            }
        };
    }
    return _tagsView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"分屏";

    [self.bottomView addSubview:self.tagsView];
}


@end
