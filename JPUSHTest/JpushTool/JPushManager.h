//
//  JPushManager.h
//  JPUSHTest
//
//  Created by itios on 2018/11/22.
//  Copyright © 2018年 qlt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface JPushManager : NSObject
+ (JPushManager *)shareJPushManager;
//检测是否从通知栏启动得应用
-(void)isFromNotification:(NSDictionary *)launchingOption;
// 在应用启动的时候调用
- (void)cdm_setupWithOption:(NSDictionary *)launchingOption
                     appKey:(NSString *)appKey
                    channel:(NSString *)channel
           apsForProduction:(BOOL)isProduction
      advertisingIdentifier:(NSString *)advertisingId;
// 在appdelegate注册设备处调用
- (void)cdm_registerDeviceToken:(NSData *)deviceToken;
//设置角标
- (void)cdm_setBadge:(int)badge;
//获取注册ID
- (void)cdm_getRegisterIDCallBack:(void(^)(NSString *registerID))completionHandler;
//处理推送信息
- (void)cdm_handleRemoteNotification:(NSDictionary *)remoteInfo;
//实现注册 APNs 失败接口
-(void)failToRegisterRemoteNotification:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
