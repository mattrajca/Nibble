//
//  UIColor.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@interface UIColor : NSObject {
  @private
	NSColor *_color;
}

+ (UIColor *)blackColor;

- (void)set;

@end
