//
//  NibbleTouchAppDelegate.h
//  NibbleTouch
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@class RootViewController;

@interface NibbleTouchAppDelegate : NSObject < UIApplicationDelegate > {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *viewController;

@end
