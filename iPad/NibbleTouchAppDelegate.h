//
//  NibbleTouchAppDelegate.h
//  NibbleTouch
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@class RootViewController;

@interface NibbleTouchAppDelegate : NSObject < UIApplicationDelegate > {

}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet RootViewController *viewController;

@end
