//
//  MainWindowController.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "MainWindowController.h"

#import "ArchiveDumpOperation.h"
#import "ParseDumpOperation.h"
#import "PIA6821+Additions.h"

@interface MainWindowController ()

- (NSOperationQueue *)workQueue;

- (void)setupSystem;
- (void)loadROM;

- (uint16_t)addressFromTextField:(NSTextField *)textField;

@end


@implementation MainWindowController

#define MEM_SIZE (0xFFFF) // 64K
#define ROM_LOC (0xFF00)

static uint16_t sLastAddr;

@synthesize screenView = _screenView;

- (id)init {
	return [super initWithWindowNibName:@"MainWindow"];
}

- (void)awakeFromNib {
	self.screenView.font = @"PrintChar21";
	self.screenView.margin = CGSizeMake(6.0f, 10.0f);
	self.screenView.fontSize = 16.0f;
	self.screenView.characterSpacing = 1.0f;
	self.screenView.delegate = self;
	
	[self setupSystem];
}

- (NSOperationQueue *)workQueue {
	if (!_workQueue) {
		_workQueue = [[NSOperationQueue alloc] init];
		[_workQueue setMaxConcurrentOperationCount:2];
	}
	
	return _workQueue;
}

- (void)setupSystem {
	_memory = [[Memory alloc] initWithMemorySize:MEM_SIZE];
	[self loadROM];
	
	_pia = [[PIA6821 alloc] initWithMemory:_memory];
	_pia.delegate = self;
	
	_processor = [[M6502 alloc] initWithMemory:_memory];
	[_processor run];
}

- (void)loadROM {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"apple1"
													 ofType:@"rom"];
	
	NSData *romData = [NSData dataWithContentsOfFile:path];
	
	[_memory loadMemory:romData atAddress:ROM_LOC];
}

- (void)PIA6821:(PIA6821 *)pia outputVideoChar:(char)character {
	[self.screenView putCharacter:character];
}

- (void)screenView:(ScreenView *)aView didReceiveChar:(char)character {
	[_pia processInputChar:character];
}

#pragma mark -
#pragma mark Loading Memory Dumps

- (IBAction)loadMemoryDumpFile:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel beginSheetModalForWindow:[self window]
					  completionHandler:^(NSInteger result) {
						  
						  if (result != NSFileHandlingPanelOKButton)
							  return;
						  
						  [self loadMemoryDumpFileAtPath:[openPanel URL]];
						  
					  }];
}

- (void)loadMemoryDumpFileAtPath:(NSURL *)aPath {
	NSData *data = [NSData dataWithContentsOfURL:aPath];
	
	if (!data) {
		NSLog(@"Cannot load memory dump file");
		return;
	}
	
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	[controller noteNewRecentDocumentURL:aPath];
	
	ParseDumpOperation *operation = [[ParseDumpOperation alloc] initWithData:data];
	operation.delegate = self;
	
	[[self workQueue] addOperation:operation];
}

- (void)dumpParseOperation:(ParseDumpOperation *)operation
		 didEncounterBytes:(NSData *)bytes
				 atAddress:(uint16_t)addr {
	
	[_memory loadMemory:bytes atAddress:addr];
}

- (void)dumpParseOperation:(ParseDumpOperation *)operation
 didFinishParseFromAddress:(uint16_t)addr {
	
	sLastAddr = addr;
	
	NSString *title = NSLocalizedString(@"Success", nil);
	NSString *defaultButton = NSLocalizedString(@"Run", nil);
	NSString *otherButton = NSLocalizedString(@"OK", nil);
	NSString *message = NSLocalizedString(@"Loaded memory at address: 0x%X", nil);
	
	NSBeginInformationalAlertSheet(title, defaultButton, otherButton, nil, [self window],
								   self, NULL,
								   @selector(sheetDidDismiss:returnCode:contextInfo:),
								   NULL, message, addr);
}

- (void)sheetDidDismiss:(NSWindow *)sheet
			 returnCode:(NSInteger)returnCode
			contextInfo:(void *)contextInfo {
	
	if (returnCode == NSAlertAlternateReturn)
		return;
	
	[_pia evokeRunAtAddress:sLastAddr];
	sLastAddr = 0;
}

#pragma mark -
#pragma mark Saving Memory Dumps

- (uint16_t)addressFromTextField:(NSTextField *)textField {
	NSString *string = [textField stringValue];
	
	if ([string hasPrefix:@"0x"] || [string hasPrefix:@"0X"]) {
		string = [string substringFromIndex:2];
	}
	
	return strtol([string UTF8String], NULL, 16);
}

- (IBAction)saveMemoryDumpFile:(id)sender {
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
	
	NSViewController *avc = [[NSViewController alloc] initWithNibName:@"AddressView"
															   bundle:nil];
	
	[savePanel setAccessoryView:[avc view]];
	
	[savePanel beginSheetModalForWindow:[self window]
					  completionHandler:^(NSInteger result) {
						  
						  if (result != NSFileHandlingPanelOKButton)
							  return;
						  
						  NSTextField *fromField = [[savePanel accessoryView] viewWithTag:4];
						  NSTextField *toField = [[savePanel accessoryView] viewWithTag:5];
						  
						  uint16_t fromAddr = [self addressFromTextField:fromField];
						  uint16_t toAddr = [self addressFromTextField:toField];
						  
						  [self saveMemoryDumpFileToPath:[savePanel URL]
											 fromAddress:fromAddr
											   toAddress:toAddr];
						  
					  }];
}

- (void)saveMemoryDumpFileToPath:(NSURL *)aPath
					 fromAddress:(uint16_t)fromAddr
					   toAddress:(uint16_t)toAddr {
	
	ArchiveDumpOperation *operation = [[ArchiveDumpOperation alloc] initWithMemory:_memory
																			  path:aPath
																	   fromAddress:fromAddr
																		 toAddress:toAddr];
	
	[[self workQueue] addOperation:operation];
}

#pragma mark -

- (IBAction)reset:(id)sender {
	BOOL hard = ([NSEvent modifierFlags] & NSAlternateKeyMask) == NSAlternateKeyMask;
	
	[_processor stop];
	
	if (hard)
		[_memory reset]; // ROM has to be reloaded before running M6502
	
	[_pia reset];
	[_screenView reset];
	
	if (hard)
		[self loadROM];
	
	[_processor reset];
	[_processor run];
}

@end
