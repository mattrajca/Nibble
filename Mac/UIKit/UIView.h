//
//  UIView.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@interface UIView : NSView {

}

- (void)setNeedsDisplay;

@end


@protocol UIKeyInput < NSObject >

- (BOOL)hasText;
- (void)insertText:(NSString *)text;
- (void)deleteBackward;

@end
