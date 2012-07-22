//
//  ArchiveDumpOperation.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@class Memory;

@interface ArchiveDumpOperation : NSOperation {
  @private
	Memory *_memory;
	NSURL *_path;
	uint16_t _fromAddr, _toAddr;
}

- (id)initWithMemory:(Memory *)memory
				path:(NSURL *)aPath
		 fromAddress:(uint16_t)fromAddr
		   toAddress:(uint16_t)toAddr;

@end
