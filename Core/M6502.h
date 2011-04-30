//
//  M6502.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@class Memory;

@interface M6502 : NSObject {
  @private
	Memory *_memory;
	uint8_t _accum, _x, _y;
	uint8_t _c, _d, _i, _n, _v, _z;
	uint8_t _stackPtr;
	uint16_t _pc; // keeps track of the address of the current instruction
	NSTimer *_timer;
	uint16_t _cycles;
}

@property (nonatomic, readonly) uint8_t accum;
@property (nonatomic, readonly) uint8_t x;
@property (nonatomic, readonly) uint8_t y;

@property (nonatomic, readonly) uint8_t c;
@property (nonatomic, readonly) uint8_t d;
@property (nonatomic, readonly) uint8_t i;
@property (nonatomic, readonly) uint8_t n;
@property (nonatomic, readonly) uint8_t v;
@property (nonatomic, readonly) uint8_t z;

@property (nonatomic, readonly) uint8_t stackPtr;
@property (nonatomic, readonly) uint16_t pc;

- (id)initWithMemory:(Memory *)someMemory;

- (void)stop;
- (void)reset;
- (void)run;

@end
