//
//  NibbleAppDelegate.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "NibbleAppDelegate.h"

#import "MainWindowController.h"

@implementation NibbleAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	if (!_mainWC) {
		_mainWC = [[MainWindowController alloc] init];
	}
	
	[_mainWC showWindow:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
	[_mainWC loadMemoryDumpFileAtPath:filename];
	
	return YES;
}

@end
