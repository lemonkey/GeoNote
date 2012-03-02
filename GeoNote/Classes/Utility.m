//
//  Utility.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/24/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "Utility.h"


// Private methods
@interface Utility()

-(void)restoreLastNoteIndex;

@end

// Main implementation
@implementation Utility
@synthesize lastNoteIndex = _lastNoteIndex;

+(Utility *)instance {
	DLog(@"");
	
	static Utility *instance;
	
	@synchronized(self) {
		if(!instance) {
			instance = [[Utility alloc] init];
            [instance restoreLastNoteIndex];
		}
	}
	
	return instance;
}

-(void)dealloc {
	DLog(@"");
    
	[super dealloc];
}

#pragma mark -
#pragma mark Instance methods

-(void)restoreLastNoteIndex {
    DLog(@"");
    
    self.lastNoteIndex = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUD_LastNoteIndex];
}

-(NSNumber *)getNextNoteIndex {
    DLog(@"lastNoteIndex: %@", self.lastNoteIndex);
    
    self.lastNoteIndex = [NSNumber numberWithInt:([self.lastNoteIndex intValue]+1)];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.lastNoteIndex forKey:kUD_LastNoteIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return self.lastNoteIndex;
}

#pragma mark -
#pragma mark Class methods

// Given a UILabel, adjusts its overall height based 
// on the total number of lines of its text.
+(void)verticallyAlignLabel:(UILabel *)label {
	DLog(@"label: %@", label);
	
	if(label != nil) {
		CGSize headlineSize = CGSizeMake(label.frame.size.width, label.frame.size.height);
		CGSize fontSize = [label.text sizeWithFont:label.font];
		CGSize textSize = [label.text sizeWithFont:label.font
								 constrainedToSize:headlineSize
									 lineBreakMode:label.lineBreakMode];
		label.numberOfLines = textSize.height / fontSize.height;
		label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, textSize.width, fontSize.height * label.numberOfLines);
	}
}

// Simple helper method to show a general alert.
+(void)showGeneralAlertMsg:(NSString *)msg withTitle:(NSString *)title {
    DLog(@"");
    
    if(msg && title) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        DLog(@"Error: Util - showGeneralAlertMsg requires both msg and title!");
    }
}

@end