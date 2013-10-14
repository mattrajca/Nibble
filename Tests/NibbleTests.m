//
//  NibbleTests.m
//  NibbleTests
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "NibbleTests.h"

#import "M6502+Private.h"

@implementation NibbleTests

#define MEM_SIZE (0xFFFF)
#define ROM_LOC (0xFF00)

#define ADDR [self nextAddr]
#define CURR_ADDR [self currentAddr]

static uint16_t gAddr = 0x0;

#pragma mark -
#pragma mark OCUnit

- (void)setUp {
	[super setUp];
	
	_memory = [[Memory alloc] initWithMemorySize:MEM_SIZE];
	
	static NSData *rom = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSString *path = [[NSBundle mainBundle] pathForResource:@"apple1" ofType:@"rom"];
		rom = [NSData dataWithContentsOfFile:path];
		
		XCTAssertNotNil(rom, @"ROM should not be nil");
		XCTAssertTrue([rom length] == 256, @"ROM should be 256 bytes in size");
	});
	
	[_memory loadMemory:rom atAddress:ROM_LOC];
	
	_processor = [[M6502 alloc] initWithMemory:_memory];
}

- (void)tearDown {
	[_processor release];
	_processor = nil;
	
	[_memory release];
	_memory = nil;
}

- (uint16_t)nextAddr {
	return gAddr += 4;
}

- (uint16_t)currentAddr {
	return gAddr;
}

#pragma -
#pragma Load and Store

- (void)testLDA {
	uint8_t pos = 73;
	[_processor LDA:pos];
	
	XCTAssertTrue([_processor accum] == pos, @"positive accumulator value could not be set");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -48;
	[_processor LDA:neg];
	
	XCTAssertTrue( (int8_t) [_processor accum] == neg,
				 @"negative accumulator value could not be set");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	
	XCTAssertTrue([_processor accum] == 0, @"zero accumulator value could not be set");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testLDX {
	uint8_t pos = 112;
	[_processor LDX:pos];
	
	XCTAssertTrue([_processor x] == pos, @"positive x index could not be set");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -72;
	[_processor LDX:neg];
	
	XCTAssertTrue( (int8_t) [_processor x] == neg, @"negative x index could not be set");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDX:0];
	
	XCTAssertTrue([_processor x] == 0, @"zero x index could not be set");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testLDY {
	uint8_t pos = 21;
	[_processor LDY:pos];
	
	XCTAssertTrue([_processor y] == pos, @"positive y index could not be set");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -115;
	[_processor LDY:neg];
	
	XCTAssertTrue( (int8_t) [_processor y] == neg, @"negative y index could not be set");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDY:0];
	
	XCTAssertTrue([_processor y] == 0, @"zero y index could not be set");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testSTA {
	uint8_t pos = 57;
	[_processor LDA:pos];
	[_processor STA:ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == pos,
				 @"could not store positive accumulator value in memory");
	
	int8_t neg = -90;
	[_processor LDA:neg];
	[_processor STA:ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == neg,
				 @"could not store negative accumulator value in memory");
}

- (void)testSTX {
	int8_t neg = -22;
	[_processor LDA:neg];
	[_processor TAX];
	[_processor STX:ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == neg,
				 @"could not store negative x index in memory");
	
	uint8_t pos = 116;
	[_processor LDA:pos];
	[_processor TAX];
	[_processor STX:ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == pos,
				 @"could not store positive x index in memory");
}

- (void)testSTY {
	int8_t neg = -50;
	[_processor LDY:neg];
	[_processor STY:ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == neg,
				 @"could not store negative y index in memory");
	
	uint8_t pos = 34;
	[_processor LDY:pos];
	[_processor STY:ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == pos,
				 @"could not store positive y index in memory");
}

#pragma mark -
#pragma mark Arithmetic

- (void)testADC {
	uint8_t num1 = 40, num2 = 18;
	[_processor LDA:num1];
	[_processor ADC:num2];
	
	XCTAssertTrue([_processor accum] == (num1 + num2),
				 @"The accumulator should contain a valid sum");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	num1 = 254;
	[_processor LDA:num1];
	[_processor ADC:num2];
	
	XCTAssertTrue([_processor accum] == 16,
				 @"The accumulator should contain a valid sum");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	num1 = 120;
	[_processor LDA:num1];
	[_processor ADC:num2];
	
	XCTAssertTrue([_processor accum] == (num1 + num2) + 1, // c is 1
				 @"The accumulator should contain a valid sum");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor v] == 1, @"v should be 1");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testSBC {
	uint8_t num1 = 40, num2 = 52;
	[_processor LDA:num1];
	[_processor SBC:num1-2];
	
	XCTAssertTrue([_processor accum] == 1,
				 @"The accumulator should contain a valid difference");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:num1];
	[_processor SBC:num2];
	
	XCTAssertTrue( (int8_t) [_processor accum] == (num1 - num2),
				 @"The accumulator should contain a valid difference");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:num1];
	[_processor SBC:num1];
	
	XCTAssertTrue( (int8_t) [_processor accum] == -1,
				 @"The accumulator should contain a valid difference");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

#pragma mark -
#pragma mark Incrementing and Decrementing

- (void)testINC {
	uint8_t pos = 41;
	[_memory writeByte:pos atAddress:ADDR];
	[_processor INC:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == (pos + 1),
				 @"positive memory value could not be incremented");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -6;
	[_memory writeByte:neg atAddress:ADDR];
	[_processor INC:CURR_ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == (neg + 1),
				 @"negative memory value could not be incremented");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	uint8_t limit = 0xFF;
	[_memory writeByte:limit atAddress:ADDR];
	[_processor INC:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == 0,
				 @"limited memory value could not be incremented");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testINX {
	uint8_t pos = 81;
	[_processor LDX:pos];
	[_processor INX];
	
	XCTAssertTrue([_processor x] == (pos + 1),
				 @"positive x index could not be incremented");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -33;
	[_processor LDX:neg];
	[_processor INX];
	
	XCTAssertTrue( (int8_t) [_processor x] == (neg + 1),
				 @"negative x index could not be incremented");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	uint8_t limit = 0xFF;
	[_processor LDX:limit];
	[_processor INX];
	
	XCTAssertTrue([_processor x] == 0, @"invalid x index after incrementing past limit");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testINY {
	uint8_t pos = 19;
	[_processor LDY:pos];
	[_processor INY];
	
	XCTAssertTrue([_processor y] == (pos + 1),
				 @"positive y index could not be incremented");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -107;
	[_processor LDY:neg];
	[_processor INY];
	
	XCTAssertTrue( (int8_t) [_processor y] == (neg + 1),
				 @"negative y index could not be incremented");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	uint8_t limit = 0xFF;
	[_processor LDY:limit];
	[_processor INY];
	
	XCTAssertTrue([_processor y] == 0, @"invalid y index after incrementing past limit");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testDEC {
	uint8_t pos = 97;
	[_memory writeByte:pos atAddress:ADDR];
	[_processor DEC:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == (pos - 1),
				 @"positive memory value could not be decremented");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -39;
	[_memory writeByte:neg atAddress:ADDR];
	[_processor DEC:CURR_ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == (neg - 1),
				 @"negative memory value could not be decremented");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	uint8_t limit = 0;
	[_memory writeByte:limit atAddress:ADDR];
	[_processor DEC:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == 0xFF,
				 @"limited memory value could not be decremented");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testDEX {
	uint8_t pos = 53;
	[_processor LDX:pos];
	[_processor DEX];
	
	XCTAssertTrue([_processor x] == (pos - 1),
				 @"positive x index could not be decremented");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -96;
	[_processor LDX:neg];
	[_processor DEX];
	
	XCTAssertTrue( (int8_t) [_processor x] == (neg - 1),
				 @"negative x index could not be decremented");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDX:0];
	[_processor DEX];
	
	XCTAssertTrue([_processor x] == 0xFF,
				 @"invalid x index after decrementing past limit");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testDEY {
	uint8_t pos = 78;
	[_processor LDY:pos];
	[_processor DEY];
	
	XCTAssertTrue([_processor y] == (pos - 1),
				 @"positive y index could not be decremented");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -13;
	[_processor LDY:neg];
	[_processor DEY];
	
	XCTAssertTrue( (int8_t) [_processor y] == (neg - 1),
				 @"negative y index could not be decremented");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDY:0];
	[_processor DEY];
	
	XCTAssertTrue([_processor y] == 0xFF,
				 @"invalid y index after decrementing past limit");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

#pragma mark -
#pragma mark Shift and Rotate

- (void)testASL {
	uint8_t pos = 42;
	[_memory writeByte:pos atAddress:ADDR];
	[_processor ASL:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == pos << 1,
				 @"The memory value should be double of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -52;
	[_memory writeByte:neg atAddress:ADDR];
	[_processor ASL:CURR_ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == neg << 1,
				 @"The memory value should be double of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_memory writeByte:0 atAddress:ADDR];
	[_processor ASL:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == 0,
				 @"TThe memory value should be double of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testASL_a {
	uint8_t pos = 33;
	[_processor LDA:pos];
	[_processor ASL_a];
	
	XCTAssertTrue([_processor accum] == pos << 1,
				 @"The accumulator should contain a value double of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -20;
	[_processor LDA:neg];
	[_processor ASL_a];
	
	XCTAssertTrue( (int8_t) [_processor accum] == neg << 1,
				 @"The accumulator should contain a value double of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor ASL_a];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain a value double of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testLSR {
	uint8_t pos = 92;
	[_memory writeByte:pos atAddress:ADDR];
	[_processor LSR:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == pos >> 1,
				 @"The memory value should be a right-shifted variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -73;
	[_memory writeByte:neg atAddress:ADDR];
	[_processor LSR:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == (uint8_t) neg >> 1,
				 @"The memory value should be a right-shifted variant of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_memory writeByte:0 atAddress:ADDR];
	[_processor LSR:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == 0,
				 @"The memory value should be a right-shifted variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testLSR_a {
	uint8_t pos = 40;
	[_processor LDA:pos];
	[_processor LSR_a];
	
	XCTAssertTrue([_processor accum] == pos >> 1,
				 @"The accumulator should contain a right-shifted variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -5;
	[_processor LDA:neg];
	[_processor LSR_a];
	
	XCTAssertTrue([_processor accum] == (uint8_t) neg >> 1,
				 @"The accumulator should contain a right-shifted variant of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor LSR_a];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain a right-shifted variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testROL {
	uint8_t pos = 42;
	[_memory writeByte:pos atAddress:ADDR];
	[_processor ROL:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == pos << 1,
				 @"The memory value should be a left-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -4;
	[_memory writeByte:neg atAddress:ADDR];
	[_processor ROL:CURR_ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == neg << 1,
				 @"The memory value should be a left-rotated variant of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_memory writeByte:0 atAddress:ADDR];
	[_processor CLC];
	[_processor ROL:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == 0,
				 @"The memory value should be a left-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testROL_a {
	uint8_t pos = 36;
	[_processor LDA:pos];
	[_processor ROL_a];
	
	XCTAssertTrue([_processor accum] == pos << 1,
				 @"The accumulator should contain a left-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -57;
	[_processor LDA:neg];
	[_processor ROL_a];
	
	XCTAssertTrue( (int8_t) [_processor accum] == neg << 1,
				 @"The accumulator should contain a left-rotated variant of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor CLC];
	[_processor ROL_a];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain a left-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testROR {
	uint8_t pos = 65;
	[_memory writeByte:pos atAddress:ADDR];
	[_processor ROR:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == pos >> 1,
				 @"The memory value should be a right-rotated variant of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -12;
	[_memory writeByte:neg atAddress:ADDR];
	[_processor ROR:CURR_ADDR];
	
	XCTAssertTrue( (int8_t) [_memory readByteAtAddress:CURR_ADDR] == neg >> 1,
				 @"The memory value should be a right-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_memory writeByte:0 atAddress:ADDR];
	[_processor ROR:CURR_ADDR];
	
	XCTAssertTrue([_memory readByteAtAddress:CURR_ADDR] == 0,
				 @"The memory value should be a right-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testROR_a {
	uint8_t pos = 65;
	[_processor LDA:pos];
	[_processor ROR_a];
	
	XCTAssertTrue([_processor accum] == pos >> 1,
				 @"The accumulator should contain a right-rotated variant of the input");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -12;
	[_processor LDA:neg];
	[_processor ROR_a];
	
	XCTAssertTrue([_processor accum] == (uint8_t) neg >> 1,
				 @"The accumulator should contain a right-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor ROR_a];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain a right-rotated variant of the input");
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

#pragma mark -
#pragma mark Logic

- (void)testAND {
	uint8_t num1 = 50, num2 = 32;
	[_processor LDA:num1];
	[_processor AND:num2];
	
	XCTAssertTrue([_processor accum] == (num1 & num2),
				 @"The accumulator should contain a valid AND'ed value");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t n_num1 = -10;
	[_processor LDA:n_num1];
	[_processor AND:n_num1];
	
	XCTAssertTrue( (int8_t) [_processor accum] == (n_num1 & n_num1),
				 @"The accumulator should contain a valid AND'ed value");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor AND:num1];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain a valid AND'ed value");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testORA {
	uint8_t num1 = 42, num2 = 12;
	[_processor LDA:num1];
	[_processor ORA:num2];
	
	XCTAssertTrue([_processor accum] == (num1 | num2),
				 @"The accumulator should contain a valid OR'ed value");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t n_num1 = -36;
	[_processor LDA:n_num1];
	[_processor ORA:num2];
	
	XCTAssertTrue( (int8_t) [_processor accum] == (n_num1 | num2),
				 @"The accumulator should contain a valid OR'ed value");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor ORA:0];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain a valid OR'ed value");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testEOR {
	uint8_t num1 = 32, num2 = 20;
	[_processor LDA:num1];
	[_processor EOR:num2];
	
	XCTAssertTrue([_processor accum] == (num1 ^ num2),
				 @"The accumulator should contain a valid XOR'ed value");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t n_num1 = -32;
	[_processor LDA:n_num1];
	[_processor EOR:num2];
	
	XCTAssertTrue( (int8_t) [_processor accum] == (n_num1 ^ num2),
				 @"The accumulator should contain a valid XOR'ed value");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:num1];
	[_processor EOR:num1];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain a valid XOR'ed value");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

#pragma mark -
#pragma mark Compare and Test

- (void)testCMP {
	uint8_t pos = 220;
	[_processor LDA:pos];
	[_processor CMP:pos];
	
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
	
	[_processor LDA:pos];
	[_processor CMP:pos-20];
	
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:pos];
	[_processor CMP:pos+22];
	
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testCPX {
	uint8_t pos = 92;
	[_processor LDX:pos];
	[_processor CPX:pos];
	
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
	
	[_processor LDX:pos];
	[_processor CPX:pos-30];
	
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDX:pos];
	[_processor CPX:pos+9];
	
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testCPY {
	uint8_t pos = 66;
	[_processor LDY:pos];
	[_processor CPY:pos];
	
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
	
	[_processor LDY:pos];
	[_processor CPY:pos-21];
	
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDY:pos];
	[_processor CPY:pos+14];
	
	XCTAssertTrue([_processor c] == 0, @"c should be 0");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testBIT {
	uint8_t val1 = 220, val2 = 120;
	[_processor LDA:val1];
	[_processor BIT:val2];
	
	XCTAssertTrue([_processor v] == 1, @"v should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	val1 = 5, val2 = 0;
	[_processor LDA:val1];
	[_processor BIT:val2];
	
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
	
	val1 = 240, val2 = 220;
	[_processor LDA:val1];
	[_processor BIT:val2];
	
	XCTAssertTrue([_processor v] == 1, @"v should be 1");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

#pragma mark -
#pragma mark Branch

- (void)testBCC {
	uint8_t num = 59;
	[_processor LDA:num];
	[_processor CMP:num+2];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BCC:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since C=0");
	
	[_processor CMP:num-1];
	
	addr = [_processor pc];
	[_processor BCC:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since C=1");
}

- (void)testBCS {
	uint8_t num = 17;
	[_processor LDA:num];
	[_processor CMP:num-2];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BCS:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since C=1");
	
	[_processor CMP:num+1];
	
	addr = [_processor pc];
	[_processor BCS:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since C=0");
}

- (void)testBEQ {
	uint8_t num = 102;
	[_processor LDA:num];
	[_processor CMP:num];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BEQ:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since Z=1");
	
	[_processor CMP:num-1];
	
	addr = [_processor pc];
	[_processor BEQ:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since Z=0");
}

- (void)testBMI {
	int8_t neg = -30;
	[_processor LDA:neg];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BMI:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since N=1");
	
	uint8_t pos = 113;
	[_processor LDA:pos];
	
	addr = [_processor pc];
	[_processor BMI:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since N=0");
}

- (void)testBNE {
	uint8_t num = 21;
	[_processor LDA:num];
	[_processor CMP:num-2];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BNE:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since Z=0");
	
	[_processor CMP:num];
	
	addr = [_processor pc];
	[_processor BNE:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since Z=1");
}

- (void)testBPL {
	uint8_t num = 5;
	[_processor LDA:num];
	[_processor CMP:num-2];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BPL:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since N=0");
	
	[_processor CMP:num+1];
	
	addr = [_processor pc];
	[_processor BPL:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since N=1");
}

- (void)testBVC {
	uint8_t val1 = 220, val2 = 30;
	[_processor LDA:val1];
	[_processor BIT:val2];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BVC:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since V=0");
	
	val1 = 220, val2 = 240;
	[_processor LDA:val1];
	[_processor BIT:val2];
	
	addr = [_processor pc];
	[_processor BVC:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since V=1");
}

- (void)testBVS {
	uint8_t val1 = 12, val2 = 242;
	[_processor LDA:val1];
	[_processor BIT:val2];
	
	uint16_t addr = [_processor pc] + 8;
	[_processor BVS:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to take branch since V=1");
	
	val1 = 220, val2 = 20;
	[_processor LDA:val1];
	[_processor BIT:val2];
	
	addr = [_processor pc];
	[_processor BVS:addr];
	
	XCTAssertTrue(addr == [_processor pc], @"PC shouldn't have been touched since V=0");
}

#pragma mark -
#pragma mark Transfer

- (void)testTAX {
	uint8_t pos = 47;
	[_processor LDA:pos];
	[_processor TAX];
	
	XCTAssertTrue([_processor x] == pos,
				 @"The x register should contain the same value as the accumulator");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -20;
	[_processor LDA:neg];
	[_processor TAX];
	
	XCTAssertTrue( (int8_t) [_processor x] == neg,
				 @"The x register should contain the same value as the accumulator");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor TAX];
	
	XCTAssertTrue([_processor x] == 0,
				 @"The x register should contain the same value as the accumulator");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testTXA {
	uint8_t pos = 13;
	[_processor LDX:pos];
	[_processor TXA];
	
	XCTAssertTrue([_processor accum] == pos,
				 @"The accumulator should contain the same value as the x index");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -92;
	[_processor LDX:neg];
	[_processor TXA];
	
	XCTAssertTrue( (int8_t) [_processor accum] == neg,
				 @"The accumulator should contain the same value as the x index");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDX:0];
	[_processor TXA];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain the same value as the x index");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testTAY {
	uint8_t pos = 97;
	[_processor LDA:pos];
	[_processor TAY];
	
	XCTAssertTrue([_processor y] == pos,
				 @"The y register should contain the same value as the accumulator");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -31;
	[_processor LDA:neg];
	[_processor TAY];
	
	XCTAssertTrue( (int8_t) [_processor y] == neg,
				 @"The y register should contain the same value as the accumulator");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDA:0];
	[_processor TAY];
	
	XCTAssertTrue([_processor y] == 0,
				 @"The y register should contain the same value as the accumulator");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testTYA {
	uint8_t pos = 55;
	[_processor LDY:pos];
	[_processor TYA];
	
	XCTAssertTrue([_processor accum] == pos,
				 @"The accumulator should contain the same value as the y index");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	int8_t neg = -2;
	[_processor LDY:neg];
	[_processor TYA];
	
	XCTAssertTrue( (int8_t) [_processor accum] == neg,
				 @"The accumulator should contain the same value as the y index");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor LDY:0];
	[_processor TYA];
	
	XCTAssertTrue([_processor accum] == 0,
				 @"The accumulator should contain the same value as the y index");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
}

- (void)testTSX {
	[_processor TSX];
	
	XCTAssertTrue([_processor x] == 0xFF,
				 @"The x register should be equal to the stack pointer");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testTXS {
	uint8_t pos = 110;
	[_processor LDX:pos];
	[_processor TXS];
	
	XCTAssertTrue([_processor stackPtr] == pos,
				 @"stackPtr should be equal to the x index");
	
	int8_t neg = -92;
	[_processor LDX:neg];
	[_processor TXS];
	
	XCTAssertTrue( (int8_t) [_processor stackPtr] == neg,
				 @"stackPtr should be equal to the x index");
	
	[_processor LDX:0];
	[_processor TXS];
	
	XCTAssertTrue([_processor stackPtr] == 0,
				 @"stackPtr should be equal to the x index");
}

#pragma mark -
#pragma mark Stack

- (void)testPHAplusPLA {
	uint8_t num = 37;
	[_processor LDA:num];
	[_processor PHA];
	
	int8_t num2 = -52;
	[_processor LDA:num2];
	[_processor PHA];
	
	[_processor PLA];
	
	XCTAssertTrue(num2 == (int8_t) [_processor accum],
				 @"accumulator value couldn't be pulled from the stack");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
	
	[_processor PLA];
	
	XCTAssertTrue(num == [_processor accum],
				 @"accumulator value couldn't be pulled from the stack");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

- (void)testPHPplusPLP {
	[_processor SEC];
	[_processor SED];
	[_processor SEI];
	[_processor LDA:-20]; // sets n to 1
	[_processor PHP];
	
	[_processor LDA:0]; // sets z to 1
	[_processor PHP];
	
	[_processor CLC];
	[_processor CLD];
	[_processor CLI];
	
	[_processor PLP];
	
	XCTAssertTrue([_processor b] == 0, @"b should be 0");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor d] == 1, @"d should be 1");
	XCTAssertTrue([_processor i] == 1, @"i should be 1");
	XCTAssertTrue([_processor n] == 0, @"n should be 0");
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor z] == 1, @"z should be 1");
	
	[_processor PLP];
	
	XCTAssertTrue([_processor b] == 0, @"b should be 0");
	XCTAssertTrue([_processor c] == 1, @"c should be 1");
	XCTAssertTrue([_processor d] == 1, @"d should be 1");
	XCTAssertTrue([_processor i] == 1, @"i should be 1");
	XCTAssertTrue([_processor n] == 1, @"n should be 1");
	XCTAssertTrue([_processor v] == 0, @"v should be 0");
	XCTAssertTrue([_processor z] == 0, @"z should be 0");
}

#pragma mark -
#pragma mark Subroutines and Jump

- (void)testJMP {
	[_processor JMP:ADDR];
	
	XCTAssertTrue(CURR_ADDR == [_processor pc], @"failed to adjust PC after JMP");
}

- (void)testJSR {
	[_processor JSR:ADDR];
	
	XCTAssertTrue(CURR_ADDR == [_processor pc], @"failed to adjust PC after JSR");
}

- (void)testRTS {
	uint16_t addr = [_processor pc];
	
	[_processor JSR:ADDR];
	[_processor RTS];
	
	XCTAssertTrue(addr == [_processor pc], @"failed to adjust PC after RTS");
}

#pragma mark -
#pragma mark Set and Clear

- (void)testSEC {
	[_processor SEC];
	
	XCTAssertTrue([_processor c] == 1,
				 @"c should be 1 after setting the carry flag");
}

- (void)testSED {
	[_processor SED];
	
	XCTAssertTrue([_processor d] == 1,
				 @"d should be 1 after setting decimal arithmetic mode");
}

- (void)testSEI {
	[_processor SEI];
	
	XCTAssertTrue([_processor i] == 1,
				 @"i should be 1 after setting the interrupt disable bit");
}

- (void)testCLC {
	[_processor SEC];
	[_processor CLC];
	
	XCTAssertTrue([_processor c] == 0,
				 @"c should be 0 after clearing the carry flag");
}

- (void)testCLD {
	[_processor SED];
	[_processor CLD];
	
	XCTAssertTrue([_processor d] == 0,
				 @"d should be 0 after clearing decimal arithmetic mode");
}

- (void)testCLI {
	[_processor SEI];
	[_processor CLI];
	
	XCTAssertTrue([_processor i] == 0,
				 @"i should be 0 after clearing the interrupt disable bit");
}

- (void)testCLV {
	[_processor CLV];
	
	XCTAssertTrue([_processor v] == 0,
				 @"v should be 0 after clearing the overflow flag");
}

#pragma mark -

@end
