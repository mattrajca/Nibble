//
//  ScreenView.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#if !TARGET_OS_IPHONE
#import "UIView.h"
#import "UIColor.h"
#import "UIGraphics.h"
#endif

#define COLS 40
#define ROWS 24

@protocol ScreenViewDelegate;

@interface ScreenView : UIView < UIKeyInput > {
  @private
	char _contents[ROWS][COLS];
	int _currentRow, _currentCol;
}

@property (nonatomic, copy) NSString *font;
@property (nonatomic, assign) CGSize margin;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat characterSpacing;

@property (nonatomic, weak) id < ScreenViewDelegate > delegate;

- (void)reset;

- (void)putCharacter:(char)character;

@end


@protocol ScreenViewDelegate < NSObject >

- (void)screenView:(ScreenView *)aView didReceiveChar:(char)character;

@end
