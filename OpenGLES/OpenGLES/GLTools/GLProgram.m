//
//  GLProgram.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/2.
//

#import "GLProgram.h"

@implementation GLProgram

+ (GLuint)programWithVertexShader:(NSString *)vertexShaderFilepath fragmentShader:(NSString *)fragmentShaderFilepath {
    // Load the vertex/fragment shaders
    GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER
                        withShaderFilepath:vertexShaderFilepath];
    if (vertexShader == 0)
        return 0;
    
    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER
                          withShaderFilepath:fragmentShaderFilepath];
    if (fragmentShader == 0) {
        glDeleteShader(vertexShader);
        return 0;
    }
    
    // Create the program object
    GLuint program = glCreateProgram();
    if (program == 0)
        return 0;
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // Link the program
    glLinkProgram(program);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1){
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);

            NSLog(@"Error linking program:\n%s\n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(program);
        return 0;
    }
    
    // Free up no longer needed shader resources
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return program;
}


+ (GLuint)loadShader:(GLenum)type filepath:(NSString *)filepath {
    return [self loadShader:type withShaderFilepath:filepath];
}

+ (GLuint)loadShader:(GLenum)type withShaderFilepath:(NSString *)shaderFilepath {
    NSError *error;
    NSString *filePath = [NSString stringWithContentsOfFile:shaderFilepath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (!filePath) {
        NSLog(@"Error: loading shader file: %@ %@", shaderFilepath, error.localizedDescription);
        return 0;
    }
    
    return [self compileShader:type withShaderFilepath:filePath];
}

+ (GLuint)compileShader:(GLenum)type withShaderFilepath:(NSString *)shaderFilepath {
    // Create the shader object
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"Error: failed to create shader");
        return 0;
    }
    
    // Load the shader source
    const char *shaderSource = [shaderFilepath UTF8String];
    
    // 将着色器源码附加到着色器对象上
    // 参数1：shader, 要编译的着色器对象 *shader
    // 参数2：numOfStrings, 传递的源码字符串数量 1个
    // 参数3：strings, 着色器程序的源码（真正的着色器程序源码）
    // 参数4：lenOfStrings, 长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
    glShaderSource(shader, 1, &shaderSource, NULL);
    
    // Compile the shader
    // 把着色器源代码编译成目标代码
    glCompileShader(shader);
    
    // Check the compile status
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv (shader, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n %s \n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}


@end
