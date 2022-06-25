//
//  ESView.m
//  OpenGLES
//
//  Created by kingsic on 2022/6/22.
//

#import "ESView.h"
#import <OpenGLES/ES3/gl.h>

@interface ESView()
{
    GLuint vertShader, fragShader;
}
@property (nonatomic, strong) CAEAGLLayer *eagLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;
@property (nonatomic, assign) GLuint program;

@end

@implementation ESView

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
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    // CALayer 默认是透明的，必须将它设为不透明才能将其可见
    self.eagLayer.opaque = YES;
    
    // 设置描述属性
    self.eagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys: @(0), kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatSRGBA8,  kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"create context failed");
        exit(0);
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"set current context failed");
        exit(0);
    }
    
    self.context = context;
}

- (void)deleteBuffer {
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    glDeleteFramebuffers(1, &_colorFrameBuffer);
    self.colorRenderBuffer = 0;
    self.colorFrameBuffer = 0;
}

- (void)setupRenderBuffer {
    // 定义缓存区标记
    GLuint buffer;
    
    // 根据标记分配空间
    glGenRenderbuffers(1, &buffer);
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    
    // 渲染缓存区分配存储空间
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
    
    self.colorRenderBuffer = buffer;
}

- (void)setupFrameBuffer {
    // 定义缓存区标记
    GLuint buffer;
    
    // 根据标记分配空间
    glGenFramebuffers(1, &buffer);
    
    // 绑定对应空间
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    
    // 生成空间之后，则需要将 renderbuffer 跟 framebuffer 进行绑定
    // 调用 glFramebufferRenderbuffer 函数进行绑定，后面的绘制才能起作用
    // 将 renderBuffer 通过 glFramebufferRenderbuffer 函数绑定到 GL_COLOR_ATTACHMENT0 上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
    
    self.colorFrameBuffer = buffer;
}

- (void)render {
    // 设置清屏颜色
    glClearColor(0, 1, 0, 1);
    // 清除屏幕
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 设置视口大小
    CGFloat scale = [[UIScreen mainScreen] scale];
    GLint x = self.frame.origin.x * scale;
    GLint y = self.frame.origin.y * scale;
    GLint w = self.frame.size.width * scale;
    GLint h = self.frame.size.height * scale;
    glViewport(x, y, w, h);
    
    // 1、读取顶点着色程序、片元着色程序
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vshader" ofType:@"glsl"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"fshader" ofType:@"glsl"];
    
    NSLog(@"vertFile: %@", vertFile);
    NSLog(@"fragFile: %@", fragFile);
    
    self.program = [self loadShader:vertFile frag:fragFile];
    
    // 链接program
    glLinkProgram(self.program);
    
    GLint linkSuccess;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"Program Link %@", messageString);
        return ;
    }
    
    // 使用program
    glUseProgram(self.program);
    
    // 设置顶点、纹理坐标
    GLfloat vertData[] = {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    
    /*
     // 解决渲染图片倒置问题：
     GLfloat vertData[] =
     {
     0.7f, -0.5f, 0.0f,        1.0f, 1.0f, //右下
     -0.7f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
     -0.7f, -0.5f, 0.0f,       0.0f, 1.0f, // 左下
     0.7f, 0.5f, 0.0f,         1.0f, 0.0f, // 右上
     -0.7f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
     0.7f, -0.5f, 0.0f,        1.0f, 1.0f, // 右下
     };
     */
    
    GLuint buffer;
    // 申请一个缓存区标识符
    glGenBuffers(1, &buffer);
    // 将buffer绑定到GL_ARRAY_BUFFER标识符上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    // 把顶点数据从CPU内存复制到GPU上
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertData), vertData, GL_DYNAMIC_DRAW);
    
    // 将顶点数据通过programe中的传递到顶点着色程序的position
    // 1.glGetAttribLocation, 用来获取vertex attribute的入口的.
    // 2.告诉OpenGL ES, 通过glEnableVertexAttribArray
    // 3.最后数据是通过glVertexAttribPointer传递过去的。
    // 注意：第二参数字符串必须和vshader.slgl中的输入变量：position保持一致
    GLuint position = glGetAttribLocation(self.program, "position");
    // 设置合适的格式从buffer里面读取数据
    glEnableVertexAttribArray(position);
    
    // 设置读取方式
    //参数1：index, 顶点数据的索引
    //参数2：size, 每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
    //参数3：type, 数据中的每个组件的类型，常用的有GL_FLOAT, GL_BYTE, GL_SHORT。默认初始值为GL_FLOAT
    //参数4：normalized, 固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    //参数5：stride, 连续顶点属性之间的偏移量，默认为0；
    //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, NULL);
    
    GLuint textureCoordinate = glGetAttribLocation(self.program, "textureCoordinate");
    glEnableVertexAttribArray(textureCoordinate);
    glVertexAttribPointer(textureCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (GLfloat *)NULL + 3);
    
    [self loadTexture:@"image"];
    
    // 注意，想要获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    /*
     一个一致变量在一个图元的绘制过程中是不会改变的，所以其值不能在glBegin/glEnd中设置。一致变量适合描述在一个图元中、一帧中甚至一个场景中都不变的值。一致变量在顶点shader和片断shader中都是只读的。首先你需要获得变量在内存中的位置，这个信息只有在连接程序之后才可获得
     */
    GLuint rotate = glGetUniformLocation(self.program, "rotateMatrix");
    
    // 获取渲染的弧度
    //    float radians = 180 * 3.14159f / 180.0f;
    float radians = 10 * 3.14159f / 180.0f;
    // 求得弧度对于的sin\cos值
    float s = sin(radians);
    float c = cos(radians);
    
    // 在OpenGL ES用的是列向量
    GLfloat zRotation[16] = {
        c, -s, 0, 0,
        s, c, 0, 0,
        0, 0, 1.0, 0,
        0.0, 0, 0, 1.0
    };
    
    // 设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

// 加载shader
- (GLuint)loadShader:(NSString *)vert frag:(NSString *)frag {
    GLuint program = glCreateProgram();
    
    // 编译顶点/片元着色器
    [self complieShader:&vertShader
                   type:GL_VERTEX_SHADER file:vert];
    [self complieShader:&fragShader
                   type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    // 释放不需要的shader
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    return  program;
}
// 编译shader
- (void)complieShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    // 获取文件路径字符串，C语言字符串
    const GLchar *source = (GLchar *)[content UTF8String];

    // 创建shader
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    
    // 把着色器源代码编译成目标代码
    glCompileShader(*shader);
    
    int status = 0;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_TRUE) {
        NSLog(@"%d: shader compile success", type);
    } else {
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(*shader, logLength, &logLength, log);
            if (shader == &vertShader) {
                NSLog(@" vertex Shader log is : %@", [NSString stringWithFormat:@"%s", log]);
            } else {
                NSLog(@" fragment Shader log is : %@", [NSString stringWithFormat:@"%s", log]);
            }
            free(log);
        }
    }
}

//设置纹理
- (GLuint)loadTexture:(NSString *)fileName {
    //1、获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    //判断图片是否获取成功
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    //2、读取图片的大小，宽和高
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    //3.获取图片字节数 宽*高*4（RGBA）
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    //4.创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    
    
    //5、在CGContextRef上绘图
    /*
     CGContextDrawImage 使用的是Core Graphics框架，坐标系与UIKit 不一样。UIKit框架的原点在屏幕的左上角，Core Graphics框架的原点在屏幕的左下角。
     CGContextDrawImage
     参数1：绘图上下文
     参数2：rect坐标
     参数3：绘制的图片
     */
    CGRect rect = CGRectMake(0, 0, width, height);
    //使用默认方式绘制，发现图片是倒的。
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    /*
     解决图片倒置的方法(2):
     CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
     CGContextTranslateCTM(spriteContext, 0, rect.size.height);
     CGContextScaleCTM(spriteContext, 1.0, -1.0);
     CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
     CGContextDrawImage(spriteContext, rect, spriteImage);
     */
   
    //6、画图完毕就释放上下文
    CGContextRelease(spriteContext);
    
    //5、绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //设置纹理属性
    /*
     参数1：纹理维度
     参数2：线性过滤、为s,t坐标设置模式
     参数3：wrapMode,环绕模式
     */
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    //载入纹理2D数据
    /*
     参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
     参数2：加载的层次，一般设置为0
     参数3：纹理的颜色值GL_RGBA
     参数4：宽
     参数5：高
     参数6：border，边界宽度
     参数7：format
     参数8：type
     参数9：纹理数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    //绑定纹理
    /*
     参数1：纹理维度
     参数2：纹理ID,因为只有一个纹理，给0就可以了。
     */
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //释放spriteData
    free(spriteData);
    
    return 0;
}


@end
