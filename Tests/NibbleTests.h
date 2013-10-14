//
//  NibbleTests.h
//  NibbleTests
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Memory.h"
#import "M6502.h"

@interface NibbleTests : XCTestCase {
  @private
	Memory *_memory;
	M6502 *_processor;
}

@end
