//
//  Memory.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

typedef void (^MemReadBlock) (uint8_t value);
typedef void (^MemWriteBlock) (uint8_t newValue);

@interface Memory : NSObject {
  @private
	uint8_t *_buffer;
	uint16_t _size;
	NSMutableDictionary *_writeWatch;
	NSMutableDictionary *_readWatch;
	BOOL _ignoreWatch;
}

- (id)initWithMemorySize:(uint16_t)size;

- (void)reset;

- (void)loadMemory:(NSData *)data atAddress:(uint16_t)addr;

- (uint8_t)readByteAtAddress:(uint16_t)addr; // triggers watches
- (uint16_t)readShortAtAddress:(uint16_t)addr;
- (uint16_t)readShortZPAtAddress:(uint16_t)addr;

- (void)writeByte:(uint8_t)value atAddress:(uint16_t)addr; // triggers watches

- (void)ignoreWatch:(void(^)())block;

- (void)watchMemoryAtAddress:(uint16_t)addr readBlock:(MemReadBlock)block;
- (void)watchMemoryAtAddress:(uint16_t)addr writeBlock:(MemWriteBlock)block;

@end
