//
//  UIView.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "UIView.h"

@implementation UIView

- (void)setNeedsDisplay {
	[self setNeedsDisplay:YES];
}

- (BOOL)isFlipped {
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
	if (![self respondsToSelector:@selector(insertText:)])
		return;
	
	[self insertText:[theEvent characters]];
}

@end
