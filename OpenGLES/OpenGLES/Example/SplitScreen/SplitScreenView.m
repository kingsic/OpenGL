//
//  SplitScreenView.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/3.
//

#import "SplitScreenView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLProgram.h"
#import "GLTexture.h"
#import "SGWeakProxy.h"

@interface SplitScreenView ()
{
    CADisplayLink *link;
    // 开始的时间戳
    NSTimeInterval startTimeInterval;
}
@property (nonatomic, strong) CAEAGLLayer *eagLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint textureID;
@property (nonatomic, assign) GLuint vertexID;

@end

@implementation SplitScreenView

- (void)dealloc {
    NSLog(@"SplitScreenView - - dealloc");
}

- (void)layoutSubviews {
    // 设置图层
    [self setupLayer];
    
    // 设置上下文
    [self setupContext];

    // 清空缓存区
    [self deleteBuffer];

    // 注：绑定renderBuffer和FrameBuffer是有顺序的，先有RenderBuffer，才有FrameBuffer

    // 设置RenderBuffer
    [self setupRenderBuffer];

    // 设置FrameBuffer
    [self setupFrameBuffer];
    
    // 渲染
    [self render];
    
    link = [CADisplayLink displayLinkWithTarget:[SGWeakProxy weakProxyWithTarget:self] selector:@selector(timeAction)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    self.eagLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.eagLayer.opaque = YES;
    self.eagLayer.drawableProperties = [
        NSDictionary dictionaryWithObjectsAndKeys:
            @(0), kEAGLDrawablePropertyRetainedBacking,
            kEAGLColorFormatSRGBA8, kEAGLDrawablePropertyColorFormat,
        nil];
}

- (void)setupContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context || ![EAGLContext setCurrentContext:context]) {
        NSLog(@"set up context failed");
    }
    self.context = context;
}

- (void)deleteBuffer {
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    self.colorRenderBuffer = 0;
    glDeleteFramebuffers(1, &_colorFrameBuffer);
    self.colorFrameBuffer = 0;
}

- (void)setupRenderBuffer {
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
    self.colorRenderBuffer = buffer;
}

- (void)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
    self.colorFrameBuffer = buffer;
}

- (void)render {
    glClearColor(0.5, 1.0, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    GLint x = self.frame.origin.x * scale;
    GLint y = self.frame.origin.y * scale;
    GLint w = self.frame.size.width * scale;
    GLint h = self.frame.size.height * scale;
    // 设置视口大小
    glViewport(x, y, w, h);
    
    // 顶点/纹理数据
    GLfloat vertData[] = {
        0.7f, -0.5f, 0.0f,        1.0f, 1.0f, // 右下
        -0.7f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
        -0.7f, -0.5f, 0.0f,       0.0f, 1.0f, // 左下
        0.7f, 0.5f, 0.0f,         1.0f, 0.0f, // 右上
        -0.7f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
        0.7f, -0.5f, 0.0f,        1.0f, 1.0f, // 右下
    };

    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertData), vertData, GL_DYNAMIC_DRAW);
    self.vertexID = buffer;
    
    [self splitScreenViewFragment:@"SplitScreenFS"];
}

- (void)splitScreenViewFragment:(NSString *)fragmentFilepath {
    [link setPaused:NO];
    
    NSString *vertFilepath = [[NSBundle mainBundle] pathForResource:@"SplitScreenVS" ofType:@"glsl"];
    NSString *fragFilepath = [[NSBundle mainBundle] pathForResource:fragmentFilepath ofType:@"glsl"];
    
    self.program = [GLProgram programWithVertexShader:vertFilepath fragmentShader:fragFilepath];
    
    glUseProgram(self.program);

    
    // 在iOS中，attribute通道默认是关闭的，需要手动开启，
    // 而数据有顶点坐标和纹理坐标两种，需要分别开启两次
    
    GLuint position = glGetAttribLocation(self.program, "a_position");
    glEnableVertexAttribArray(position);
    // 参数1：index, 顶点数据的索引
    // 参数2：size, 每个顶点属性的组件数量，1，2，3，或者4. 默认初始值是4.
    // 参数3：type, 数据中的每个组件的类型，常用的有GL_FLOAT, GL_BYTE, GL_SHORT。默认初始值为 GL_FLOAT
    // 参数4：normalized, 固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    // 参数5：stride, 连续顶点属性之间的偏移量，默认为0；
    // 参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL);
    
    // 处理纹理数据
    GLuint textColor = glGetAttribLocation(self.program, "a_texture");
    glEnableVertexAttribArray(textColor);
    glVertexAttribPointer(textColor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    
    // 加载纹理
    self.textureID = [GLTexture textureWithName:@"image"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    // 设置纹理采样器 sampler2D
    GLuint colorMap = glGetUniformLocation(self.program, "u_colorMap");
    glUniform1i(colorMap, 0);
        
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 6);
    // 将绘制好的图片渲染到屏幕上进行显示
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    startTimeInterval = 0;
}


- (void)splitScreenViewScaleAnimator {
    [link setPaused:NO];
    
    NSString *vertFilepath = [[NSBundle mainBundle] pathForResource:@"ScaleVS" ofType:@"glsl"];
    NSString *fragFilepath = [[NSBundle mainBundle] pathForResource:@"ScaleFS" ofType:@"glsl"];
    self.program = [GLProgram programWithVertexShader:vertFilepath fragmentShader:fragFilepath];
    
    GLuint position = glGetAttribLocation(self.program, "a_position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL);

    GLuint textColor = glGetAttribLocation(self.program, "texCoord");
    glEnableVertexAttribArray(textColor);
    glVertexAttribPointer(textColor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);

    GLuint colorMap = glGetUniformLocation(self.program, "colorMap");
    glUniform1i(colorMap, 0);
    
    GLuint size = glGetUniformLocation(self.program, "size");
    glUniform2i(size, [self drawableWidth], [self drawableHeight]);
    
    startTimeInterval = 0;
}

- (GLint)drawableWidth {
    GLint width;
    //获取渲染缓存区大小
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}

- (GLint)drawableHeight {
    GLint height;
    //获取渲染缓存区大小
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return height;
}

- (void)timeAction {
    glClearColor(0.5, 1.0, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (startTimeInterval == 0) {
        startTimeInterval = link.timestamp;
    }
    
    glUseProgram(self.program);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexID);
    // 激活纹理,绑定纹理ID
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    GLuint colorMap = glGetUniformLocation(self.program, "Time");
    glUniform1f(colorMap, link.timestamp - startTimeInterval);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
