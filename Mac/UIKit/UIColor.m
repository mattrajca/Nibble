//
//  UIColor.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "UIColor.h"

@interface UIColor ()

- (id)initWithNSColor:(NSColor *)color;

@end


@implementation UIColor

- (id)initWithNSColor:(NSColor *)color {
	self = [super init];
	if (self) {
		_color = [color retain];
	}
	return self;
}

- (void)dealloc {
	[_color release];
	[super dealloc];
}

+ (UIColor *)blackColor {
	return [[[[self class] alloc] initWithNSColor:[NSColor blackColor]] autorelease];
}

- (void)set {
	[_color set];
}

@end
