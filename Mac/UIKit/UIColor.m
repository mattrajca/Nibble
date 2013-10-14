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
		_color = color;
	}
	return self;
}


+ (UIColor *)blackColor {
	return [[[self class] alloc] initWithNSColor:[NSColor blackColor]];
}

- (void)set {
	[_color set];
}

@end
