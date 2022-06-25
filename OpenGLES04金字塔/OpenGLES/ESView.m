//
//  ESView.m
//  OpenGLES
//
//  Created by kingsic on 2022/6/22.
//

#import "ESView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLESMath.h"

@interface ESView()
@property (nonatomic, strong) CAEAGLLayer *eagLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint vertices;

@end

@implementation ESView
{
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL bX;
    BOOL bY;
    BOOL bZ;
    NSTimer *timer;
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
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.eagLayer.opaque = YES;
    self.eagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatSRGBA8, kEAGLDrawablePropertyColorFormat, nil];
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
    self.colorRenderBuffer = 0;
    glDeleteFramebuffers(1, &_colorFrameBuffer);
    self.colorFrameBuffer = 0;
}

- (void)setupRenderBuffer {
    // 定义一个缓存区
    GLuint buffer;
    // 申请一个缓存区标志
    glGenRenderbuffers(1, &buffer);
    // 将标识符绑定到GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, buffer);
    // frame buffer仅仅是管理者，不需要分配空间；
    // render buffer的存储空间的分配，对于不同的render buffer，使用不同的API进行分配，而只有分配空间的时候，render buffer句柄才确定其类型
    // 为color renderBuffer 分配空间
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
    self.colorRenderBuffer = buffer;
}

- (void)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    glBindFramebuffer(GL_FRAMEBUFFER, buffer);
    // 附着（将renderBuffer附着到framebuffer）
    // 将_colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 附着点上
    // 附着点 GL_COLOR_ATTACHMENT0
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
    self.colorFrameBuffer = buffer;
}

- (void)render {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    GLfloat scale = [[UIScreen mainScreen] scale];
    CGFloat x = self.frame.origin.x * scale;
    CGFloat y = self.frame.origin.y * scale;
    CGFloat w = self.frame.size.width * scale;
    CGFloat h = self.frame.size.height * scale;
    glViewport(x, y, w, h);
    
    // 获取顶点/片元着色器文件
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vshader" ofType:@"glsl"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"fshader" ofType:@"glsl"];

    // 判断self.myProgram是否存在，存在则清空其文件
    if (self.program) {
        
        glDeleteProgram(self.program);
        self.program = 0;
    }
    
    // 加载程序到myProgram中来。
    self.program = [self loadShader:vertFile frag:fragFile];
    
    // 链接
    glLinkProgram(self.program);
    GLint linkSuccess;
    
    // 获取链接状态
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        
        return ;
    } else {
        glUseProgram(self.program);
    }
    
    
    // 创建索引数组
    GLuint indices[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    // 判断顶点缓存区是否为空，如果为空则申请一个缓存区标识符
    if (self.vertices == 0) {
        glGenBuffers(1, &_vertices);
    }
    
    GLfloat vertDate[] = {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, //左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, //右上
        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, //左下
        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下
        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f, //顶点
    };
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertDate), vertDate, GL_DYNAMIC_DRAW);
    
    // 顶点数据
    GLuint position = glGetAttribLocation(self.program, "a_position");
    glEnableVertexAttribArray(position);
    // 设置读取方式
    // 参数1：index, 顶点数据的索引
    // 参数2：size, 每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
    // 参数3：type, 数据中的每个组件的类型，常用的有GL_FLOAT, GL_BYTE, GL_SHORT。默认初始值为GL_FLOAT
    // 参数4：normalized, 固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    // 参数5：stride, 连续顶点属性之间的偏移量，默认为0；
    // 参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 6, NULL);
    
    // 颜色数据
    GLuint positionColor = glGetAttribLocation(self.program, "a_positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 6, (CGFloat *)NULL + 3);
    
    // 投影矩阵
    GLuint projectionMatrixSlot = glGetUniformLocation(self.program, "u_projectionMatrix");
    
    // 纵横比：立体图形 -> 透视投影
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float aspect = width / height;
    
    // 创建4x4的矩阵
    KSMatrix4 _projectionMatrix;
    // 加载单元矩阵
    ksMatrixLoadIdentity(&_projectionMatrix);
    
    // 设置透视投影
    /*
     参数1：矩阵
     参数2：视角，度数为单位
     参数3：纵横比
     参数4：近平面距离
     参数5：远平面距离
     */
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0, 20.0);
    
    // 将矩阵传递顶点着色器
    // 设置glsl里面的投影矩阵
    /*
     void glUniformMatrix4fv(GLint location,  GLsizei count,  GLboolean transpose,  const GLfloat *value);
     参数列表：
     location:指要更改的uniform变量的位置
     count:更改矩阵的个数
     transpose:是否要转置矩阵，并将它作为uniform变量的值。必须为GL_FALSE
     value:执行count个元素的指针，用来更新指定uniform变量
     */
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    
    // 开启正背面剔除
    glEnable(GL_CULL_FACE);
    
    
    // 模型视图矩阵
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.program, "u_modelViewMatrix");
    // 创建一个4 * 4 矩阵，模型视图
    KSMatrix4 _modelViewMatrix;
    // 获取单元矩阵
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    // 平移，z轴平移-10
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);
    
    // 创建一个4 * 4 矩阵，旋转矩阵
    KSMatrix4 _rotationMatrix;
    // 初始化为单元矩阵
    ksMatrixLoadIdentity(&_rotationMatrix);
    
    // 旋转
    ksRotate(&_rotationMatrix, xDegree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0); //绕Y轴
    ksRotate(&_rotationMatrix, zDegree, 0.0, 0.0, 1.0); //绕Z轴
    
    // 把变换矩阵相乘，注意先后顺序，将平移矩阵与旋转矩阵相乘，结合到模型视图
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    // 加载模型视图矩阵 modelViewMatrixSlot
    // 设置glsl里面的投影矩阵
    /*
     void glUniformMatrix4fv(GLint location,  GLsizei count,  GLboolean transpose,  const GLfloat *value);
     参数列表：
     location:指要更改的uniform变量的位置
     count:更改矩阵的个数
     transpose:是否要转置矩阵，并将它作为uniform变量的值。必须为GL_FALSE
     value:执行count个元素的指针，用来更新指定uniform变量
     */
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    
    // 使用索引绘图
    /*
     void glDrawElements(GLenum mode,GLsizei count,GLenum type,const GLvoid * indices);
     参数列表：
     mode: 要呈现的画图的模型
                GL_POINTS
                GL_LINES
                GL_LINE_LOOP
                GL_LINE_STRIP
                GL_TRIANGLES
                GL_TRIANGLE_STRIP
                GL_TRIANGLE_FAN
     count: 绘图个数
     type: 类型
             GL_BYTE
             GL_UNSIGNED_BYTE
             GL_SHORT
             GL_UNSIGNED_SHORT
             GL_INT
             GL_UNSIGNED_INT
     indices：绘制索引数组
     */
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);

    // 要求本地窗口系统显示OpenGL ES渲染<目标>
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark -- Shader
- (GLuint)loadShader:(NSString *)vert frag:(NSString *)frag {
    // 创建2个临时的变量，vertShader,fragShader
    GLuint vertShader,fragShader;
    // 创建一个Program
    GLuint program = glCreateProgram();

    //编译文件
    //编译顶点着色程序、片元着色器程序
    //参数1：编译完存储的底层地址
    //参数2：编译的类型，GL_VERTEX_SHADER（顶点）、GL_FRAGMENT_SHADER(片元)
    //参数3：文件路径
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];

    // 创建最终的程序
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);

    // 释放不需要的shader
    glDeleteProgram(vertShader);
    glDeleteProgram(fragShader);

    return program;
}

// 链接shader
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    // 读取文件路径字符串
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    // 获取文件路径字符串，C语言字符串
    const GLchar *source = (GLchar *)[content UTF8String];

    // 创建一个shader（根据type类型）
    *shader = glCreateShader(type);

    //将顶点着色器源码附加到着色器对象上。
    //参数1：shader,要编译的着色器对象 *shader
    //参数2：numOfStrings,传递的源码字符串数量 1个
    //参数3：strings,着色器程序的源码（真正的着色器程序源码）
    //参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
    glShaderSource(*shader, 1, &source, NULL);

    // 把着色器源代码编译成目标代码
    glCompileShader(*shader);

}


- (IBAction)xAction:(id)sender {
    // 开启定时器
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    // 更新的是X还是Y
    bX = !bX;
}

- (IBAction)yAction:(id)sender {
    // 开启定时器
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    // 更新的是X还是Y
    bY = !bY;
}

- (IBAction)zAction:(id)sender {
    // 开启定时器
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    // 更新的是X还是Y
    bZ = !bZ;
}

- (void)reDegree {
    // 如果停止X轴旋转，X = 0则度数就停留在暂停前的度数.
    // 更新度数
    xDegree += bX * 5;
    yDegree += bY * 5;
    zDegree += bZ * 5;
    // 重新渲染
    [self render];
    
}

@end
