//
//  BridgeInvocation.m
//  BridgeWebKit
//
//  Created by Tsuf on 2018/1/8.
//  Copyright © 2018年 upmer. All rights reserved.
//

#import "BridgeInvocation.h"

@implementation BridgeInvocation

+ (void)excuteNatureBridgeWithMethod:(NSString *)method argments:(NSArray *)args interface:(NSObject *)interface
{
    SEL selector = NSSelectorFromString(method);
    NSMethodSignature *signature = [[interface class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = interface;
    
    for (int i = 0; i < args.count; i++) {
        NSString *arg = [(NSString *)args[i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [invocation setArgument:&arg atIndex:i + 2];
    }
    [invocation invoke];
}

@end
