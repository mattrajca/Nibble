//
//  ProgressView.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

#define WIDTH 64.0f
#define INDICATOR_WIDTH 32.0f

#define ANIMATION_DURATION 0.2f

- (id)init {
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, WIDTH, WIDTH)];
	if (self) {
		self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f].CGColor;
		self.layer.cornerRadius = 8.0f;
		
		self.alpha = 0.0f;
		
		_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_indicator.bounds = CGRectMake(0.0f, 0.0f, INDICATOR_WIDTH, INDICATOR_WIDTH);
		_indicator.center = CGPointMake(WIDTH / 2, WIDTH / 2);
		_indicator.hidesWhenStopped = NO;
		
		[self addSubview:_indicator];
	}
	return self;
}

- (void)dealloc {
	[_indicator release];
	[super dealloc];
}

- (void)showInView:(UIView *)view {
	CGRect bounds = [view bounds];
	self.center = CGPointMake(CGRectGetMidX(bounds), (int) (CGRectGetMidY(bounds) * 2 / 3));
	
	[view addSubview:self];
	
	self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
	
	[_indicator startAnimating];
	
	[self performSelector:@selector(animateIn) withObject:nil afterDelay:0.0f];
}

- (void)animateIn {
	[UIView animateWithDuration:ANIMATION_DURATION
					 animations:^{
						 
						 self.alpha = 1.0f;
						 self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
						 
					 }];
}

- (void)dismiss {
	[UIView animateWithDuration:ANIMATION_DURATION
					 animations:^{
						 
						 self.alpha = 0.0f;
						 self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
						 
					 }
					 completion:^(BOOL finished) {
						 
						 [_indicator stopAnimating];
						 [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.0f];
						 
					 }];
}

@end
