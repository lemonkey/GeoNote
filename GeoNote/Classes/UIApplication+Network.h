//
//  UIApplication+Network.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/24/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>


@interface UIApplication (Network)

+(BOOL)hasActiveWiFiConnection;
+(BOOL)hasNetworkConnection;

@end
