//
//  KeyboardLayout.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#define KEY(t,c,st,sc)\
		key.title = (t);\
		key.repChar = (c);\
		key.sTitle = (st);\
		key.sRepChar = (sc);

typedef struct {
	const char *title;
	char repChar;
	const char *sTitle;
	char sRepChar;
} KeyStruct;

KeyStruct KeyInRowOneAtIndex (NSUInteger idx);
KeyStruct KeyInRowTwoAtIndex (NSUInteger idx);
KeyStruct KeyInRowThreeAtIndex (NSUInteger idx);
KeyStruct KeyInRowFourAtIndex (NSUInteger idx);
