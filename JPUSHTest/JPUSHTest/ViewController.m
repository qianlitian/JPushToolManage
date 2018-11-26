//
//  ViewController.m
//  JPUSHTest
//
//  Created by itios on 2018/11/21.
//  Copyright © 2018年 qlt. All rights reserved.
//

#import "ViewController.h"
#import "JPUSHService.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setJpush];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)setJpush {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkFailedRegister:)
                          name:kJPFNetworkFailedRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(serviceError:)
                          name:kJPFServiceErrorNotification
                        object:nil];
}
#pragma mark - NSNotificationCenter事件
- (void)networkDidSetup:(NSNotification *)notification {
    
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    
    NSLog(@"未连接");
}

- (void)networkDidRegister:(NSNotification *)notification {
    
    NSLog(@"已注册");
    NSLog(@"\n%@", [notification userInfo]);
    
}
- (void)networkFailedRegister:(NSNotification *)notification {
    
    NSLog(@"注册失败");
    NSLog(@"\n%@", [notification userInfo]);
    
}

- (void)networkDidLogin:(NSNotification *)notification {
    
    NSLog(@"已登录");
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        NSLog(@"resCode : %d,registrationID: %@",resCode,registrationID);
    }];
    

}
- (void)serviceError:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *error = [userInfo valueForKey:@"error"];
    NSLog(@"\n%@", error);
}
#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
// 注意，如果是发送"自定义消息"，那么只有app处于前台时才能立刻接收到消息。如果app处于后台或者关闭状态，不会有通知栏提示，但是当app进入前台时，会接收到消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSLog(@"自定义弹");

//    self.timeLabel.text = [NSString stringWithFormat:@"时间：%@", [dateFormatter stringFromDate:[NSDate date]]];
//    self.titleLabel.text = [NSString stringWithFormat:@"标题：%@", title];
//    self.contentLabel.text = [NSString stringWithFormat:@"内容：%@", content];
//    self.extraLabel.text = [NSString stringWithFormat:@"传值：%@", [self logDic:extra]];
}

@end
