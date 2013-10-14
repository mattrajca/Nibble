//
//  ArchiveDumpOperation.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ArchiveDumpOperation.h"

#import "Memory.h"

@implementation ArchiveDumpOperation

- (id)initWithMemory:(Memory *)memory
				path:(NSURL *)aPath
		 fromAddress:(uint16_t)fromAddr
		   toAddress:(uint16_t)toAddr {
	
	NSParameterAssert(memory != nil);
	NSParameterAssert(aPath != nil);
	
	self = [super init];
	if (self) {
		_memory = memory;
		_path = [aPath copy];
		_fromAddr = fromAddr;
		_toAddr = toAddr;
	}
	return self;
}

- (void)main {
	@autoreleasepool {
	
		NSMutableString *string = [[NSMutableString alloc] init];
		
		for (uint32_t addr = _fromAddr; addr <= _toAddr; addr++) {
			if ((addr - _fromAddr) % 8 == 0) {
				[string appendFormat:@"\n%04X: ", addr];
			}
			
			uint8_t byte = [_memory readByteAtAddress:addr];
			[string appendFormat:@"%02X ", byte];
		}
		
		NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
		[data writeToURL:_path atomically:YES];
	
	}
}

@end
