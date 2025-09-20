// WCPluginsHeader.h
// 定义其他插件提供的类和方法声明

#import <Foundation/Foundation.h>

@interface WCPluginsMgr : NSObject
+ (instancetype)sharedInstance;
- (void)registerControllerWithTitle:(NSString *)title 
                            version:(NSString *)version 
                         controller:(NSString *)controller;
@end

// 在WCPluginsHeader.h文件末尾添加以下常量
extern NSString * const kEnableFullscreenBackGestureKey;
extern NSString * const kFullscreenBackGestureStateChangedNotification;

