//
//  main.m
//  NibbleTouch
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	int retVal = UIApplicationMain(argc, argv, nil, nil);
	[pool drain];
	
	return retVal;
}
