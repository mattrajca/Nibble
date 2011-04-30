//
//  PIA6821.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "PIA6821.h"

#import "Memory.h"

@interface PIA6821 ()

- (void)setup;

@end


@implementation PIA6821

#define KBD_LOC (0xD010)
#define KBD_CR_LOC (0xD011)

#define DSP_LOC (0xD012)
#define DSP_CR_LOC (0xD013)

@synthesize delegate;

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
	[super dealloc];
}

- (void)reset {
	_inputEnabled = _videoEnabled = NO;
	[self setup];
}

- (void)setup {
	[_memory watchMemoryAtAddress:DSP_LOC writeBlock:^(uint8_t val) {
		
		if (val >= 0x80)
			val -= 0x80;
		
		[_memory writeByte:val atAddress:DSP_LOC];
		
		if ([self.delegate respondsToSelector:@selector(PIA6821:outputVideoChar:)]) {
			[self.delegate PIA6821:self outputVideoChar:val];
		}
		
	}];
	
	[_memory watchMemoryAtAddress:DSP_CR_LOC writeBlock:^(uint8_t newValue) {
		
		if (!_videoEnabled && newValue >= 0x80) {
			_videoEnabled = YES;
			[_memory writeByte:0x0 atAddress:DSP_CR_LOC];
		}
		
	}];
	
	[_memory watchMemoryAtAddress:KBD_CR_LOC writeBlock:^(uint8_t val) {
		
		if (!_inputEnabled && val >= 0x80) {
			_inputEnabled = YES;
			[_memory writeByte:0x0 atAddress:KBD_CR_LOC];
		}
		
	}];
	
	[_memory watchMemoryAtAddress:KBD_CR_LOC readBlock:^(uint8_t val) {
		
		if (_inputEnabled && val >= 0x80) {
			[_memory writeByte:0x0 atAddress:KBD_CR_LOC]; // reset CR after read
		}
		
	}];
}

- (void)processInputChar:(char)character {
	if (!_inputEnabled || character >= 0x80)
		return;
	
	character &= 0x7F;
	
	if (character >= 0x61 && character <= 0x7A)
		character = toupper(character);
	
	if (character < 0x60) {
		[_memory ignoreWatch:^{
			[_memory writeByte:character + 0x80 atAddress:KBD_LOC];
			[_memory writeByte:0xA7 atAddress:KBD_CR_LOC];
		}];
	}
}

@end
