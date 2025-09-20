#import "CS2BackGestureSettingsViewController.h"
#import "CSSettingTableViewCell.h"
#import <objc/runtime.h>

// 全屏返回手势开关键
static NSString * const kFullScreenBackGestureEnabledKey = @"com.wechat.enhance.fullScreenBackGesture.enabled";

@implementation CS2BackGestureSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航标题
    self.title = @"全屏返回手势";
    
    // 设置UI样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 设置数据
    [self setupData];
}

- (void)setupData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 使用类方法创建设置项
    CSSettingItem *fullScreenBackGestureItem = [CSSettingItem switchItemWithTitle:@"启用全屏返回手势" 
                                                                        iconName:@"arrow.left.arrow.right" 
                                                                       iconColor:[UIColor systemBlueColor] 
                                                                     switchValue:[defaults boolForKey:kFullScreenBackGestureEnabledKey]
                                                               valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kFullScreenBackGestureEnabledKey];
        [defaults synchronize];
    }];
    
    // 创建说明项
    CSSettingItem *descriptionItem = [CSSettingItem itemWithTitle:@"功能说明" 
                                                         iconName:@"info.circle" 
                                                        iconColor:[UIColor systemGrayColor] 
                                                          detail:@"屏幕中间右滑返回"];
    
    // 创建设置组
    CSSettingSection *mainSection = [CSSettingSection sectionWithHeader:@"手势设置" 
                                                                 items:@[fullScreenBackGestureItem, descriptionItem]];
    
    self.sections = @[mainSection];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CSSettingSection *settingSection = self.sections[section];
    return settingSection.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSSettingTableViewCell reuseIdentifier]];
    
    CSSettingSection *section = self.sections[indexPath.section];
    CSSettingItem *item = section.items[indexPath.row];
    [cell configureWithItem:item];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CSSettingSection *settingSection = self.sections[section];
    return settingSection.header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"开启后可在微信任意页面通过屏幕中间右滑手势返回上一级，提升操作便捷性";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
