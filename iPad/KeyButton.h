//
//  KeyButton.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#define KEY_HEIGHT 46.0f

@class KeyButton;

typedef enum {
	KeyButtonStateHighlighted = 0,
	KeyButtonStateReleased
} KeyButtonState;

typedef void (^TapHandlerBlock) (KeyButton *button, KeyButtonState state);

@interface KeyButton : UIView {
  @private
	TapHandlerBlock _tapHandler;
	BOOL _resetShift;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *secondaryTitle;
@property (nonatomic, assign) BOOL toggleMode;

@property (nonatomic, assign) BOOL isHighlighted;

- (void)sizeToFit;

- (void)enableTapHandler:(TapHandlerBlock)block;

@end
