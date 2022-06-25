//
//  ViewController.m
//  OpenGLES
//
//  Created by kingsic on 2022/6/22.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface ViewController () <GLKViewDelegate>
{
    // EAGLContent是苹果在ios平台下实现的opengles渲染层
    // 用于渲染结果在目标surface上的更新
    EAGLContext *context;
    // 效果，光照与阴影纹理，基于着色器 OpenGL 渲染，可以理解为固定管线，提供3个光照+2个纹理
    GLKBaseEffect *baseEffect;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 配置OpenGLES环境
    [self configOpenGLES];
    
    // 加载顶点数据
    [self loadVertexData];
    
    // 加载纹理数据
    [self loadTextureData];
}

- (void)configOpenGLES {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"create EAGLContext failed");
        exit(0);
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    
    // 深度缓冲区格式
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    // 颜色缓冲区格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    // 模板缓冲区
    //view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    // 启用多重采样
    //view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    
    [EAGLContext setCurrentContext:context];
    
    // 开启深度测试，就是让离你近的物体可以遮挡离你远的物体
    glEnable(GL_DEPTH_TEST);
}

- (void)loadVertexData {
    
    // 顶点数据
    // 前3个是顶点坐标x,y,z；后面2个是纹理坐标
    // OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间
    // 纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角
    
    GLfloat vertData[] = {
        0.7, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.7, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.7, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        0.7, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.7, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.7, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    GLuint buffer;
    // 申请一个缓存区标识符
    glGenBuffers(1, &buffer);
    // glBindBuffer把标识符绑定到GL_ARRAY_BUFFER上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    // glBufferData把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertData), vertData, GL_STATIC_DRAW);
    
    // 允许顶点着色器读取GPU（服务器端）数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // glVertexAttribPointer 使用来上传顶点数据到GPU的方法
    // type: 指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT, GL_UNSIGNED_SHORT, GL_FIXED 和 GL_FLOAT，初始值为GL_FLOAT
    // (GLfloat *)NULL + 0 指针，指向数组首地址
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    // (GLfloat *)NULL + 3，指向到纹理数据
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

- (void)loadTextureData {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpeg"];
        
    // GLKTextureLoaderOriginBottomLeft, 纹理坐标是相反的
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:file options:options error:NULL];
    
    // 着色器
    baseEffect = [[GLKBaseEffect alloc] init];
    // 第一个纹理属性
    baseEffect.texture2d0.enabled = GL_TRUE;
    // 纹理的名字
    baseEffect.texture2d0.name = textureInfo.name;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 启动着色器
    [baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
