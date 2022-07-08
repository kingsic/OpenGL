//
//  GLTexture.h
//  OpenGLES
//
//  Created by kingsic on 2022/7/3.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTexture : NSObject
/**
 * 加载纹理
 *
 * @return 返回的纹理ID
 */
+ (GLuint)textureWithName:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
