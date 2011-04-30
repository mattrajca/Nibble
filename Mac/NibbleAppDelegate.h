//
//  NibbleAppDelegate.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@class MainWindowController;

@interface NibbleAppDelegate : NSObject < NSApplicationDelegate > {
  @private
	MainWindowController *_mainWC;
}

@property (nonatomic, retain) IBOutlet NSMenu *recentFilesMenu;

- (IBAction)clearRecentFiles:(id)sender;

@end
