//
//  PIA6821.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@class Memory;
@protocol PIA6821Delegate;

@interface PIA6821 : NSObject {
  @private
	Memory *_memory;
	BOOL _inputEnabled, _videoEnabled;
}

@property (nonatomic, weak) id < PIA6821Delegate > delegate;

- (id)initWithMemory:(Memory *)someMemory;

- (void)reset;

- (void)processInputChar:(char)character;

@end


@protocol PIA6821Delegate < NSObject >

- (void)PIA6821:(PIA6821 *)pia outputVideoChar:(char)character;

@end
