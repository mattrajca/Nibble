//
//  RootViewController.h
//  NibbleTouch
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "M6502.h"
#import "Memory.h"
#import "PIA6821.h"
#import "KeyboardView.h"
#import "ScreenView.h"

@class KeyButton;

@interface RootViewController : UIViewController < PIA6821Delegate, KeyboardViewDelegate, ScreenViewDelegate > {
  @private
	Memory *_memory;
	M6502 *_processor;
	PIA6821 *_pia;
	
	UIWindow *_externalWindow;
	ScreenView *_screenView;
}

@property (nonatomic, retain) IBOutlet KeyboardView *keyboardView;
@property (nonatomic, retain) IBOutlet KeyButton *byteShopButton;

- (IBAction)reset:(id)sender;

@end
