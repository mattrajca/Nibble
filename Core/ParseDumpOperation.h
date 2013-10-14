//
//  ParseDumpOperation.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@interface ParseDumpOperation : NSOperation {
  @private
	NSData *_data;
}

@property (nonatomic, weak) id delegate;

- (id)initWithData:(NSData *)data;

@end


@interface NSObject (DumpParseOperationDelegate)

- (void)dumpParseOperation:(ParseDumpOperation *)operation
		 didEncounterBytes:(NSData *)bytes atAddress:(uint16_t)addr;

- (void)dumpParseOperation:(ParseDumpOperation *)operation
 didFinishParseFromAddress:(uint16_t)addr;

@end
