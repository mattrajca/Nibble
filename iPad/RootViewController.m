//
//  RootViewController.m
//  NibbleTouch
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "RootViewController.h"

#import "ByteShopViewController.h"
#import "KeyboardLayout.h"
#import "KeyButton.h"
#import "ParseDumpOperation.h"
#import "PIA6821+Additions.h"

@interface RootViewController ()

- (void)activated;
- (void)deactivated;
- (void)setupByteShopButton;

- (void)setupScreens;
- (void)setupMainScreen;
- (void)setupExternalScreen:(UIScreen *)screen;

- (void)screenDidConnect:(NSNotification *)aNotification;
- (void)screenDidDisconnect:(NSNotification *)aNotification;

- (void)setupSystem;
- (void)loadROM;

- (void)showResetSheet:(id)sender;
- (void)reset:(BOOL)hard;
- (void)presentByteShop;

@end


@implementation RootViewController

#define MEM_SIZE (0xFFFF) // 64K
#define ROM_LOC (0xFF00)

static uint16_t sLastAddr;

@synthesize byteShopButton, keyboardView;

- (void)dealloc {
	[_memory release];
	[_processor release];
	[_pia release];
	
	[_externalWindow release];
	[_screenView release];
	
	[byteShopButton release];
	[keyboardView release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark View

- (void)viewDidLoad {
	UIImage *image = [UIImage imageNamed:@"Background.png"];
	self.view.backgroundColor = [UIColor colorWithPatternImage:image];
	self.keyboardView.delegate = self;
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self
			   selector:@selector(activated)
				   name:UIApplicationDidBecomeActiveNotification
				 object:nil];
	
	[center addObserver:self
			   selector:@selector(deactivated)
				   name:UIApplicationWillResignActiveNotification
				 object:nil];
	
	[self setupByteShopButton];
	[self setupScreens];
	[self setupSystem];
}

- (void)activated {
	[_processor run];
}

- (void)deactivated {
	[_processor stop];
}

- (void)setupByteShopButton {
	self.byteShopButton.title = NSLocalizedString(@"BYTE SHOP", nil);
	
	[self.byteShopButton enableTapHandler:^(KeyButton *button, KeyButtonState state) {
		
		if (state == KeyButtonStateReleased) {
			[self presentByteShop];
		}
		
	}];
}

#pragma mark -
#pragma mark Screen Management

- (void)setupScreens {
	if (!_screenView) {
		_screenView = [[ScreenView alloc] initWithFrame:CGRectZero];
		_screenView.backgroundColor = [UIColor clearColor];
		_screenView.font = @"PrintChar21";
		_screenView.delegate = self;
	}
	
	NSArray *screens = [UIScreen screens];
	
	if ([screens count] > 1) {
		UIScreen *screen = [screens objectAtIndex:1];
		[self setupExternalScreen:screen];
	}
	else {
		[self setupMainScreen];
	}
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self selector:@selector(screenDidConnect:)
				   name:UIScreenDidConnectNotification object:nil];
	
	[center addObserver:self selector:@selector(screenDidDisconnect:)
				   name:UIScreenDidDisconnectNotification object:nil];
}

- (void)setupMainScreen {
	if (_externalWindow) {
		[_externalWindow release];
		_externalWindow = nil;
	}
	
	if (_screenView.superview) {
		[_screenView removeFromSuperview];
	}
	
	_screenView.frame = CGRectMake(36.0f, 34.0f, 696.0f, 500.0f);
	_screenView.margin = CGSizeMake(12.0f, 15.0f);
	_screenView.fontSize = 17.0f;
	_screenView.characterSpacing = 2.0f;
	
	[self.view addSubview:_screenView];
	[_screenView setNeedsDisplay];
}

- (void)setupExternalScreen:(UIScreen *)screen {
	screen.currentMode = [screen.availableModes lastObject];
	
	if (_externalWindow) {
		[_externalWindow release];
		_externalWindow = nil;
	}
	
	if (_screenView.superview) {
		[_screenView removeFromSuperview];
	}
	
	CGRect screenBounds = screen.bounds;
	
	_externalWindow = [[UIWindow alloc] initWithFrame:screenBounds];
	_externalWindow.screen = screen;
	
	if (screenBounds.size.width == 1024.0f && screenBounds.size.height == 768.0f) {
		_screenView.margin = CGSizeMake(20.0f, 32.0f);
		_screenView.fontSize = 27.0f;
		_screenView.characterSpacing = 1.0f;
	}
	
	_screenView.frame = screenBounds;
	
	[_externalWindow addSubview:_screenView];
	[_screenView setNeedsDisplay];
	
	[_externalWindow makeKeyAndVisible];
}

- (void)screenDidConnect:(NSNotification *)aNotification {
	UIScreen *screen = [aNotification object];
	[self setupExternalScreen:screen];
}

- (void)screenDidDisconnect:(NSNotification *)aNotification {
	[self setupMainScreen];
}

#pragma mark -
#pragma mark Keyboard

#define NUM_ROWS 5

- (KeyStruct)keyForIndexPath:(NSIndexPath *)path {
	KeyStruct key;
	
	if (path.section == 0) {
		key = KeyInRowOneAtIndex(path.row);
	}
	else if (path.section == 1) {
		key = KeyInRowTwoAtIndex(path.row);
	}
	else if (path.section == 2) {
		key = KeyInRowThreeAtIndex(path.row);
	}
	else if (path.section == 3) {
		key = KeyInRowFourAtIndex(path.row);
	}
	else {
		// space
		KEY("", ' ', NULL, 0)
	}
	
	return key;
}

- (NSUInteger)numberOfRowsForKeyboardView:(KeyboardView *)aView {
	return NUM_ROWS;
}

- (NSUInteger)keyboardView:(KeyboardView *)aView numberOfKeysInRow:(NSUInteger)rowIdx {
	if (rowIdx < 3) {
		return 13;
	}
	else if (rowIdx == 3) {
		return 12;
	}
	else if (rowIdx == 4) {
		return 1;
	}
	
	return 0;
}

- (void)keyboardView:(KeyboardView *)aView configureButton:(KeyButton *)button
		 atIndexPath:(NSIndexPath *)path {
	
	KeyStruct key = [self keyForIndexPath:path];
	
	if (!strcmp(key.title, "SHIFT")) {
		button.toggleMode = YES;
	}
	
	button.title = [NSString stringWithUTF8String:key.title];
	
	if (key.sTitle) {
		button.secondaryTitle = [NSString stringWithUTF8String:key.sTitle];
	}
	
	[button sizeToFit];
	
	if (path.section == 4) {
		CGRect bounds = button.bounds;
		bounds.size.width = 396.0f;
		
		button.bounds = bounds;
	}
}

- (void)keyboardView:(KeyboardView *)aView
	   didReleaseKey:(KeyButton *)button
		   indexPath:(NSIndexPath *)path {
	
	KeyStruct key = [self keyForIndexPath:path];
	
	if (!strcmp(key.title, "RESET")) {
		[self performSelector:@selector(showResetSheet:)
				   withObject:button
				   afterDelay:0.0f];
	}
	else if (keyboardView.isShiftDown) {
		if (key.sTitle == NULL)
			return;
		
		[_screenView insertText:[NSString stringWithFormat:@"%c", key.sRepChar]];
		[keyboardView untoggleShiftKey];
	}
	else if (key.repChar == 0) {
		NSLog(@"The '%s' key has not been implemented", key.title);
	}
	else {
		[_screenView insertText:[NSString stringWithFormat:@"%c", key.repChar]];
	}
}

#pragma mark -
#pragma mark System

- (void)setupSystem {	
	if (!_memory) {
		_memory = [[Memory alloc] initWithMemorySize:MEM_SIZE];
		[self loadROM];
	}
	
	if (!_pia) {
		_pia = [[PIA6821 alloc] initWithMemory:_memory];
		_pia.delegate = self;
	}
	
	if (!_processor) {
		_processor = [[M6502 alloc] initWithMemory:_memory];
	}
	
	[_processor run];
}

- (void)loadROM {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"apple1"
													 ofType:@"rom"];
	
	NSData *romData = [NSData dataWithContentsOfFile:path];
	
	[_memory loadMemory:romData atAddress:ROM_LOC];
}

- (void)PIA6821:(PIA6821 *)pia outputVideoChar:(char)character {
	[_screenView putCharacter:character];
}

- (void)screenView:(ScreenView *)aView didReceiveChar:(char)character {
	[_pia processInputChar:character];
}

#pragma mark -
#pragma mark Byte Shop

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)index {
	if (index == 0)
		return;
	
	[_pia evokeRunAtAddress:sLastAddr];
	sLastAddr = 0;
}

- (void)dumpParseOperation:(ParseDumpOperation *)operation
		 didEncounterBytes:(NSData *)bytes atAddress:(uint16_t)addr {
	
	[_memory loadMemory:bytes atAddress:addr];
}

- (void)dumpParseOperation:(ParseDumpOperation *)operation
 didFinishParseFromAddress:(uint16_t)addr {
	
	sLastAddr = addr;
	
	NSString *title = NSLocalizedString(@"Success", nil);
	NSString *message = NSLocalizedString(@"Loaded program at address: 0x%X", nil);
	NSString *cancelButton = NSLocalizedString(@"OK", nil);
	NSString *runButton = NSLocalizedString(@"Run", nil);
	
	NSString *content = [NSString stringWithFormat:message, addr];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:content
												   delegate:self
										  cancelButtonTitle:cancelButton
										  otherButtonTitles:runButton, nil];
	
	[alert show];
	[alert release];
}

- (void)byteShopViewController:(ByteShopViewController *)vc didLoadData:(NSData *)data {
	ParseDumpOperation *operation = [[ParseDumpOperation alloc] initWithData:data];
	operation.delegate = self;
	
	[[NSOperationQueue mainQueue] addOperation:operation];
	[operation release];
}

#pragma mark -
#pragma mark Actions

- (void)showResetSheet:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
													   delegate:self
											  cancelButtonTitle:nil
										 destructiveButtonTitle:nil
											  otherButtonTitles:@"Reset", @"Hard Reset", nil];
	
	[sheet showFromRect:[sender frame] inView:self.keyboardView animated:YES];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == -1)
		return;
	
	[self reset:(buttonIndex != 0)];
}

- (void)reset:(BOOL)hard {
	[_processor stop];
	
	if (hard)
		[_memory reset];
	
	[_pia reset];
	[_screenView reset];
	
	if (hard)
		[self loadROM];
	
	[_processor reset];
	[_processor run];
}

- (void)presentByteShop {
	ByteShopViewController *vc = [[ByteShopViewController alloc] init];
	vc.delegate = self;
	
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:vc];
	controller.navigationBar.tintColor = [UIColor darkGrayColor];
	controller.modalPresentationStyle = UIModalPresentationFormSheet;
	
	[vc release];
	
	[self presentViewController:controller animated:YES completion:NULL];
	[controller release];
}

#pragma mark -

@end
