//
//  ViewController.m
//  OpenGLES
//
//  Created by kingsic on 2022/6/22.
//

#import "ViewController.h"
#import "ESView.h"

@interface ViewController()
@property (nonatomic, strong) ESView *esView;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.esView = (ESView *)self.view;
}

@end
