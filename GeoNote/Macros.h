//
//  Macros.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#ifdef DEBUG
    // Pretty console log formatting
    #define DLog(format, ...) NSLog(@"<DEBUG: %s> " format, __func__,  ## __VA_ARGS__)
#else
    // Suppress logging to console if not DEBUG build
    #define DLog(format, ...)
#endif