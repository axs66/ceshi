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
    
    // 全屏返回手势开关
    CSSettingItem *fullScreenBackGestureItem = [CSSettingItem switchItemWithTitle:@"全屏返回手势" 
                                                                        iconName:@"arrow.left.arrow.right" 
                                                                       iconColor:[UIColor systemBlueColor] 
                                                                     switchValue:[defaults boolForKey:kFullScreenBackGestureEnabledKey]
                                                               valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kFullScreenBackGestureEnabledKey];
        [defaults synchronize];
    }];
    
    // 说明项 - 使用正确的方式创建
    CSSettingItem *descriptionItem = [CSSettingItem itemWithTitle:@"功能说明" 
                                                         iconName:@"info.circle" 
                                                        iconColor:[UIColor systemGrayColor] 
                                                          detail:@"在任意页面右滑返回"];
    
    // 设置组
    CSSettingSection *mainSection = [CSSettingSection sectionWithHeader:@"手势设置" 
                                                                 items:@[fullScreenBackGestureItem, descriptionItem]];
    
    self.sections = @[mainSection];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSSettingTableViewCell reuseIdentifier]];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"开启后可在微信任意页面通过右滑手势返回上一级，提升操作便捷性";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
