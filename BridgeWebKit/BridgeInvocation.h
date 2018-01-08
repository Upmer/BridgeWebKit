//
//  BridgeInvocation.h
//  BridgeWebKit
//
//  Created by Tsuf on 2018/1/8.
//  Copyright © 2018年 upmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BridgeInvocation : NSObject

+ (void)excuteNatureBridgeWithMethod:(NSString *)method argments:(NSArray *)args interface:(NSObject *)interface;

@end
