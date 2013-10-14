//
//  ParseDumpOperation.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ParseDumpOperation.h"

@implementation ParseDumpOperation

#define ACCUM_WIDTH 4096
#define BYTES_PER_LINE 4096

#define CLEAR_ACCUM bzero(accumulator, ACCUM_WIDTH);\
					idx = 0

#define CLEAR_BYTES bzero(bytes, BYTES_PER_LINE);\
					btidx = 0

typedef enum {
	DumpParseWaitingForAddress = 0,
	DumpParseReadingOps,
	DumpParseSkippingComments
} DumpParseState;

@synthesize delegate;

- (id)initWithData:(NSData *)data {
	NSParameterAssert(data != nil);
	
	self = [super init];
	if (self) {
		_data = data;
	}
	return self;
}


- (void)main {
	@autoreleasepool {
	
		uint32_t len = (uint32_t) [_data length];
		
		char *data = malloc(len);
		[_data getBytes:data length:len];
		
		DumpParseState state = DumpParseWaitingForAddress;
		
		uint16_t addr = 0;
		uint32_t firstAddr = UINT32_MAX;
		
		uint8_t bytes[BYTES_PER_LINE];
		uint32_t btidx = 0;
		
		CLEAR_BYTES;
		
		char accumulator[ACCUM_WIDTH];
		uint32_t idx = 0;
		
		CLEAR_ACCUM;
		
		for (uint32_t n = 0; n < len; n++) {
			char c = data[n];
			
			if (c == '/' && data[n+1] == '/') {
				state = DumpParseSkippingComments;
				continue;
			}
			
			if (state == DumpParseSkippingComments) {
				if (c == '\n' || c == '\r') {
					state = DumpParseWaitingForAddress;
				}
				
				continue;
			}
			
			if (c == '\n' || c == '\r' || c == '\t' || c == ' ') {
				if (state == DumpParseReadingOps && accumulator[0] > 0) {
					bytes[btidx++] = strtol(accumulator, NULL, 16);
					
					CLEAR_ACCUM;
				}
				
				if (c == '\n' || c == '\r') {
					NSData *data = [NSData dataWithBytes:bytes length:btidx];
					
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{
						
						if ([self.delegate respondsToSelector:@selector(dumpParseOperation:
																		didEncounterBytes:
																		atAddress:)]) {
							
							[self.delegate dumpParseOperation:self
											didEncounterBytes:data
													atAddress:addr];
						}
						
					}];
					
					CLEAR_BYTES;
					
					state = DumpParseWaitingForAddress;
				}
				
				continue;
			}
			
			if (state == DumpParseWaitingForAddress && c == ':') {
				addr = strtol(accumulator, NULL, 16);
				
				if (firstAddr == UINT32_MAX)
					firstAddr = addr;
				
				CLEAR_ACCUM;
				
				state = DumpParseReadingOps;
				
				continue;
			}
			
			accumulator[idx++] = c;
		}
		
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			
			if ([self.delegate respondsToSelector:@selector(dumpParseOperation:
															didFinishParseFromAddress:)]) {
				
				[self.delegate dumpParseOperation:self didFinishParseFromAddress:firstAddr];
			}
			
		}];
		
		free(data);
	
	}
}

@end
