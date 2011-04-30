//
//  UIGraphics.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "UIGraphics.h"

void UIRectFill (CGRect rect) {
	NSRectFill(NSRectFromCGRect(rect));
}

CGContextRef UIGraphicsGetCurrentContext (void) {
	return [[NSGraphicsContext currentContext] graphicsPort];
}
