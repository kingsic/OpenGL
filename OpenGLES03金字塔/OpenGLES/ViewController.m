//
//  ViewController.m
//  OpenGLES
//
//  Created by kingsic on 2022/6/22.
//

#import "ViewController.h"

@interface ViewController () <GLKViewDelegate>
{
    dispatch_source_t timer;
}

@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, assign) int count;
// 旋转的度数
@property(nonatomic, assign) float XDegree;
@property(nonatomic, assign) float YDegree;
@property(nonatomic, assign) float ZDegree;
// 是否旋转X,Y,Z
@property(nonatomic, assign) BOOL XB;
@property(nonatomic, assign) BOOL YB;
@property(nonatomic, assign) BOOL ZB;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 配置OpenGLES环境
    [self configOpenGLES];
    
    // 渲染图形
    [self render];
}

- (void)configOpenGLES {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        NSLog(@"create EAGLContext failed");
        exit(0);
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    // 深度缓冲区格式
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    // 颜色缓冲区格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    // 模板缓冲区
    //view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    // 启用多重采样
    //view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    
    [EAGLContext setCurrentContext:self.context];
    
    // 开启深度测试，就是让离你近的物体可以遮挡离你远的物体
    glEnable(GL_DEPTH_TEST);
}

- (void)render {
    // 顶点数据
    // 前3个元素，是顶点数据；中间3个元素，是顶点颜色值，最后2个是纹理坐标
    GLfloat vertData[] = {
        -0.5f, 0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       0.0f, 0.5f, 0.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     0.5f, 0.0f, 1.0f,       0.0f, 0.0f,//左下
        0.5f, -0.5f, 0.0f,      0.0f, 0.0f, 0.5f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       1.0f, 1.0f, 1.0f,       0.5f, 0.5f,//顶点
    };
    
    // 绘图索引
    GLuint indices[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    // 索引数组的个数
    self.count = sizeof(indices) / sizeof(GLuint);
    
    // 将顶点数组的数组载入到缓冲区
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertData), vertData, GL_DYNAMIC_DRAW);
    
    // 将索引数据存储到索引数组缓冲区
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    
    // 顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, NULL);
    
    // 颜色数据
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, (GLfloat *)NULL + 3);
    
    // 纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 8, (GLfloat *)NULL + 6);
    
    // 获取纹理路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpeg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"1", GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = textureInfo.name;
    
    // 获得投影矩阵(投影方式)
    CGSize size = self.view.bounds.size;
    float aspect = size.width / size.height;
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1, 10);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0, 1.0, 1.0);
    
    // 将投影矩阵传入 effect
    self.baseEffect.transform.projectionMatrix = projectionMatrix;
    
    // 模型视图
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2.0);
    
    // 将模型视图矩阵传入 effect
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    // 定时器
    double seconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        self.XDegree += 0.1f * self.XB;
        self.YDegree += 0.1f * self.YB;
        self.ZDegree += 0.1f * self.ZB;
    });
    dispatch_resume(timer);
}

// 场景数据变化
- (void)update {
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.XDegree);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.YDegree);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.ZDegree);
    
    // effect 重新渲染
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.0, 0.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 启动着色器
    [self.baseEffect prepareToDraw];
    
    // 索引绘图
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}


- (IBAction)xAction:(id)sender {
    _XB = !_XB;
}
- (IBAction)yAction:(id)sender {
    _YB = !_YB;
}
- (IBAction)zAction:(id)sender {
    _ZB = !_ZB;
}

@end
