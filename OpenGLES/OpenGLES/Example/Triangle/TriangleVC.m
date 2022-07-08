//
//  TriangleVC.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/2.
//

#import "TriangleVC.h"
#import "TriangleView.h"

@implementation TriangleVC

- (void)dealloc {
    NSLog(@"TriangleVC - - dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"绘制三角形";
    
    self.view = [[TriangleView alloc] init];
}


@end
