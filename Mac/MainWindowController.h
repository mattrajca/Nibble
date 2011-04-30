//
//  MainWindowController.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "M6502.h"
#import "Memory.h"
#import "PIA6821.h"
#import "ScreenView.h"

@interface MainWindowController : NSWindowController < PIA6821Delegate, ScreenViewDelegate > {
  @private
	NSOperationQueue *_workQueue;
	Memory *_memory;
	M6502 *_processor;
	PIA6821 *_pia;
}

@property (nonatomic, retain) IBOutlet ScreenView *screenView;

- (void)loadMemoryDumpFileAtPath:(NSString *)aPath;

- (void)saveMemoryDumpFileToPath:(NSString *)aPath
					 fromAddress:(uint16_t)fromAddr
					   toAddress:(uint16_t)toAddr;

- (IBAction)loadMemoryDumpFile:(id)sender;
- (IBAction)saveMemoryDumpFile:(id)sender;

- (IBAction)reset:(id)sender;

@end
