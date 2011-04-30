//
//  KeyboardLayout.m
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "KeyboardLayout.h"

KeyStruct KeyInRowOneAtIndex (NSUInteger idx) {
	KeyStruct key;
	
	switch (idx) {
		case 0:
			KEY("1", '1', "!", '!')
			break;
		case 1:
			KEY("2", '2', "\"", '"')
			break;
		case 2:
			KEY("3", '3', "#", '#')
			break;
		case 3:
			KEY("4", '4', "$", '$')
			break;
		case 4:
			KEY("5", '5', "%", '%')
			break;
		case 5:
			KEY("6", '6', "&", '&')
			break;
		case 6:
			KEY("7", '7', "'", '\'')
			break;
		case 7:
			KEY("8", '8', "(", '(')
			break;
		case 8:
			KEY("9", '9', ")", ')')
			break;
		case 9:
			KEY("0", '0', NULL, 0)
			break;
		case 10:
			KEY(":", ':', "*", '*')
			break;
		case 11:
			KEY("-", '-', "=", '=')
			break;
		case 12:
			KEY("RESET", '4', NULL, 0)
			break;
		default:
			break;
	}
	
	return key;
}

KeyStruct KeyInRowTwoAtIndex (NSUInteger idx) {
	KeyStruct key;
	
	switch (idx) {
		case 0:
			KEY("ESC", 0x1B, NULL, 0)
			break;
		case 1:
			KEY("Q", 'Q', NULL, 0)
			break;
		case 2:
			KEY("W", 'W', NULL, 0)
			break;
		case 3:
			KEY("E", 'E', NULL, 0)
			break;
		case 4:
			KEY("R", 'R', NULL, 0)
			break;
		case 5:
			KEY("T", 'T', NULL, 0)
			break;
		case 6:
			KEY("Y", 'Y', NULL, 0)
			break;
		case 7:
			KEY("U", 'U', NULL, 0)
			break;
		case 8:
			KEY("I", 'I', NULL, 0)
			break;
		case 9:
			KEY("O", 'O', NULL, 0)
			break;
		case 10:
			KEY("P", 'P', "@", '@')
			break;
		case 11:
			KEY("REPT", 0, NULL, 0)
			break;
		case 12:
			KEY("RETURN", '\r', NULL, 0)
			break;
		default:
			break;
	}
	
	return key;
}

KeyStruct KeyInRowThreeAtIndex (NSUInteger idx) {
	KeyStruct key;
	
	switch (idx) {
		case 0:
			KEY("CTRL", 0, NULL, 0)
			break;
		case 1:
			KEY("A", 'A', NULL, 0)
			break;
		case 2:
			KEY("S", 'S', NULL, 0)
			break;
		case 3:
			KEY("D", 'D', NULL, 0)
			break;
		case 4:
			KEY("F", 'F', NULL, 0)
			break;
		case 5:
			KEY("G", 'G', NULL, 0)
			break;
		case 6:
			KEY("H", 'H', NULL, 0)
			break;
		case 7:
			KEY("J", 'J', NULL, 0)
			break;
		case 8:
			KEY("K", 'K', NULL, 0)
			break;
		case 9:
			KEY("L", 'L', NULL, 0)
			break;
		case 10:
			KEY(";", ';', "+", '+')
			break;
		case 11:
			KEY("LEFT", 0, NULL, 0)
			break;
		case 12:
			KEY("RIGHT", 0, NULL, 0)
			break;
		default:
			break;
	}
	
	return key;
}

KeyStruct KeyInRowFourAtIndex (NSUInteger idx) {
	KeyStruct key;
	
	switch (idx) {
		case 0:
			KEY("SHIFT", 0, NULL, 0)
			break;
		case 1:
			KEY("Z", 'Z', NULL, 0)
			break;
		case 2:
			KEY("X", 'X', NULL, 0)
			break;
		case 3:
			KEY("C", 'C', NULL, 0)
			break;
		case 4:
			KEY("V", 'V', NULL, 0)
			break;
		case 5:
			KEY("B", 'B', NULL, 0)
			break;
		case 6:
			KEY("N", 'N', "^", '^')
			break;
		case 7:
			KEY("M", 'M', NULL, 0)
			break;
		case 8:
			KEY(",", ',', NULL, 0)
			break;
		case 9:
			KEY(".", '.', NULL, 0)
			break;
		case 10:
			KEY("/", '/', "?", '?')
			break;
		case 11:
			KEY("SHIFT", 0, NULL, 0)
			break;
		default:
			break;
	}
	
	return key;
}
