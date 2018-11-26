//
//  JPushManager.m
//  JPUSHTest
//
//  Created by itios on 2018/11/22.
//  Copyright © 2018年 qlt. All rights reserved.
//

#import "JPushManager.h"
// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

#define appKeyJpush @"bfd5797dcf4c089a1e3fccd9"
#define channelJpush @"Ad_Hoc"
#define SYisProduction 1
@interface JPushManager()<JPUSHRegisterDelegate>
//是不是从通知点进来
@property(nonatomic, assign) BOOL isLaunchedByNotification;
@end
@implementation JPushManager
+ (JPushManager *)shareJPushManager
{
    static JPushManager * JPushTool = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        JPushTool = [[JPushManager alloc] init];
    });
    
    return JPushTool;
}
//检测是否从通知栏启动得应用
-(void)isFromNotification:(NSDictionary *)launchingOption {
     NSDictionary *remoteNotification = [launchingOption objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        //自定义的BOOL值,用来标记是从通知启动的应用
        self.isLaunchedByNotification = YES;
    }else{
        
    }
        [self checkIsLaunchedByNotification];
    
}
#pragma mark - 检测是否从通知栏启动得应用

- (void)checkIsLaunchedByNotification{
    
    if (self.isLaunchedByNotification) {
        
        
        NSLog(@"从通知栏启动得应用" );
        
        
    }
}

// 在应用启动的时候调用
- (void)cdm_setupWithOption:(NSDictionary *)launchingOption
                     appKey:(NSString *)appKey
                    channel:(NSString *)channel
           apsForProduction:(BOOL)isProduction
      advertisingIdentifier:(NSString *)advertisingId
{
    
    //Required
    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: ]
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    // Optional
    // 获取 IDFA
    // 如需使用 IDFA 功能请添加此代码并在初始化方法的 advertisingIdentifier 参数中填写对应值

    // Required
    // init Push
    // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
    // 如需继续使用 pushConfig.plist 文件声明 appKey 等配置内容，请依旧使用 [JPUSHService setupWithOption:launchOptions] 方式初始化。
    [JPUSHService setupWithOption:launchingOption appKey:appKeyJpush
                          channel:channelJpush
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    
    //    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //
    //    [JPUSHService setBadge:0];
    //推送自定义消息
//    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
//    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    return;
}
//实现回调方法 networkDidReceiveMessage
//- (void)networkDidReceiveMessage:(NSNotification *)notification {
//
//    NSDictionary * userInfo = [notification userInfo];
//    NSString *content = [userInfo valueForKey:@"content"];
//    NSString *messageID = [userInfo valueForKey:@"_j_msgid"];
//    NSDictionary *extras = [userInfo valueForKey:@"extras"];
//    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的 Extras 附加字段，key 是自己定义的
//    NSLog(@"自定义%@" , userInfo);
//}
// 在appdelegate注册设备处调用
- (void)cdm_registerDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
    return;
    
}
//设置角标
- (void)cdm_setBadge:(int)badge
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    [JPUSHService setBadge:badge];
}
//获取注册ID
- (void)cdm_getRegisterIDCallBack:(void(^)(NSString *registerID))completionHandler
{
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        //        if(resCode == 0){
        //        NSLog(@"registrationID获取成功：%@",registrationID);
        
        //        }
        //        else{
        //            NSLog(@"registrationID获取失败，code：%d",resCode);
        //        }
        
        if (resCode == 0) {
            
            NSLog(@"registrationID获取成功：%@",registrationID);
            
            completionHandler(registrationID);
        }
    }];
    
}
//处理推送信息
- (void)cdm_handleRemoteNotification:(NSDictionary *)remoteInfo
{
    [JPUSHService handleRemoteNotification:remoteInfo];
    [self cdm_setBadge:0];
    
}

//实现注册 APNs 失败接口
-(void)failToRegisterRemoteNotification:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    //Optional
//    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
//}


//delegate
// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required, For systems with less than or equal to iOS 6
    [JPUSHService handleRemoteNotification:userInfo];
}
@end
