//
//  GLTexture.m
//  OpenGLES
//
//  Created by kingsic on 2022/7/3.
//

#import "GLTexture.h"
#import <UIKit/UIKit.h>

@implementation GLTexture
/**
 * 加载纹理
 *
 * @return 返回的纹理ID
 */
+ (GLuint)textureWithName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    // 将 UIImage -> CGImageRef
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        NSLog(@"Failed to lead image %@", imageName);
        return 0;
    }
    
    // 获取图片的数据大小、宽高、字节数
    GLuint imgWidth = (GLuint)CGImageGetWidth(imageRef);
    GLuint imgHeight = (GLuint)CGImageGetHeight(imageRef);
    GLubyte *imageData = (GLubyte *)calloc(imgWidth * imgHeight * 4, sizeof(GLubyte));
    
    /** 创建上下文
     para1: data，指向要渲染的绘制图像的内存地址
     para2: width，bitmap的宽度，单位为像素
     para3: height，bitmap的高度，单位为像素
     para4: bitPerComponent，内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     para5: bytesPerRow，bitmap的没一行的内存所占的比特数
     para6: colorSpace，bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef imgContext = CGBitmapContextCreate(imageData, imgWidth, imgHeight, 8, imgWidth * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);

    CGRect imgRect = CGRectMake(0, 0, imgWidth, imgHeight);
    
    // 获取图片的颜色空间
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 翻转图片
//    CGContextTranslateCTM(imgContext, 0, imgHeight);
//    CGContextScaleCTM(imgContext, 1.0f, -1.0f);
//    CGColorSpaceRelease(colorSpace);
//    CGContextClearRect(imgContext, imgRect);
    
    // 重新绘制图——解压缩的位图
    CGContextDrawImage(imgContext, imgRect, imageRef);

    // 设置图片纹理属性
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);

    // 载入纹理
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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imgWidth, imgHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

    // 设置纹理属性：过滤方式 + 环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // 绑定纹理
    glBindTexture(GL_TEXTURE_2D, 0);

    CGContextRelease(imgContext);
    free(imageData);
    
    // 返回纹理id
    return textureID;
}


@end
