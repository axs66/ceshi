// WCPluginsHeader.h
// 定义其他插件提供的类和方法声明

#import <Foundation/Foundation.h>

@interface WCPluginsMgr : NSObject
+ (instancetype)sharedInstance;
- (void)registerControllerWithTitle:(NSString *)title 
                            version:(NSString *)version 
                         controller:(NSString *)controller;
@end

// 新增配置键（用于NSUserDefaults存储）
#define kEnableFullscreenBackGestureKey @"com.wechat.tweak.enableFullscreenBackGesture"

// 新增通知名称（用于状态变化通知）
#define kFullscreenBackGestureStateChangedNotification @"FullscreenBackGestureStateChanged"
