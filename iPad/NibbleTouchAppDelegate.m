//
//  NibbleTouchAppDelegate.m
//  NibbleTouch
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "NibbleTouchAppDelegate.h"

#import "RootViewController.h"

@implementation NibbleTouchAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window.screen = [UIScreen mainScreen];
	self.window.rootViewController = self.viewController;
	
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)dealloc {
	[_window release];
	[_viewController release];
	
    [super dealloc];
}

@end
