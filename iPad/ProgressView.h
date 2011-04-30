//
//  ProgressView.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@interface ProgressView : UIView {
  @private
	UIActivityIndicatorView *_indicator;
}

- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
