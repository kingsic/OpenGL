//
//  SplitScreenView.h
//  OpenGLES
//
//  Created by kingsic on 2022/7/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SplitScreenView : UIView
- (void)splitScreenViewFragment:(NSString *)fragmentFilepath;
- (void)splitScreenViewScaleAnimator;
@end

NS_ASSUME_NONNULL_END
