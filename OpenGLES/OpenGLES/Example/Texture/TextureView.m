//
//  TextureView.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/3.
//

#import "TextureView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLProgram.h"

@interface TextureView ()
@property (nonatomic, strong) CAEAGLLayer *eagLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;
@property (nonatomic, assign) GLuint program;

@end

@implementation TextureView

- (void)dealloc {
    NSLog(@"TextureView - - dealloc");
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
}

// 由于UIView中自带的layer是继承自CALayer的
// 而需要创建的layer是继承自CAEAGLLayer的
// 所以需要重写类方法layerClass，返回[CAEAGLLayer class]
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    self.eagLayer = (CAEAGLLayer *)self.layer;
    // 设置scale，将layer的大小设置为跟屏幕大小一致
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.eagLayer.opaque = YES;
    // kEAGLDrawablePropertyRetainedBacking 只有true 或者 false两种
    // kEAGLDrawablePropertyRetainedBacking 绘图表面显示后，是否保留其内容，默认为 false
    // kEAGLColorFormatSRGBA8 32位的RGBA颜色值（每位表示8位，所以4*8=32位）
    // kEAGLDrawablePropertyColorFormat 可绘制表面的内部颜色缓存区格式
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

// 清理缓冲区的目的在于清除残留数据，防止残留数据对本次操作造成影响
- (void)deleteBuffer {
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    self.colorRenderBuffer = 0;
    glDeleteFramebuffers(1, &_colorFrameBuffer);
    self.colorFrameBuffer = 0;
}

// RenderBuffer：是一个通过应用分配的2D图像缓冲区，需要附着在FrameBuffer上
- (void)setupRenderBuffer {
    // RenderBuffer有3种缓存区
    // 深度缓存区（Depth Buffer）：存储深度值等
    // 纹理缓存区：存储纹理坐标中对应的纹素、颜色值等
    // 模板缓存区（Stencil Buffer）：存储模板
    
    // 定义一个缓存区ID
    GLuint buffer;
    
    // 申请一个缓存区标识符
    glGenRenderbuffers(1, &buffer);
    
    // 将标识符绑定到GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    
    // 将可绘制对象drawable object的CAEAGLLayer的存储绑定到OpenGL ES renderBuffer对象
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
    
    self.colorRenderBuffer = buffer;
}

// 是一个收集颜色、深度和模板缓存区的附着点，简称FBO，即是一个管理者，
// 用来管理RenderBuffer，且FrameBuffer没有实际的存储功能，真正实现存储的是RenderBuffer
- (void)setupFrameBuffer {
    // FrameBuffer有3个附着点
    // 颜色附着点（Color Attachment）：管理纹理、颜色缓冲区
    // 深度附着点（depth Attachment）：会影响颜色缓冲区，管理深度缓冲区（Depth Buffer）
    // 模板附着点（Stencil Attachment）：管理模板缓冲区（Stencil Buffer）
    
    // 定义一个缓存区ID
    GLuint buffer;
    
    // 申请一个缓存区标识符
    glGenFramebuffers(1, &buffer);
    
    // 将标识符绑定到GL_FRAMEBUFFER
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    
    // 将渲染缓存区的 colorRenderBuffer 通过 glFramebufferRenderbuffer 函数绑定到 GL_COLOR_ATTACHMENT0 上
    // 参数1：绑定到的目标
    // 参数2：FrameBuffer的附着点
    // 参数3：需要绑定的渲染缓冲区目标
    // 参数4：渲染缓冲区
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
    
    self.colorFrameBuffer = buffer;
}

- (void)render {
    // 设置清屏颜色 & 清除屏幕
    glClearColor(0.5f, 1.0f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    GLint x = self.frame.origin.x * scale;
    GLint y = self.frame.origin.y * scale;
    GLint w = self.frame.size.width * scale;
    GLint h = self.frame.size.height * scale;
    // 设置视口大小
    glViewport(x, y, w, h);
    
    NSString *vertFilepath = [[NSBundle mainBundle] pathForResource:@"TextureVS" ofType:@"glsl"];
    NSString *fragFilepath = [[NSBundle mainBundle] pathForResource:@"TextureFS" ofType:@"glsl"];
    
    self.program = [GLProgram programWithVertexShader:vertFilepath fragmentShader:fragFilepath];
    
    glUseProgram(self.program);
    
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
    
    // 在iOS中，attribute通道默认是关闭的，需要手动开启，
    // 而数据有顶点坐标和纹理坐标两种，需要分别开启两次
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    // 参数1：index, 顶点数据的索引
    // 参数2：size, 每个顶点属性的组件数量，1，2，3，或者4. 默认初始值是4.
    // 参数3：type, 数据中的每个组件的类型，常用的有GL_FLOAT, GL_BYTE, GL_SHORT。默认初始值为 GL_FLOAT
    // 参数4：normalized, 固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    // 参数5：stride, 连续顶点属性之间的偏移量，默认为0；
    // 参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL);
    
    // 处理纹理数据
    GLuint textColor = glGetAttribLocation(self.program, "textCoordinate");
    glEnableVertexAttribArray(textColor);
    glVertexAttribPointer(textColor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    
    // 加载纹理
    [self setupTexture:@"image"];
    
    // 设置纹理采样器 sampler2D
    GLuint colorMap = glGetUniformLocation(self.program, "colorMap");
    glUniform1i(colorMap, 0);
    
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 6);
    // 将绘制好的图片渲染到屏幕上进行显示
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

// 从图片中加载纹理
- (GLuint)setupTexture:(NSString *)fileName {
    // 1、将UIImage转换为CGImageRef & 判断图片是否获取成功
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    if (!spriteImage) {
        NSLog(@"Failed to lead image %@", fileName);
        exit(1);
    }
    
    // 2、读取图片的大小、宽和高
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    // 3、获取图片字节数 宽*高*4（RGBA）
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));
    
    // 4、创建上下文
    /*
    参数1：data, 指向要渲染的绘制图像的内存地址
    参数2：width, bitmap的宽度，单位为像素
    参数3：height, bitmap的高度，单位为像素
    参数4：bitPerComponent, 内存中像素的每个组件的位数，比如32位RGBA，就设置为8
    参数5：bytesPerRow, bitmap的没一行的内存所占的比特数
    参数6：colorSpace, bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
    */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 5、在CGContextRef上 --- 将图片绘制出来
    /*
    CGContextDrawImage 使用的是Core Graphics框架，坐标系与UIKit 不一样。UIKit框架的原点在屏幕的左上角，Core Graphics框架的原点在屏幕的左下角。
    CGContextDrawImage
    参数1：绘图上下文
    参数2：rect坐标
    参数3：绘制的图片
    */
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 6、使用默认方式绘制
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    // 7、画图完毕就释放上下文
    CGContextRelease(spriteContext);
    
    // 8、绑定纹理到默认的纹理ID
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 9、设置纹理属性
    /* 参数1：纹理维度
     参数2：线性过滤、为s,t坐标设置模式
     参数3：wrapMode,环绕模式
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    
    float fw = width, fh = height;
    // 10、载入纹理2D数据
    /*
     参数1：纹理模式(绑定纹理对象的种类)，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
     参数2：加载的层次，一般设置为0, 0表示没有进行缩小的原始图片等级。
     参数3：纹理的颜色值GL_RGBA, 表示了纹理所采用的内部格式，内部格式是我们的像素数据在显卡中存储的格式，这里的GL_RGB显然就表示纹理中像素的颜色值是以RGB的格式存储的。
     参数4：纹理的宽
     参数5：纹理的高
     参数6：border，边界宽度，通常为0.
     参数7：format（描述了像素在内存中的存储格式）
     参数8：type（描述了像素在内存中的数据类型）
     参数9：纹理数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // 11、释放spriteData
    free(spriteData);
    return 0;
}

@end
