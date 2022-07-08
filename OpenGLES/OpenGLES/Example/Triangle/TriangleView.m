//
//  TriangleView.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/2.
//

#import "TriangleView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLProgram.h"

@interface TriangleView ()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CAEAGLLayer *eagLayer;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;
@property (nonatomic, assign) GLuint program;
@end

@implementation TriangleView

- (void)dealloc {
    NSLog(@"TriangleView - - dealloc");
}

- (void)layoutSubviews {
    // 设置图层
    [self setupLayer];
    
    // 设置上下文
    [self setupContext];

    // 清空缓存区
    [self deleteBuffer];

    // 设置RenderBuffer
    [self setupRenderBuffer];

    // 设置FrameBuffer
    [self setupFrameBuffer];

    // 渲染
    [self render];
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
    glDeleteBuffers(1, &_colorRenderBuffer);
    self.colorRenderBuffer = 0;
    glDeleteBuffers(1, &_colorFrameBuffer);
    self.colorFrameBuffer = 0;
}

- (void)setupRenderBuffer {
    GLuint buffer;
    // 创建绘制缓冲区
    glGenRenderbuffers(1, &buffer);
    // 绑定绘制缓冲区到渲染管线
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    // 为绘制缓冲区分配存储区：将CAEAGLLayer的绘制存储区作为绘制缓冲区的存储区
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
    self.colorRenderBuffer = buffer;
}

- (void)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    // 绑定帧缓冲区到渲染管线
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    // 将绘制缓冲区邦定到帧缓冲区
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
    self.colorFrameBuffer = buffer;
}

- (void)render {
    glClearColor(0.5f, 1.0f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    GLint x = self.frame.origin.x * scale;
    GLint y = self.frame.origin.y * scale;
    GLint w = self.frame.size.width * scale;
    GLint h = self.frame.size.height * scale;
    glViewport(x, y, w, h);
    
    NSString *vertFilepath = [[NSBundle mainBundle] pathForResource:@"TriangleVS" ofType:@"glsl"];
    NSString *fragFilepath = [[NSBundle mainBundle] pathForResource:@"TriangleFS" ofType:@"glsl"];

    self.program = [GLProgram programWithVertexShader:vertFilepath fragmentShader:fragFilepath];
    
    glUseProgram(self.program);
    
    GLfloat vertData[] = {
        0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    // 将顶点坐标写入顶点VBO（把顶点数据从CPU内存复制到GPU上）
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertData), vertData, GL_STATIC_DRAW);
    
    // 获取参数索引
    GLuint position = glGetAttribLocation(self.program, "position");
    // 设置合适的格式从buffer里面读取数据
    glEnableVertexAttribArray(position);
    // 告诉OpenGL该如何解析顶点数据
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
    
    
    // 绘制三个顶点的三角形
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // EACAGLContext 渲染OpenGL绘制好的图像到 EACAGLLayer
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
