//
//  UIApplication+Network.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/24/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "UIApplication+Network.h"


#define ReachableViaWiFiNetwork      2
#define ReachableDirectWWAN			(1 << 18)

@implementation UIApplication (Network)

// Check specifically for a WiFi connection
+(BOOL)hasActiveWiFiConnection {
    DLog(@"");
    
	SCNetworkReachabilityFlags	flags;
	SCNetworkReachabilityRef	reachabilityRef;
	BOOL						gotFlags;
	
	reachabilityRef = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(),[kNetworkCheckURL UTF8String]);
	
	gotFlags = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
	CFRelease(reachabilityRef);
	
	if (!gotFlags)
		return NO;
	
	if( flags & ReachableDirectWWAN )
		return NO;
	
	if( flags & ReachableViaWiFiNetwork )
		return YES;
	
	return NO;
}

// Check for any type of connection (Edge, 3G, WiFi)
+(BOOL)hasNetworkConnection {
    DLog(@"");
    
	bool success = false;
	const char *host_name = [kNetworkCheckURL
							 cStringUsingEncoding:NSASCIIStringEncoding];
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,
																				host_name);
	SCNetworkReachabilityFlags flags;
	success = SCNetworkReachabilityGetFlags(reachability, &flags);
	bool isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	
	if (isAvailable) {
		DLog(@"Host is reachable: %d", flags);
	}else{
		DLog(@"Host is unreachable");
	}
	
	return isAvailable;
}

@end