//
//  PIA6821+Additions.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "PIA6821+Additions.h"

@implementation PIA6821 (Additions)

#define CHARACTER_DELAY 0.1f

- (void)evokeRunAtAddress:(uint16_t)addr {
	char buffer[16];
	sprintf(buffer, "%X", addr);
	
	size_t len = strlen(buffer);
	
	for (int n = 0; n < len; n++) {
		NSString *string = [NSString stringWithFormat:@"%c", buffer[n]];
		
		[self performSelector:@selector(loadChar:)
				   withObject:string
				   afterDelay:n * CHARACTER_DELAY];
		
		if (n + 1 == len) {
			[self performSelector:@selector(loadChar:)
					   withObject:@"R"
					   afterDelay:(n+1) * CHARACTER_DELAY];
			
			[self performSelector:@selector(loadChar:)
					   withObject:@"\r"
					   afterDelay:(n+2) * CHARACTER_DELAY];
		}
	}
}

- (void)loadChar:(NSString *)string {
	[self processInputChar:[string characterAtIndex:0]];
}

@end
