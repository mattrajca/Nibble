//
//  M6502.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "M6502.h"

#import "M6502+Private.h"
#import "Memory.h"

@interface M6502 ()

- (void)processOpCode;

- (void)setNZAccordingly:(uint8_t)val;
- (void)pushByteToStack:(uint8_t)byte;
- (void)pushShortToStack:(uint16_t)val;
- (uint8_t)popByteFromStack;
- (uint16_t)popShortFromStack;

- (void)executeImpliedOp:(void(^)())block;
- (void)executeImmediateOp:(void(^)(uint8_t val))block;
- (void)executeRelativeOp:(void(^)(uint16_t addr))block;

- (void)executeZeroPageOp:(void(^)(uint8_t addr))block;
- (void)executeZeroPageXOp:(void(^)(uint8_t addr))block;
- (void)executeZeroPageYOp:(void(^)(uint8_t addr))block;
- (void)executeZeroPageIndXOp:(void(^)(uint16_t addr))block;
- (void)executeZeroPageIndYOp:(void(^)(uint16_t addr))block;

- (void)executeAbsoluteOp:(void(^)(uint16_t addr))block;
- (void)executeAbsoluteXOp:(void(^)(uint16_t addr))block;
- (void)executeAbsoluteYOp:(void(^)(uint16_t addr))block;

@end


@implementation M6502

#define STACK_LOC (0x100 + _stackPtr)
#define MEM_VAL(addr) [_memory readByteAtAddress:(addr)]

#define SPEED 200000 // nanoseconds

@synthesize accum = _accum;
@synthesize x = _x;
@synthesize y = _y;

@synthesize b = _b;
@synthesize c = _c;
@synthesize d = _d;
@synthesize i = _i;
@synthesize n = _n;
@synthesize v = _v;
@synthesize z = _z;

@synthesize stackPtr = _stackPtr;
@synthesize pc = _pc;

#pragma mark -
#pragma mark Initialization

- (id)initWithMemory:(Memory *)someMemory {
	NSParameterAssert(someMemory != nil);
	
	self = [super init];
	if (self) {
		_memory = [someMemory retain];
		[self reset];
	}
	return self;
}

- (void)dealloc {
	[_memory release];
	
	if (_timer) {
		dispatch_source_cancel(_timer);
		dispatch_release(_timer);
	}
	
	if (_queue) {
		dispatch_release(_queue);
	}
	
	[super dealloc];
}

#pragma mark -
#pragma mark Processing

- (void)stop {
	if (_timer) {
		dispatch_source_cancel(_timer);
		dispatch_release(_timer);
		_timer = NULL;
	}
}

- (void)reset {
	if (_timer) {
#ifdef DEBUG
		NSLog(@"M6502 shouldn't be reset while running");
#endif
		return;
	}
	
	// The Apple I starts executing code at the 16-bit address specified
	// by 0xFFFC-0xFFFD in the Monitor ROM
	_pc = [_memory readShortAtAddress:0xFFFC];
	_stackPtr = 0xFF;
	
	_accum = _x = _y = 0;
	_b = _c = _d = _i = _n = _v = _z = 0;
	_cycles = 0;
}

- (void)run {
	if (_timer)
		return;
	
	if (!_queue) {
		_queue = dispatch_queue_create("timer", 0);
	}
	
	_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
	dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, SPEED, 10);
	
	dispatch_source_set_event_handler(_timer, ^{
		[self processOpCode];
	});
	
	dispatch_resume(_timer);
}

- (void)processOpCode {
	if (_cycles) {
		_cycles--;
		return;
	}
	
	// move to the following address at the next iteration
	uint8_t op = [_memory readByteAtAddress:_pc++];
	
	switch (op) {
		case 0x01:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self ORA:MEM_VAL(addr)];
			}];
			break;
		case 0x05:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self ORA:MEM_VAL(addr)];
			}];
			break;
		case 0x06:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self ASL:addr];
			}];
			break;
		case 0x08:
			[self executeImpliedOp:^{
				[self PHP];
			}];
			break;
		case 0x09:
			[self executeImmediateOp:^(uint8_t val) {
				[self ORA:val];
			}];
			break;
		case 0x0A:
			[self executeImpliedOp:^{
				[self ASL_a];
			}];
			break;
		case 0x0D:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self ORA:MEM_VAL(addr)];
			}];
			break;
		case 0x0E:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self ASL:addr];
			}];
			break;
		case 0x10:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BPL:addr];
			}];
			break;
		case 0x11:
			[self executeZeroPageIndYOp:^(uint16_t addr) {
				[self ORA:MEM_VAL(addr)];
			}];
			break;
		case 0x15:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self ORA:MEM_VAL(addr)];
			}];
			break;
		case 0x16:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self ASL:addr];
			}];
			break;
		case 0x18:
			[self executeImpliedOp:^{
				[self CLC];
			}];
			break;
		case 0x19:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self ORA:MEM_VAL(addr)];
			}];
			break;
		case 0x1D:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self ORA:MEM_VAL(addr)];
			}];
			break;
		case 0x1E:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self ASL:addr];
			}];
			break;
		case 0x20:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self JSR:addr];
			}];
			break;
		case 0x21:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self AND:MEM_VAL(addr)];
			}];
			break;
		case 0x24:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self BIT:MEM_VAL(addr)];
			}];
			break;
		case 0x25:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self AND:MEM_VAL(addr)];
			}];
			break;
		case 0x26:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self ROL:addr];
			}];
			break;
		case 0x28:
			[self executeImpliedOp:^{
				[self PLP];
			}];
			break;
		case 0x29:
			[self executeImmediateOp:^(uint8_t val) {
				[self AND:val];
			}];
			break;
		case 0x2A:
			[self executeImpliedOp:^{
				[self ROL_a];
			}];
			break;
		case 0x2C:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self BIT:MEM_VAL(addr)];
			}];
			break;
		case 0x2D:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self AND:MEM_VAL(addr)];
			}];
			break;
		case 0x2E:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self ROL:addr];
			}];
			break;
		case 0x30:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BMI:addr];
			}];
			break;
		case 0x31:
			[self executeZeroPageIndYOp:^(uint16_t addr) {
				[self AND:MEM_VAL(addr)];
			}];
			break;
		case 0x35:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self AND:MEM_VAL(addr)];
			}];
			break;
		case 0x36:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self ROL:addr];
			}];
			break;
		case 0x38:
			[self executeImpliedOp:^{
				[self SEC];
			}];
			break;
		case 0x39:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self AND:MEM_VAL(addr)];
			}];
			break;
		case 0x3D:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self AND:MEM_VAL(addr)];
			}];
			break;
		case 0x3E:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self ROL:addr];
			}];
			break;
		case 0x41:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self EOR:MEM_VAL(addr)];
			}];
			break;
		case 0x45:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self EOR:MEM_VAL(addr)];
			}];
			break;
		case 0x46:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self LSR:addr];
			}];
			break;
		case 0x48:
			[self executeImpliedOp:^{
				[self PHA];
			}];
			break;
		case 0x49:
			[self executeImmediateOp:^(uint8_t val) {
				[self EOR:val];
			}];
			break;
		case 0x4A:
			[self executeImpliedOp:^{
				[self LSR_a];
			}];
			break;
		case 0x4C:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self JMP:addr];
			}];
			break;
		case 0x4D:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self EOR:MEM_VAL(addr)];
			}];
			break;
		case 0x4E:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self LSR:addr];
			}];
			break;
		case 0x50:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BVC:addr];
			}];
			break;
		case 0x51:
			[self executeZeroPageIndYOp:^(uint16_t addr) {
				[self EOR:MEM_VAL(addr)];
			}];
			break;
		case 0x55:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self EOR:MEM_VAL(addr)];
			}];
			break;
		case 0x56:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self LSR:addr];
			}];
			break;
		case 0x58:
			[self executeImpliedOp:^{
				[self CLI];
			}];
			break;
		case 0x59:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self EOR:MEM_VAL(addr)];
			}];
			break;
		case 0x5D:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self EOR:MEM_VAL(addr)];
			}];
			break;
		case 0x5E:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self LSR:addr];
			}];
			break;
		case 0x60:
			[self executeImpliedOp:^{
				[self RTS];
			}];
			break;
		case 0x61:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self ADC:MEM_VAL(addr)];
			}];
			break;
		case 0x65:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self ADC:MEM_VAL(addr)];
			}];
			break;
		case 0x66:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self ROR:addr];
			}];
			break;
		case 0x68:
			[self executeImpliedOp:^{
				[self PLA];
			}];
			break;
		case 0x69:
			[self executeImmediateOp:^(uint8_t val) {
				[self ADC:val];
			}];
			break;
		case 0x6A:
			[self executeImpliedOp:^{
				[self ROR_a];
			}];
			break;
		case 0x6C:
			[self executeAbsoluteOp:^(uint16_t addr) {
				uint16_t oaddr = [_memory readShortAtAddress:addr];
				_cycles += 2;
				
				[self JMP:oaddr];
			}];
			break;
		case 0x6D:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self ADC:MEM_VAL(addr)];
			}];
			break;
		case 0x6E:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self ROR:addr];
			}];
			break;
		case 0x70:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BVS:addr];
			}];
			break;
		case 0x71:
			[self executeZeroPageIndYOp:^(uint16_t addr) {
				[self ADC:MEM_VAL(addr)];
			}];
			break;
		case 0x75:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self ADC:MEM_VAL(addr)];
			}];
			break;
		case 0x76:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self ROR:addr];
			}];
			break;
		case 0x78:
			[self executeImpliedOp:^{
				[self SEI];
			}];
			break;
		case 0x79:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self ADC:MEM_VAL(addr)];
			}];
			break;
		case 0x7C:
			[self executeAbsoluteOp:^(uint16_t addr) {
				// absolute indexed indirect mode
				uint16_t oaddr = [_memory readShortAtAddress:addr+_x];
				_cycles += 2;
				
				[self JMP:oaddr];
			}];
			break;
		case 0x7D:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self ADC:MEM_VAL(addr)];
			}];
			break;
		case 0x7E:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self ROR:addr];
			}];
			break;
		case 0x81:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self STA:addr];
			}];
			break;
		case 0x84:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self STY:addr];
			}];
			break;
		case 0x85:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self STA:addr];
			}];
			break;
		case 0x86:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self STX:addr];
			}];
			break;
		case 0x88:
			[self executeImpliedOp:^{
				[self DEY];
			}];
			break;
		case 0x89:
			[self executeImmediateOp:^(uint8_t val) {
				[self BIT:val];
			}];
			break;
		case 0x8A:
			[self executeImpliedOp:^{
				[self TXA];
			}];
			break;
		case 0x8C:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self STY:addr];
			}];
			break;
		case 0x8D:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self STA:addr];
			}];
			break;
		case 0x8E:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self STX:addr];
			}];
			break;
		case 0x90:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BCC:addr];
			}];
			break;
		case 0x91:
			[self executeZeroPageOp:^(uint8_t addr) {
				uint16_t oaddr = [_memory readShortZPAtAddress:addr] + _y;
				[self STA:oaddr];
			}];
			break;
		case 0x94:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self STY:addr];
			}];
			break;
		case 0x95:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self STA:addr];
			}];
			break;
		case 0x96:
			[self executeZeroPageYOp:^(uint8_t addr) {
				[self STX:addr];
			}];
			break;
		case 0x98:
			[self executeImpliedOp:^{
				[self TYA];
			}];
			break;
		case 0x99:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self STA:addr];
			}];
			break;
		case 0x9A:
			[self executeImpliedOp:^{
				[self TXS];
			}];
			break;
		case 0x9D:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self STA:addr];
			}];
			break;
		case 0xA0:
			[self executeImmediateOp:^(uint8_t val) {
				[self LDY:val];
			}];
			break;
		case 0xA1:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self LDA:MEM_VAL(addr)];
			}];
			break;
		case 0xA2:
			[self executeImmediateOp:^(uint8_t val) {
				[self LDX:val];
			}];
			break;
		case 0xA4:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self LDY:MEM_VAL(addr)];
			}];
			break;
		case 0xA5:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self LDA:MEM_VAL(addr)];
			}];
			break;
		case 0xA6:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self LDX:MEM_VAL(addr)];
			}];
			break;
		case 0xA8:
			[self executeImpliedOp:^{
				[self TAY];
			}];
			break;
		case 0xA9:
			[self executeImmediateOp:^(uint8_t val) {
				[self LDA:val];
			}];
			break;
		case 0xAA:
			[self executeImpliedOp:^{
				[self TAX];
			}];
			break;
		case 0xAC:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self LDY:MEM_VAL(addr)];
			}];
			break;
		case 0xAD:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self LDA:MEM_VAL(addr)];
			}];
			break;
		case 0xAE:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self LDX:MEM_VAL(addr)];
			}];
			break;
		case 0xB0:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BCS:addr];
			}];
			break;
		case 0xB1:
			[self executeZeroPageIndYOp:^(uint16_t addr) {
				[self LDA:MEM_VAL(addr)];
			}];
			break;
		case 0xB4:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self LDY:MEM_VAL(addr)];
			}];
			break;
		case 0xB5:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self LDA:MEM_VAL(addr)];
			}];
			break;
		case 0xB6:
			[self executeZeroPageYOp:^(uint8_t addr) {
				[self LDX:MEM_VAL(addr)];
			}];
			break;
		case 0xB8:
			[self executeImpliedOp:^{
				[self CLV];
			}];
			break;
		case 0xB9:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self LDA:MEM_VAL(addr)];
			}];
			break;
		case 0xBA:
			[self executeImpliedOp:^{
				[self TSX];
			}];
			break;
		case 0xBC:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self LDY:MEM_VAL(addr)];
			}];
			break;
		case 0xBD:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self LDA:MEM_VAL(addr)];
			}];
			break;
		case 0xBE:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self LDX:MEM_VAL(addr)];
			}];
			break;
		case 0xC0:
			[self executeImmediateOp:^(uint8_t val) {
				[self CPY:val];
			}];
			break;
		case 0xC1:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self CMP:MEM_VAL(addr)];
			}];
			break;
		case 0xC4:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self CPY:MEM_VAL(addr)];
			}];
			break;
		case 0xC5:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self CMP:MEM_VAL(addr)];
			}];
			break;
		case 0xC6:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self DEC:addr];
			}];
			break;
		case 0xC8:
			[self executeImpliedOp:^{
				[self INY];
			}];
			break;
		case 0xC9:
			[self executeImmediateOp:^(uint8_t val) {
				[self CMP:val];
			}];
			break;
		case 0xCA:
			[self executeImpliedOp:^{
				[self DEX];
			}];
			break;
		case 0xCC:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self CPY:MEM_VAL(addr)];
			}];
			break;
		case 0xCD:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self CMP:MEM_VAL(addr)];
			}];
			break;
		case 0xCE:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self DEC:addr];
			}];
			break;
		case 0xD0:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BNE:addr];
			}];
			break;
		case 0xD1:
			[self executeZeroPageIndYOp:^(uint16_t addr) {
				[self CMP:MEM_VAL(addr)];
			}];
			break;
		case 0xD5:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self CMP:MEM_VAL(addr)];
			}];
			break;
		case 0xD6:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self DEC:addr];
			}];
			break;
		case 0xD8:
			[self executeImpliedOp:^{
				[self CLD];
			}];
			break;
		case 0xD9:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self CMP:MEM_VAL(addr)];
			}];
			break;
		case 0xDD:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self CMP:MEM_VAL(addr)];
			}];
			break;
		case 0xDE:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self DEC:addr];
			}];
			break;
		case 0xE0:
			[self executeImmediateOp:^(uint8_t val) {
				[self CPX:val];
			}];
			break;
		case 0xE1:
			[self executeZeroPageIndXOp:^(uint16_t addr) {
				[self SBC:MEM_VAL(addr)];
			}];
			break;
		case 0xE4:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self CPX:MEM_VAL(addr)];
			}];
			break;
		case 0xE5:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self SBC:MEM_VAL(addr)];
			}];
			break;
		case 0xE6:
			[self executeZeroPageOp:^(uint8_t addr) {
				[self INC:addr];
			}];
			break;
		case 0xE8:
			[self executeImpliedOp:^{
				[self INX];
			}];
			break;
		case 0xE9:
			[self executeImmediateOp:^(uint8_t val) {
				[self SBC:val];
			}];
			break;
		case 0xEA:
			[self executeImpliedOp:^{
				[self NOP];
			}];
			break;
		case 0xEC:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self CPX:MEM_VAL(addr)];
			}];
			break;
		case 0xED:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self SBC:MEM_VAL(addr)];
			}];
			break;
		case 0xEE:
			[self executeAbsoluteOp:^(uint16_t addr) {
				[self INC:addr];
			}];
			break;
		case 0xF0:
			[self executeRelativeOp:^(uint16_t addr) {
				[self BEQ:addr];
			}];
			break;
		case 0xF1:
			[self executeZeroPageIndYOp:^(uint16_t addr) {
				[self SBC:MEM_VAL(addr)];
			}];
			break;
		case 0xF5:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self SBC:MEM_VAL(addr)];
			}];
			break;
		case 0xF6:
			[self executeZeroPageXOp:^(uint8_t addr) {
				[self INC:addr];
			}];
			break;
		case 0xF8:
			[self executeImpliedOp:^{
				[self SED];
			}];
			break;
		case 0xF9:
			[self executeAbsoluteYOp:^(uint16_t addr) {
				[self SBC:MEM_VAL(addr)];
			}];
			break;
		case 0xFD:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self SBC:MEM_VAL(addr)];
			}];
			break;
		case 0xFE:
			[self executeAbsoluteXOp:^(uint16_t addr) {
				[self INC:addr];
			}];
			break;
		default:
			NSLog(@"Unknown code: 0x%X", op);
			break;
	}
}

#pragma mark -
#pragma mark Utility

- (void)setNZAccordingly:(uint8_t)val {
	_n = (val & 0x80) != 0;
	_z = val == 0;
}

- (void)pushByteToStack:(uint8_t)byte {
	[_memory writeByte:byte atAddress:STACK_LOC];
	_stackPtr = (_stackPtr - 1) & 0xFF;
}

- (void)pushShortToStack:(uint16_t)val {
	[_memory writeByte:(val >> 8) & 0xFF atAddress:STACK_LOC];
	_stackPtr = (_stackPtr - 1) & 0xFF;
	
	[_memory writeByte:(val & 0xFF) atAddress:STACK_LOC];
	_stackPtr = (_stackPtr - 1) & 0xFF;
}

- (uint8_t)popByteFromStack {
	_stackPtr = (_stackPtr + 1) & 0xFF;
	
	uint8_t byte = [_memory readByteAtAddress:STACK_LOC];
	[_memory writeByte:0x0 atAddress:STACK_LOC];
	
	return byte;
}

- (uint16_t)popShortFromStack {
	_stackPtr = (_stackPtr + 1) & 0xFF;
	
	uint16_t res = [_memory readByteAtAddress:STACK_LOC];
	[_memory writeByte:0x0 atAddress:STACK_LOC];
	
	_stackPtr = (_stackPtr + 1) & 0xFF;
	
	res += [_memory readByteAtAddress:STACK_LOC] << 8;
	[_memory writeByte:0x0 atAddress:STACK_LOC];
	
	return res;
}

#pragma mark -
#pragma mark Addressing Modes

- (void)executeImpliedOp:(void(^)())block {
	block();
	_cycles++;
}

- (void)executeImmediateOp:(void(^)(uint8_t val))block {
	uint8_t val = [_memory readByteAtAddress:_pc++];
	block(val);
}

- (void)executeRelativeOp:(void (^)(uint16_t addr))block {
	int8_t addr = (int8_t) [_memory readByteAtAddress:_pc++];
	
	block( (_pc+addr) & 0xFFFF);
	_cycles++;
}

- (void)executeZeroPageOp:(void(^)(uint8_t addr))block {
	uint8_t addr = [_memory readByteAtAddress:_pc++];
	
	block(addr);
	_cycles++;
}

- (void)executeZeroPageXOp:(void(^)(uint8_t addr))block {
	uint8_t addr = [_memory readByteAtAddress:_pc++];
	
	block( (addr+_x) & 0xFF);
	_cycles += 2;
}

- (void)executeZeroPageYOp:(void(^)(uint8_t addr))block {
	uint8_t addr = [_memory readByteAtAddress:_pc++];
	
	block( (addr+_y) & 0xFF);
	_cycles += 2;
}

- (void)executeZeroPageIndXOp:(void(^)(uint16_t addr))block {
	uint8_t addr = [_memory readByteAtAddress:_pc++];
	uint16_t oaddr = [_memory readShortZPAtAddress:addr+_x];
	
	block(oaddr);
	_cycles += 4;
}

- (void)executeZeroPageIndYOp:(void(^)(uint16_t addr))block {
	uint8_t addr = [_memory readByteAtAddress:_pc++];
	uint16_t oaddr = [_memory readShortAtAddress:addr];
	
	block(oaddr+_y);
	_cycles += 4;
}

- (void)executeAbsoluteOp:(void(^)(uint16_t addr))block {
	uint16_t addr = [_memory readShortAtAddress:_pc];
	_pc += 2;
	_cycles += 2;
	
	block(addr);
}

- (void)executeAbsoluteXOp:(void(^)(uint16_t addr))block {
	uint16_t addr = [_memory readShortAtAddress:_pc];
	_pc += 2;
	_cycles += 3;
	
	block( (addr+_x) & 0xFFFF);
}

- (void)executeAbsoluteYOp:(void(^)(uint16_t addr))block {
	uint16_t addr = [_memory readShortAtAddress:_pc];
	_pc += 2;
	_cycles += 3;
	
	block( (addr+_y) & 0xFFFF);
}

#pragma mark -
#pragma mark Load and Store

- (void)LDA:(uint8_t)val {
	_accum = val;
	_cycles++;
	
	[self setNZAccordingly:_accum];
}

- (void)LDX:(uint8_t)val {
	_x = val;
	_cycles++;
	
	[self setNZAccordingly:_x];
}

- (void)LDY:(uint8_t)val {
	_y = val;
	_cycles++;
	
	[self setNZAccordingly:_y];
}

- (void)STA:(uint16_t)addr {
	[_memory writeByte:_accum atAddress:addr];
	_cycles++;
}

- (void)STX:(uint16_t)addr {
	[_memory writeByte:_x atAddress:addr];
	_cycles++;
}

- (void)STY:(uint16_t)addr {
	[_memory writeByte:_y atAddress:addr];
	_cycles++;
}

#pragma mark -
#pragma mark Arithmetic

- (void)ADC:(uint8_t)val {
	uint8_t prevAccum = _accum;
	
	if (_d) {
		_z = !((prevAccum + val + (_c ? 1 : 0)) & 0xFF);
		
		uint16_t tmp = (prevAccum & 0x0F) + (val & 0x0F) + (_c ? 1 : 0);
		_accum = tmp < 0x0A ? tmp : tmp + 6;
		tmp = (prevAccum & 0xF0) + (val & 0xF0) + (tmp & 0xF0);
		
		_n = tmp & 0x80;
		_v = (prevAccum ^ tmp) & ~(prevAccum ^ val) & 0x80;
		
		tmp = (_accum & 0x0F) | (tmp < 0xA0 ? tmp : tmp + 0x60);
		
		_c = tmp >= 0x100;
		_accum = tmp & 0xFF;
	}
	else {
		uint16_t res = _accum + val + _c;
		_accum = res & 0xFF;
		_c = (res & 0x100) != 0;
		_v = ((prevAccum ^ _accum) & ~(prevAccum ^ val) & 0x80) != 0;
		
		[self setNZAccordingly:_accum];
	}
	
	_cycles++;
}

- (void)SBC:(uint8_t)val {
	uint8_t prevAccum = _accum;
	
	if (_d) {
		uint16_t tmp = (prevAccum & 0x0F) - (val & 0x0F) - (_c ? 0 : 1);
		_accum = !(tmp & 0x10) ? tmp : tmp - 6;
		tmp = (prevAccum & 0xF0) - (val & 0xF0) - (_accum & 0x10);
		_accum = (_accum & 0x0F) | (!(tmp & 0x100) ? tmp : tmp - 0x60);
		tmp = prevAccum - val - (_c ? 0 : 1);
		_c = (tmp & 0x100) == 0;
		
		[self setNZAccordingly:tmp & 0xFF];
	}
	else {
		uint16_t res = _accum - val - (_c ? 0 : 1);
		_accum = res & 0xFF;
		_c = (res & 0x100) == 0;
		_v = ((prevAccum ^ val) & (prevAccum ^ _accum) & 0x80) != 0;
		
		[self setNZAccordingly:_accum];
	}
	
	_cycles++;
}

#pragma mark -
#pragma mark Increment and Decrement

- (void)INC:(uint16_t)addr {
	uint8_t val = (MEM_VAL(addr) + 1) & 0xFF;
	_cycles += 3;
	
	[self setNZAccordingly:val];
	[_memory writeByte:val atAddress:addr];
}

- (void)INX {
	_x = (_x + 1) & 0xFF;
	[self setNZAccordingly:_x];
}

- (void)INY {
	_y = (_y + 1) & 0xFF;
	[self setNZAccordingly:_y];
}

- (void)DEC:(uint16_t)addr {
	uint8_t val = (MEM_VAL(addr) - 1) & 0xFF;
	_cycles += 3;
	
	[self setNZAccordingly:val];
	[_memory writeByte:val atAddress:addr];
}

- (void)DEX {
	_x = (_x - 1) & 0xFF;
	[self setNZAccordingly:_x];
}

- (void)DEY {
	_y = (_y - 1) & 0xFF;
	[self setNZAccordingly:_y];
}

#pragma mark -
#pragma mark Shift and Rotate

- (void)ASL:(uint16_t)addr {
	uint16_t val = MEM_VAL(addr) << 1;
	uint8_t byte = val & 0xFF;
	_c = (val & 0x100) != 0;
	_cycles += 3;
	
	[self setNZAccordingly:byte];
	[_memory writeByte:byte atAddress:addr];
}

- (void)ASL_a {
	uint16_t val = _accum << 1;
	_accum = val & 0xFF;
	_c = (val & 0x100) != 0;
	
	[self setNZAccordingly:_accum];
}

- (void)LSR:(uint16_t)addr {
	uint8_t val = MEM_VAL(addr);
	uint8_t byte = (val >> 1) & 0xFF;
	_c = (val & 0x1) != 0;
	_cycles += 3;
	
	[self setNZAccordingly:byte];
	[_memory writeByte:byte atAddress:addr];
}

- (void)LSR_a {
	_c = (_accum & 0x1) != 0;
	_accum = (_accum >> 1) & 0xFF;
	
	[self setNZAccordingly:_accum];
}

- (void)ROL:(uint16_t)addr {
	uint8_t val = MEM_VAL(addr);
	uint8_t nc = (val & 0x80) != 0;
	val = (val << 1) | _c;
	_c = nc;
	_cycles += 3;
	
	[self setNZAccordingly:val];
	[_memory writeByte:val atAddress:addr];
}

- (void)ROL_a {
	uint16_t val = (_accum << 1) | _c;
	_accum = val & 0xFF;
	_c = (val & 0x100) != 0;
	
	[self setNZAccordingly:_accum];
}

- (void)ROR:(uint16_t)addr {
	uint8_t val = MEM_VAL(addr);
	uint8_t nc = val & 0x1;
	val = (val >> 1) | (_c ? 0x80 : 0);
	_c = nc;
	_cycles += 3;
	
	[self setNZAccordingly:val];
	[_memory writeByte:val atAddress:addr];
}

- (void)ROR_a {
	uint8_t val = _accum | (_c ? 0x100 : 0);
	_c = (_accum & 0x1) != 0;
	_accum = val >> 1;
	
	[self setNZAccordingly:_accum];
}

#pragma mark -
#pragma mark Logic

- (void)AND:(uint8_t)val {
	_accum &= val;
	_cycles++;
	
	[self setNZAccordingly:_accum];
}

- (void)ORA:(uint8_t)val {
	_accum |= val;
	_cycles++;
	
	[self setNZAccordingly:_accum];
}

- (void)EOR:(uint8_t)val {
	_accum ^= val;
	_cycles++;
	
	[self setNZAccordingly:_accum];
}

#pragma mark -
#pragma mark Compare and Test

- (void)CMP:(uint8_t)val {
	uint16_t res = (_accum - val);
	_c = (res & 0x100) == 0;
	_cycles++;
	
	[self setNZAccordingly:res & 0xFF];
}

- (void)CPX:(uint8_t)val {
	uint16_t res = (_x - val);
	_c = (res & 0x100) == 0;
	_cycles++;
	
	[self setNZAccordingly:res & 0xFF];
}

- (void)CPY:(uint8_t)val {
	uint16_t res = (_y - val);
	_c = (res & 0x100) == 0;
	_cycles++;
	
	[self setNZAccordingly:res & 0xFF];
}

- (void)BIT:(uint8_t)val {
	_v = (val & 0x40) != 0;
	_n = (val & 0x80) != 0;
	_z = (val & _accum) == 0;
	_cycles++;
}

#pragma mark -
#pragma mark Branch

#define BRANCH(c)\
	if ((c)) {\
		_cycles++;\
		if ((_pc & 0xFF00) != (addr & 0xFF00))\
			_cycles++;\
		_pc = addr;\
	}

- (void)BCC:(uint16_t)addr {
	BRANCH(_c == 0)
}

- (void)BCS:(uint16_t)addr {
	BRANCH(_c == 1)
}

- (void)BEQ:(uint16_t)addr {
	BRANCH(_z == 1)
}

- (void)BMI:(uint16_t)addr {
	BRANCH(_n == 1)
}

- (void)BNE:(uint16_t)addr {
	BRANCH(_z == 0)
}

- (void)BPL:(uint16_t)addr {
	BRANCH(_n == 0)
}

- (void)BVC:(uint16_t)addr {
	BRANCH(_v == 0)
}

- (void)BVS:(uint16_t)addr {
	BRANCH(_v == 1)
}

#pragma mark -
#pragma mark Transfer

- (void)TAX {
	_x = _accum;
	[self setNZAccordingly:_x];
}

- (void)TXA {
	_accum = _x;
	[self setNZAccordingly:_accum];
}

- (void)TAY {
	_y = _accum;
	[self setNZAccordingly:_y];
}

- (void)TYA {
	_accum = _y;
	[self setNZAccordingly:_accum];
}

- (void)TSX {
	_x = _stackPtr;
	[self setNZAccordingly:_x];
}

- (void)TXS {
	_stackPtr = _x;
}

#pragma mark -
#pragma mark Stack

- (void)PHA {
	_cycles++;
	[self pushByteToStack:_accum];
}

- (void)PLA {
	_accum = [self popByteFromStack];
	_cycles += 2;
	[self setNZAccordingly:_accum];
}

#define SB (1 << 0)
#define SC (1 << 1)
#define SD (1 << 2)
#define SI (1 << 3)
#define SN (1 << 4)
#define SV (1 << 5)
#define SZ (1 << 6)

- (void)PHP {
	uint8_t status = 0;
	
	if (_b) status |= SB;
	if (_c) status |= SC;
	if (_d) status |= SD;
	if (_i) status |= SI;
	if (_n) status |= SN;
	if (_v) status |= SV;
	if (_z) status |= SZ;
	
	_cycles++;
	[self pushByteToStack:status];
}

- (void)PLP {
	uint8_t status = [self popByteFromStack];
	
	_b = (status & SB) != 0;
	_c = (status & SC) != 0;
	_d = (status & SD) != 0;
	_i = (status & SI) != 0;
	_n = (status & SN) != 0;
	_v = (status & SV) != 0;
	_z = (status & SZ) != 0;
	
	_cycles += 2;
}

#pragma mark -
#pragma mark Subroutines and Jump

- (void)JMP:(uint16_t)addr {
	_pc = addr;
}

- (void)JSR:(uint16_t)addr {
	[self pushShortToStack:_pc];
	_pc = addr;
	_cycles += 3;
}

- (void)RTS {
	_pc = [self popShortFromStack];
	_cycles += 4;
}

#pragma mark -
#pragma mark Set and Clear

- (void)SEC {
	_c = 1;
}

- (void)SED {
	_d = 1;
}

- (void)SEI {
	_i = 1;
}

- (void)CLC {
	_c = 0;
}

- (void)CLD {
	_d = 0;
}

- (void)CLI {
	_i = 0;
}

- (void)CLV {
	_v = 0;
}

#pragma mark -
#pragma mark Miscellaneous

- (void)NOP { }

#pragma mark -

@end
