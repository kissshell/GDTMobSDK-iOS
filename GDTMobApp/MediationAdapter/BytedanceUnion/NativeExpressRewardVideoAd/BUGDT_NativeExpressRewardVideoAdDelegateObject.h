//
//  BUGDT_NativeExpressRewardVideoAdDelegateObject.h
//  GDTMobApp
//
//  Created by zhangzilong on 2021/4/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDTRewardVideoAdNetworkConnectorProtocol.h"
#import <BUAdSDK/BUNativeExpressRewardedVideoAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface BUGDT_NativeExpressRewardVideoAdDelegateObject : NSObject <BUNativeExpressRewardedVideoAdDelegate>

@property (nonatomic, weak) id<GDTRewardVideoAdNetworkConnectorProtocol> connector;

@property (nonatomic, assign) BOOL isAdValid;
@property (nonatomic, assign) NSInteger loadedTime;
@property (nonatomic, weak) id adapter;

@end

NS_ASSUME_NONNULL_END
