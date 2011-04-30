//
//  Memory.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "Memory.h"

#define WRITE_IN_ROM 0

@implementation Memory

- (id)initWithMemorySize:(uint16_t)size {
    self = [super init];
    if (self) {
		_size = size;
		_buffer = malloc(size);
		
		[self reset];
    }
    return self;
}

- (void)finalize {
	free(_buffer);
	[super finalize];
}

- (void)dealloc {
	free(_buffer);
	
	[_writeWatch release];
	[_readWatch release];
	
    [super dealloc];
}

- (void)reset {
	bzero(_buffer, _size);
	
	if (_writeWatch)
		[_writeWatch release];
	
	if (_readWatch)
		[_readWatch release];
	
	_writeWatch = [[NSMutableDictionary alloc] init];
	_readWatch = [[NSMutableDictionary alloc] init];
}

- (void)loadMemory:(NSData *)data atAddress:(uint16_t)addr {
	memcpy(_buffer + addr, [data bytes], [data length]);
}

- (uint8_t)readByteAtAddress:(uint16_t)addr {
	uint8_t value = _buffer[addr];
	
	if (!_ignoreWatch) {
		NSNumber *key = [NSNumber numberWithUnsignedShort:addr];
		MemReadBlock block = [_readWatch objectForKey:key];
		
		if (block) {
			_ignoreWatch = YES;
			block(value);
			_ignoreWatch = NO;
		}
	}
	
	return value;
}

- (uint16_t)readShortAtAddress:(uint16_t)addr {
	return _buffer[addr] | (_buffer[addr + 1] << 8);
}

- (uint16_t)readShortZPAtAddress:(uint16_t)addr {
	return _buffer[addr] | (_buffer[(addr + 1) & 0xFF] << 8);
}

- (void)writeByte:(uint8_t)value atAddress:(uint16_t)addr {
#if !WRITE_IN_ROM
	if (addr >= 0xFF00)
		return;
#endif
	
	_buffer[addr] = value;
	
	if (_ignoreWatch)
		return;
	
	NSNumber *key = [NSNumber numberWithUnsignedShort:addr];
	MemWriteBlock block = [_writeWatch objectForKey:key];
	
	if (block) {
		_ignoreWatch = YES;
		block(value);
		_ignoreWatch = NO;
	}
}

- (void)ignoreWatch:(void(^)())block {
	_ignoreWatch = YES;
	block();
	_ignoreWatch = NO;
}

- (void)watchMemoryAtAddress:(uint16_t)addr readBlock:(MemReadBlock)block {
	[_readWatch setObject:[[block copy] autorelease]
				   forKey:[NSNumber numberWithUnsignedShort:addr]];
}

- (void)watchMemoryAtAddress:(uint16_t)addr writeBlock:(MemWriteBlock)block {
	[_writeWatch setObject:[[block copy] autorelease]
					forKey:[NSNumber numberWithUnsignedShort:addr]];
}

@end
