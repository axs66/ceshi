#import <UIKit/UIKit.h>

// 插件注册入口
%hook MinimizeViewController

- (void)viewDidLoad {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @try {
            Class wcPluginsMgr = objc_getClass("WCPluginsMgr");
            id instance = [wcPluginsMgr performSelector:@selector(sharedInstance)];
            if (instance && [instance respondsToSelector:@selector(registerControllerWithTitle:version:controller:)]) {
                [instance registerControllerWithTitle:@"全局返回手势" 
                                           version:@"1.0" 
                                        controller:@"CS1InputTextSettingsViewController"];
            }
        } @catch (NSException *exception) {
            NSLog(@"插件注册失败: %@", exception);
        }
    });
}
%end


// WCIsOverSeaUser微信通行密钥

%hook SettingUtil
+ (BOOL)isOverSeaUser {
	return YES;
}
%end


// WCNewMiniAppFloatingWindow微信启用AB测试的miniApp悬浮窗功能，仅限8.0.54+版本

%hook AffStarManager
- (BOOL)isOpenStarSwitch {
	return YES;
}
%end


// WCSVGColorHookExamples微信SVG图片颜色修改
/* 默认示范随机颜色*/ 
UIColor *randomColor(void) {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    CGFloat alpha = (arc4random_uniform(31) + 70) / 100.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

%hook MMThemeManager
- (UIImage *)svgImageNamed:(NSString *)name size:(struct CGSize)size color:(id)color alpha:(double)alpha angle:(int)angle ignoreNotFound:(BOOL)ignore {
    /* 当然 在这里你可以判断指定修改的SVG图片名称 */
	return %orig(name, size, randomColor(), alpha, angle, ignore);
}
%end


// WCKeyboardHideLogo微信键盘隐藏Logo

%hook WBMainInputView
- (BOOL)shouldHideLogoForAccessoryView {
    return YES;
}
%end


// WCABTestSingleChatBox微信启用AB测试单聊框功能，仅限8.0.55+版本

%hook ChatBoxConfigurationMgr
- (BOOL)isSingleChatBoxEnable {
	return YES;
}
%end


// WCABTestVoiceRecordView语音弧形按钮，仅限8.0.60+版本

%hook VoiceRecordView
+ (BOOL)isNewButtonStyle {
	return YES;
}
%end


// WCABTestLocalBackup聊天记录自动备份，仅限8.0.50+版本

unsigned long long hook_isOpenNewBackup(id self, SEL _cmd) {
    return 1;
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class cls = objc_getClass("WXGRoamBackupPackageService");
        Method md = class_getInstanceMethod(cls, @selector(isOpenNewBackup));
        if (md) {
            class_replaceMethod(cls, @selector(isOpenNewBackup), (IMP)hook_isOpenNewBackup, method_getTypeEncoding(md));
        }
    });
}


// WCABTestTimeLineEmoticonOrImage微信朋友圈图片评论，仅限8.0.60+版本

%hook WCMomentsPageContext
- (BOOL)supportCommentImagePost {
    return YES;
}
- (BOOL)supportCommentImageBrowse {
    return YES;
}
- (BOOL)supportCommentEmoticonPost {
    return YES;
}
- (BOOL)supportCommentEmoticonBrowse {
    return YES;
}
- (BOOL)supportCommentEmoticonOrImagePost {
    return YES;
}
- (BOOL)supportCommentEmoticonOrImageBrowse {
    return YES;
}
%end


// WCABTestC2CLivePhoto微信启用聊天发送实时照片，仅限8.0.57+版本

%hook ImageMessageUtils
+ (BOOL)isOpenLiveMsgUpload {
    return YES;
}
%end


// WCABTestDeleteUserKeepHistory微信启用删除联系人保留聊天记录，仅限8.0.62+版本

%hook ContactUtils
+ (BOOL)getDeleteContactKeepChatHistoryOpenSwitch {
	return YES;
}
%end


// WBNoAds微信去广告
@interface WBAdSdkFlashAdView : UIView
- (void)closeAd:(unsigned long long)arg1;
@end

%hook WBAdSdkFlashAdView

- (void)didMoveToSuperview {
    %log;
    %orig;

    if (self.superview) {
        [self setHidden:YES];
        [self closeAd:2];
    }
}

%end

%hook WBReadRedPacketView
- (id)initWithFrame:(struct CGRect)arg1 completeCount:(long long)arg2 {
    return 0;
}
%end

%hook WBNavLotteryButton
- (id)initWithFrame:(struct CGRect)arg1 {
    return 0;
}
%end


// WCEnableDictation微信输入框语音转述功能，仅限8.0.61+版本

%hook MMGrowTextViewExtConfig

- (BOOL)enableDictation {
    return YES;
}

- (void)setEnableDictation:(BOOL)arg1 {
    %orig(YES);
}

%end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        %init;
    });
}


// WCFullSwipe微信添加全局屏幕中间返回功能

NSString * const kEnableFullscreenBackGestureKey = @"com.wechat.enhance.enableFullscreenBackGesture";
NSString * const kFullscreenBackGestureStateChangedNotification = @"FullscreenBackGestureStateChangedNotification";
%hook MMUIViewController

// 1. 封装手势添加逻辑（新增方法）
- (void)cs_addFullscreenBackGestureIfNeeded {
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kEnableFullscreenBackGestureKey];
    if (!enabled) return;
    
    // 保留您原有的手势实现
    UIGestureRecognizer *edgeGesture = self.navigationController.interactivePopGestureRecognizer;
    edgeGesture.enabled = YES;
    
    NSArray *targets = [edgeGesture valueForKey:@"_targets"];
    id targetObj = [targets.firstObject valueForKey:@"target"];
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    
    // 避免重复添加手势
    __block BOOL gestureExists = NO;
    [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer *obj, NSUInteger idx, BOOL *stop) {
        if ([NSStringFromSelector(obj.action) containsString:@"handleNavigationTransition"]) {
            gestureExists = YES;
            *stop = YES;
        }
    }];
    
    if (!gestureExists) {
        UIPanGestureRecognizer *fullScreenPan = [[UIPanGestureRecognizer alloc] 
            initWithTarget:targetObj 
                   action:action];
        fullScreenPan.delegate = (id<UIGestureRecognizerDelegate>)self;
        fullScreenPan.maximumNumberOfTouches = 1;
        fullScreenPan.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:fullScreenPan];
    }
}

// 2. 修改viewDidLoad（调用新增方法）
- (void)viewDidLoad {
    %orig;
    [self cs_addFullscreenBackGestureIfNeeded];
}

// 3. 保留您原有的手势代理方法（完全不变）
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && 
        gestureRecognizer != self.navigationController.interactivePopGestureRecognizer) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint location = [panGesture locationInView:self.view];
        CGFloat screenWidth = self.view.bounds.size.width;
        
        BOOL isInMiddleArea = location.x > screenWidth/3 && location.x < screenWidth*2/3;
        
        CGPoint translation = [panGesture translationInView:self.view];
        BOOL isHorizontalSwipe = fabs(translation.x) > fabs(translation.y);
        BOOL isRightSwipe = translation.x > 0;
        
        return isInMiddleArea && isHorizontalSwipe && isRightSwipe;
    }
    
    return %orig;
}

// 4. 添加通知监听方法
- (void)cs_handleGestureSettingChange:(NSNotification *)notification {
    // 移除现有的全屏返回手势
    [self.view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer *obj, NSUInteger idx, BOOL *stop) {
        if ([NSStringFromSelector(obj.action) containsString:@"handleNavigationTransition"] && 
            obj != self.navigationController.interactivePopGestureRecognizer) {
            [self.view removeGestureRecognizer:obj];
            *stop = YES;
        }
    }];
    
    // 根据需要重新添加手势
    [self cs_addFullscreenBackGestureIfNeeded];
}

%end
%ctor {
    %init;
    
    // 注册通知监听
    [[NSNotificationCenter defaultCenter] 
        addObserverForName:kFullscreenBackGestureStateChangedNotification
                    object:nil 
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *note) {
        // 更新所有已存在的视图控制器
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            UIViewController *rootVC = window.rootViewController;
            [self recursivelyUpdateGestureInViewController:rootVC];
        }
    }];
    
    // 设置默认值（首次安装时默认开启）
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kEnableFullscreenBackGestureKey] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEnableFullscreenBackGestureKey];
    }
}

// 辅助方法：递归更新所有视图控制器的手势状态
static void recursivelyUpdateGestureInViewController(UIViewController *vc) {
    if ([vc isKindOfClass:NSClassFromString(@"MMUIViewController")]) {
        [vc performSelector:@selector(cs_handleGestureSettingChange:) withObject:nil];
    }
    
    for (UIViewController *childVC in vc.childViewControllers) {
        recursivelyUpdateGestureInViewController(childVC);
    }
    
    if (vc.presentedViewController) {
        recursivelyUpdateGestureInViewController(vc.presentedViewController);
    }
}





// WCEnhance重命名【我】页面、添加图片点击关闭手势、移除加好友页面我的二维码大图
@interface WCTableViewCellLeftConfig : NSObject
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
@end

@interface WCC2CImageScrollView : UIView
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
@end

@interface CExtendInfoOfImg : NSObject
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(_Bool)arg3;
- (void)setImage:(id)arg1 withData:(id)arg2 isOriginImage:(BOOL)arg3;
@end

%hook WCTableViewCellLeftConfig

- (NSString *)title {
	NSString *r = %orig;
	
	if (r == nil) {
		return nil;
	}
	if ([r isEqualToString:@"订单与卡包"]) {
		return @"卡包";
	}
	if ([r isEqualToString:@"支付与服务"]) {
		return @"服务";
	}
	
	return r;
}

%end

%hook UIButton

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
	%orig;

	if ([accessibilityLabel isEqualToString:@"我的⼆维码"]) {

		self.hidden = YES;
	}
}

%end

%hook WCC2CImageScrollView

- (void)layoutSubviews {
	%orig;
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
	if ([version compare:@"8.0.55" options:NSNumericSearch] != NSOrderedAscending) {
		BOOL hasGesture = NO;
		for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
			if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
				hasGesture = YES;
				break;
			}
		}
		
		if (!hasGesture) {
			UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
			[self addGestureRecognizer:tap];
		}
	}
	
	NSArray *subviews = [self.subviews copy];
	for (UIView *subview in subviews) {
		if ([subview class] == [UIView class]) {
			[subview removeFromSuperview];
		}
	}
}

%new
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	CGPoint location = [gesture locationInView:self];
	CGFloat width = self.bounds.size.width;
	CGFloat edgeWidth = width * 0.2;
	
	if (location.x <= edgeWidth || location.x >= (width - edgeWidth)) {
		SEL closeSelector = NSSelectorFromString(@"onCloseBtnClick:");
		if ([self respondsToSelector:closeSelector]) {
			[self performSelector:closeSelector withObject:nil];
		}
	}
}

%end

%hook CExtendInfoOfImg
%new
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(BOOL)arg3 {
	[self setImage:arg1 withData:arg2 isOriginImage:arg3];
}
%end


// WCEnableCleanOrigMsg原图、原视频14天后自动清理，仅限8.0.54+版本
%hook HDImageExpireUtils
+ (_Bool)isExptCleanOriginMsgOpened{
    return YES;
}
%end
