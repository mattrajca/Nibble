//
//  UserDefaults.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

typedef void (^EmptyBlock)(void);

@interface UserDefaults : NSObject {
  @private
	EmptyBlock _changesBlock;
}

+ (UserDefaults *)sharedDefaults;

- (NSArray *)recentFiles;

- (void)resetRecentFiles;
- (void)addRecentFile:(NSString *)aPath;

- (void)observeChangesWithBlock:(EmptyBlock)block;

@end
