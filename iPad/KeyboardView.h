//
//  KeyboardView.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@class KeyButton;
@protocol KeyboardViewDelegate;

// index path section = row, row = key

@interface KeyboardView : UIView {
  @private
	NSMutableArray *_keys;
}

@property (nonatomic, readonly) BOOL isShiftDown;

@property (nonatomic, assign) id < KeyboardViewDelegate > delegate;

- (void)reloadData;

- (void)untoggleShiftKey;

@end


@protocol KeyboardViewDelegate < NSObject >

- (NSUInteger)numberOfRowsForKeyboardView:(KeyboardView *)aView;
- (NSUInteger)keyboardView:(KeyboardView *)aView numberOfKeysInRow:(NSUInteger)rowIdx;

- (void)keyboardView:(KeyboardView *)aView configureButton:(KeyButton *)button
		 atIndexPath:(NSIndexPath *)path;

- (void)keyboardView:(KeyboardView *)aView didReleaseKey:(KeyButton *)button indexPath:(NSIndexPath *)path;

@end
