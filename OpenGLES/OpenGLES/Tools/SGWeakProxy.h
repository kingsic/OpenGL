//
//  SGWeakProxy.h
//  OpenGLES
//
//  Created by kingsic on 2022/7/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGWeakProxy : NSProxy
+ (instancetype)weakProxyWithTarget:(id)aTarget;
@end

NS_ASSUME_NONNULL_END
