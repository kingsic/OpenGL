//
//  TextureVC.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/3.
//

#import "TextureVC.h"
#import "TextureView.h"

@interface TextureVC ()

@end

@implementation TextureVC

- (void)dealloc {
    NSLog(@"TextureVC - - dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"渲染图片";

    self.view = [[TextureView alloc] init];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
