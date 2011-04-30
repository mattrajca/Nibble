//
//  UserDefaults.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

static NSString *const kRecentFilesKey = @"RecentFiles";

+ (UserDefaults *)sharedDefaults {
	static UserDefaults *sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedInstance = [[UserDefaults alloc] init];
	});
	
	return sharedInstance;
}

- (NSArray *)recentFiles {
	return [[NSUserDefaults standardUserDefaults] arrayForKey:kRecentFilesKey];
}

- (void)resetRecentFiles {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:nil forKey:kRecentFilesKey];
	[defaults synchronize];
	
	if (_changesBlock) {
		[[NSOperationQueue mainQueue] addOperationWithBlock:_changesBlock];
	}
}

- (void)addRecentFile:(NSString *)aPath {
	NSMutableArray *files = [[self recentFiles] mutableCopy];
	
	if (!files) {
		files = [NSMutableArray new];
	}
	
	if (![files containsObject:aPath]) {
		[files addObject:aPath];
	}
	
	[files sortUsingComparator:^NSComparisonResult (id obj1, id obj2) {
		return [obj1 compare:obj2 options:0];
	}];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:files forKey:kRecentFilesKey];
	[defaults synchronize];
	
	if (_changesBlock) {
		[[NSOperationQueue mainQueue] addOperationWithBlock:_changesBlock];
	}
}

- (void)observeChangesWithBlock:(EmptyBlock)block {
	if (_changesBlock) {
		Block_release(_changesBlock);
		_changesBlock = NULL;
	}
	
	if (block) {
		_changesBlock = Block_copy(block);
	}
}

@end
