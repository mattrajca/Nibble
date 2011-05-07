//
//  ScreenView.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "ScreenView.h"

@interface ScreenView ()

- (void)setupView;

- (void)moveToNextLine;

@end


@implementation ScreenView

#define LINE_SPACING 3.0f

@synthesize font, fontSize, characterSpacing, margin, delegate;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupView];
        [self reset];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupView];
        [self reset];
	}
	return self;
}

- (void)setupView {
	self.margin = CGSizeMake(6.0f, 6.0f);
}

- (void)reset {
	_currentRow = _currentCol = 0;
	memset(_contents, 0, COLS * ROWS);
	
	[self setNeedsDisplay];
}

- (void)putCharacter:(char)character {
	if (character == 0x0 || character == 0x7F)
		return;
	
	if (character == 0x5F) {
		if (_currentCol == 0) {
			_currentRow--; // backtrack to previous line, last character
			_currentCol = COLS - 1;
		}
		else {
			_currentCol--;
		}
		
		_contents[_currentRow][_currentCol] = 0x0;
		[self setNeedsDisplay];
		
		return;
	}
	
	if (character == 0x0A || character == 0x0D ||
		character == '\r' || character == '\n') {
		
		[self moveToNextLine];
		return;
	}
	
	_contents[_currentRow][_currentCol] = character;
	
	if (_currentCol < (COLS-1)) {
		_currentCol++;
	}
	else {
		[self moveToNextLine];
	}
	
	[self setNeedsDisplay];
}

- (void)moveToNextLine {
	_currentCol = 0;
	
	if (_currentRow < (ROWS-1)) {
		_currentRow++;
		return;
	}
	
	for (int y = 1; y < ROWS; y++) {
		for (int x = 0; x < COLS; x++) {
			_contents[y-1][x] = _contents[y][x];
			
			if (y == _currentRow)
				_contents[y][x] = 0x0;
		}
	}
	
	[self setNeedsDisplay];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)drawRect:(CGRect)dirtyRect {
	[[UIColor blackColor] set];
	
#if TARGET_OS_IPHONE
	[[UIBezierPath bezierPathWithRoundedRect:[self bounds]
								cornerRadius:8.0f] fill];
#else
	UIRectFill([self bounds]);
#endif
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
#if !TARGET_OS_IPHONE
	CGContextSetAllowsFontSmoothing(ctx, false);
#endif
	
	CGContextSelectFont(ctx, [font UTF8String], fontSize, kCGEncodingMacRoman);
	CGContextSetCharacterSpacing(ctx, characterSpacing);
	CGContextSetTextMatrix(ctx, CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f));
	CGContextSetRGBFillColor(ctx, 0.0f, 1.0f, 0.0f, 1.0f);
	
	CGFloat top = margin.height + (fontSize * 2.0f / 3);
	
	for (int y = 0; y < ROWS; y++) {
		CGContextShowTextAtPoint(ctx, margin.width, top + y * (fontSize + LINE_SPACING),
								 _contents[y], COLS);
	}
}

- (void)insertText:(NSString *)text {	
	if ([delegate respondsToSelector:@selector(screenView:didReceiveChar:)]) {
		[delegate screenView:self didReceiveChar:[text characterAtIndex:0]];
	}
}

- (BOOL)hasText {
	return YES;
}

- (void)deleteBackward { }

@end
