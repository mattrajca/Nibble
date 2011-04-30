//
//  NibbleAppDelegate.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "NibbleAppDelegate.h"

#import "MainWindowController.h"
#import "UserDefaults.h"

@interface NibbleAppDelegate ()

- (void)populateRecentFilesMenu;
- (void)loadFile:(id)sender;

@end


@implementation NibbleAppDelegate

@synthesize recentFilesMenu = _recentFilesMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	if (!_mainWC) {
		_mainWC = [[MainWindowController alloc] init];
	}
	
	[_mainWC showWindow:self];
	
	[[UserDefaults sharedDefaults] observeChangesWithBlock:^{
		[self populateRecentFilesMenu];
	}];
	
	[self populateRecentFilesMenu];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void)populateRecentFilesMenu {
	for (NSUInteger i = 0; i < [_recentFilesMenu numberOfItems]; i++) {
		NSMenuItem *item = [_recentFilesMenu itemAtIndex:i];
		
		if ([item tag] == 1) {
			[_recentFilesMenu removeItemAtIndex:i];
			i--;
		}
	}
	
	NSUInteger n = 0;
	NSArray *files = [[UserDefaults sharedDefaults] recentFiles];
	
	for (NSString *path in files) {
		NSString *name = [path lastPathComponent];
		
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:name
													  action:@selector(loadFile:)
											   keyEquivalent:@""];
		
		[item setRepresentedObject:path];
		[item setTag:1];
		
		[_recentFilesMenu insertItem:item atIndex:n];
		
		n++;
	}
}

- (void)loadFile:(id)sender {
	NSString *path = [sender representedObject];
	[_mainWC loadMemoryDumpFileAtPath:path];
}

- (IBAction)clearRecentFiles:(id)sender {
	[[UserDefaults sharedDefaults] resetRecentFiles];
}

@end
