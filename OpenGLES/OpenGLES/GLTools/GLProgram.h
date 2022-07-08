//
//  GLProgram.h
//  OpenGLES
//
//  Created by kingsic on 2022/7/2.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLProgram : NSObject

/**
 *  Load a vertex and fragment shader, create a program object, link program.
 *
 *  @param vertexShaderFilepath            Vertex shader source file path
 *  @param fragmentShaderFilepath          Fragment shader source file path
 *
 *  @return A new program object linked with the vertex/fragment shader pair, 0 on failure
 */
+ (GLuint)programWithVertexShader:(NSString *)vertexShaderFilepath fragmentShader:(NSString *)fragmentShaderFilepath;


/**
 *  Load and cCompile a shader
 *
 *  @param type            shader type
 *  @param filepath        shader source file path
 *
 *  @return A new shader object with compile, 0 on failure
 */
+ (GLuint)loadShader:(GLenum)type filepath:(NSString *)filepath;

@end

NS_ASSUME_NONNULL_END
