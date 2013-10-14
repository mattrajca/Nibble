//
//  KeyButton.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "KeyButton.h"

@interface KeyButton ()

- (void)configureView;

@end


@implementation KeyButton

#define LR_MARGIN 10.0f
#define MIN_WIDTH 46.0f

#define TITLE_FONT [UIFont boldSystemFontOfSize:17.0f]
#define BK_COLOR ([UIColor colorWithWhite:0.3f alpha:1.0f])

@synthesize title, secondaryTitle, toggleMode, isHighlighted;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self configureView];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configureView];
	}
	return self;
}

- (void)dealloc {
    [title release];
	[secondaryTitle release];
	[_tapHandler release];
	
    [super dealloc];
}

- (void)configureView {
	self.backgroundColor = [UIColor clearColor];
	self.layer.cornerRadius = 4.0f;
	self.layer.backgroundColor = BK_COLOR.CGColor;
	self.userInteractionEnabled = YES;
}

- (void)drawRect:(CGRect)rect {
	[[UIColor whiteColor] set];
	
	if (secondaryTitle) {
		[secondaryTitle drawInRect:CGRectMake(0.0f, 2.0f, self.bounds.size.width, 20.0f)
						  withFont:[UIFont systemFontOfSize:17.0f]
					 lineBreakMode:0
						 alignment:NSTextAlignmentCenter];
	}
	
	CGFloat ty = secondaryTitle ? 22.0f : 12.0f;
	
	[title drawInRect:CGRectMake(0.0f, ty, self.bounds.size.width, 20.0f)
			 withFont:TITLE_FONT
		lineBreakMode:0
			alignment:NSTextAlignmentCenter];
}

- (void)sizeToFit {
	CGSize size = [title sizeWithFont:TITLE_FONT];
	CGFloat width = MAX(size.width + 2 * LR_MARGIN, MIN_WIDTH);
	
	self.bounds = CGRectMake(0.0f, 0.0f, width, KEY_HEIGHT);
}

- (void)enableTapHandler:(TapHandlerBlock)block {
	if (_tapHandler) {
		[_tapHandler release];
		_tapHandler = NULL;
	}
	
	_tapHandler = [block copy];
}

- (void)setIsHighlighted:(BOOL)value {
	if (isHighlighted != value) {
		isHighlighted = value;
		
		[CATransaction setDisableActions:YES];
		
		if (isHighlighted) {
			self.layer.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.0f].CGColor;
		}
		else {
			self.layer.backgroundColor = BK_COLOR.CGColor;
		}
		
		[CATransaction setDisableActions:NO];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!_tapHandler || (toggleMode && isHighlighted)) {
		_resetShift = isHighlighted;
		return;
	}
	
	self.isHighlighted = YES;
	
	_tapHandler(self, KeyButtonStateHighlighted);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ((!_tapHandler || toggleMode) && !_resetShift)
		return;
	
	self.isHighlighted = NO;
	_resetShift = NO;
	
	if (_tapHandler)
		_tapHandler(self, KeyButtonStateReleased);
}

@end
