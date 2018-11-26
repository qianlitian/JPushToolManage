//
//  AppDelegate.m
//  JPUSHTest
//
//  Created by itios on 2018/11/21.
//  Copyright © 2018年 qlt. All rights reserved.
//

#import "AppDelegate.h"
#import "MessViewController.h"
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
#define isProduction 1
@interface AppDelegate ()<JPUSHRegisterDelegate>
/**      **/
@property(nonatomic, assign) BOOL isLaunchedByNotification;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = na;
   
    
    
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification) {
        //自定义的BOOL值,用来标记是从通知启动的应用
        self.isLaunchedByNotification = YES;
    }else{
        
    }
    [self checkIsLaunchedByNotification];
    [self initJPush:launchOptions];
    
    
    // Override point for customization after application launch.
    return YES;
}
#pragma mark - 检测是否从通知栏启动得应用

- (void)checkIsLaunchedByNotification{
    
    if (self.isLaunchedByNotification) {
        
        [self gotoMessageVC];
        NSLog(@"从通知栏启动得应用" );
        
        
    }
}
#pragma mark - 点击了通知菜单(当应用在前台时,收到推送,点击了自定义的弹窗,调用的方法)

- (void)clickBannerView:(NSNotification *)notification{
    
    NSDictionary * dict =  notification.object;
    NSLog(@" 点了通知栏%@" ,  dict);

}

#pragma mark - 跳转到消息界面(点击通知菜单／点击通知栏启动应用时)

- (void)gotoMessageVC{
    
    MessViewController  *vc = [[MessViewController alloc] init];
    UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = na;
    
}
-(void)initJPush:(NSDictionary *)launchOptions {
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
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
    // 如需继续使用 pushConfig.plist 文件声明 appKey 等配置内容，请依旧使用 [JPUSHService setupWithOption:launchOptions] 方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:appKeyJpush
                          channel:channelJpush
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
  
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//
//    [JPUSHService setBadge:0];
    //推送自定义消息
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}
//实现回调方法 networkDidReceiveMessage
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSString *messageID = [userInfo valueForKey:@"_j_msgid"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的 Extras 附加字段，key 是自己定义的
    NSLog(@"自定义%@" , userInfo);
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
#pragma mark- JPUSHRegisterDelegate

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
   
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
        NSLog(@"从通知界面直接进入应用");
    }else{
        //从通知设置界面进入应用
        NSLog(@"设置界面进入应用进入应用");
    }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSLog(@"ppp");
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSLog(@"%@",userInfo);
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"rrrr");
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            //处于前台时
    
            //        [EBForeNotification handleRemoteNotification:@{@"aps":@{@"alert":[NSString stringWithFormat:@"%@",body]}} soundID:1312];
            NSLog(@"前台*********");
            FirstViewController  *vc = [[FirstViewController alloc] init];
            UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:vc];
            self.window.rootViewController = na;
    
    
        }else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
    
            //处于后台时
            NSLog(@"后台*********");
            [self gotoMessageVC];
        }
    
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSInteger number = response.notification.request.content.badge.integerValue;
    
    //角标问题处理我们获取推送内容里的角标 -1 就是当前的角标
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number - 1];
    [JPUSHService setBadge:number - 1];//相当于告诉极光服务器我现在的角标是多少
    
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
  
    [JPUSHService handleRemoteNotification:userInfo];
}
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [application setApplicationIconBadgeNumber:0];   //清除角标
//    [JPUSHService setBadge:0];//同样的告诉极光角标为0了
////    [application cancelAllLocalNotifications];
//}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
