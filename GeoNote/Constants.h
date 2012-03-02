//
//  Constants.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#define kDefaultLatitude                               	0.0 
#define kDefaultLongitude                              	0.0 

#define kNetworkCheckURL                                @"google.com"

#define kMsgNoNetworkWarning                            @"No network connection detected.  Certain features may not work properly."
#define kMsgCannotFindLocation_UserDeniedAccess         @"Cannot find your location unless you agree to allow GPS lookup.  Please enable location services for this application under your device's settings menu and then restart the application."
#define kMsgCannotFindLocation_Timeout                  @"Could not find your location to within the desired accuracy." 

// KVO constants
#define kNotificationNetworkStatus                      @"kNotificationNetworkStatus"
#define kKeyNetworkFound                                @"kKeyNetworkFound"

#define kGPSAccuracyInMeters                            100.0 // Once a location is found with this accuracy, GPS lookup will stop.
#define kGPSLookupTimeoutInSeconds                      30.0  // If a location with desired accuracy not found within this time, 
                                                              // GPS lookup will stop and pin will be placed at most recent location.

#define kDefaultTableViewFormCellHeight                 44

#define kUD_LastNoteIndex                               @"kUD_LastNoteIndex"
