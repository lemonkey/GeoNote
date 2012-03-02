//
//  Settings.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#ifdef DEBUG
    #define kOverrideLocation                   NO		// if yes, uses default lat/lon coordinates (see Constants.h)
#else
    #define kOverrideLocation                   NO			
#endif

#define kStopGPSAfterFirstLocationFound         NO      // if no, GPS will continue to lookup location until horizontal 
                                                        // accuracy threshold kGPSAccuracyInMeters is reached or GPS times out.