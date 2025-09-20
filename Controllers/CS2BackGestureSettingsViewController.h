#import <UIKit/UIKit.h>

// 前向声明，避免重复导入
@class CSSettingSection;

@interface CS2BackGestureSettingsViewController : UITableViewController

@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;

@end
