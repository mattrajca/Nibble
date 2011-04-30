//
//  KeyboardView.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "KeyboardView.h"

#import "KeyButton.h"
#import "UIView+Additions.h"

@interface KeyboardView ()

- (KeyButton *)firstToggledButton;

- (void)highlightedKey:(KeyButton *)button;
- (void)releasedKey:(KeyButton *)button;

@end


@implementation KeyboardView

#define KEY_MARGIN 4.0f

@synthesize isShiftDown, delegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_keys = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[_keys release];
	
	[super dealloc];
}

- (void)setDelegate:(id < KeyboardViewDelegate >)aDelegate {
	if (delegate != aDelegate) {
		delegate = aDelegate;
		
		if (delegate)
			[self reloadData];
	}
}

- (void)reloadData {
	if (![delegate respondsToSelector:@selector(numberOfRowsForKeyboardView:)])
		return;
	
	if (![delegate respondsToSelector:@selector(keyboardView:numberOfKeysInRow:)])
		return;
	
	if (![delegate respondsToSelector:@selector(keyboardView:configureButton:atIndexPath:)])
		return;
	
	NSUInteger rows = [delegate numberOfRowsForKeyboardView:self];
	
	for (NSUInteger row = 0; row < rows; row++) {
		NSUInteger keys = [delegate keyboardView:self numberOfKeysInRow:row];
		
		NSMutableArray *views = [[NSMutableArray alloc] init];
		CGFloat width = 0.0f;
		
		for (NSUInteger n = 0; n < keys; n++) {
			NSIndexPath *path = [NSIndexPath indexPathForRow:n inSection:row];
			
			KeyButton *button = [[KeyButton alloc] initWithFrame:CGRectZero];
			button.userInfo = path;
			
			[button enableTapHandler:^(KeyButton *button, KeyButtonState state) {
				
				if (state == KeyButtonStateHighlighted) {
					[self highlightedKey:button];
				}
				else if (state == KeyButtonStateReleased) {
					[self releasedKey:button];
				}
				
			}];
			
			[delegate keyboardView:self configureButton:button atIndexPath:path];
			
			[_keys addObject:button];
			[button release];
			
			[views addObject:button];
			[button release];
			
			width += button.bounds.size.width + KEY_MARGIN;
		}
		
		CGFloat xOffset = floorf(([self bounds].size.width - width) / 2);
		CGFloat pos = 0.0f;
		
		for (KeyButton *button in views) {
			CGRect rect = [button bounds];
			rect.origin.x = xOffset + pos;
			rect.origin.y = row * (KEY_MARGIN + KEY_HEIGHT);
			
			button.frame = rect;
			
			[self addSubview:button];
			
			pos += button.layer.bounds.size.width + KEY_MARGIN;
		}
		
		[views release];
	}
}

- (void)untoggleShiftKey {
	[[self firstToggledButton] setIsHighlighted:NO];
	
	isShiftDown = NO;
}

- (KeyButton *)firstToggledButton {
	for (KeyButton *button in _keys) {
		if (button.toggleMode && button.isHighlighted)
			return button;
	}
	
	return nil;
}

- (void)highlightedKey:(KeyButton *)button {
	if (button.toggleMode) {
		isShiftDown = YES;
	}
}

- (void)releasedKey:(KeyButton *)button {
	NSIndexPath *key = (NSIndexPath *) button.userInfo;
	
	if (button.toggleMode) {
		[self untoggleShiftKey];
		return;
	}
	
	if ([delegate respondsToSelector:@selector(keyboardView:didTapKeyAtIndexPath:)]) {
		[delegate keyboardView:self didTapKeyAtIndexPath:key];
	}
}

@end
