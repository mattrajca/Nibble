//
//  M6502+Private.h
//  Nibble
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

@interface M6502 (Private)

- (void)LDA:(uint8_t)val;
- (void)LDX:(uint8_t)val;
- (void)LDY:(uint8_t)val;
- (void)STA:(uint16_t)addr;
- (void)STX:(uint16_t)addr;
- (void)STY:(uint16_t)addr;

- (void)ADC:(uint8_t)val;
- (void)SBC:(uint8_t)val;

- (void)INC:(uint16_t)addr;
- (void)INX;
- (void)INY;
- (void)DEC:(uint16_t)addr;
- (void)DEX;
- (void)DEY;

- (void)ASL:(uint16_t)addr;
- (void)ASL_a;
- (void)LSR:(uint16_t)addr;
- (void)LSR_a;
- (void)ROL:(uint16_t)addr;
- (void)ROL_a;
- (void)ROR:(uint16_t)addr;
- (void)ROR_a;

- (void)AND:(uint8_t)val;
- (void)ORA:(uint8_t)val;
- (void)EOR:(uint8_t)val;

- (void)CMP:(uint8_t)val;
- (void)CPX:(uint8_t)val;
- (void)CPY:(uint8_t)val;
- (void)BIT:(uint8_t)val;

- (void)BCC:(uint16_t)addr;
- (void)BCS:(uint16_t)addr;
- (void)BEQ:(uint16_t)addr;
- (void)BMI:(uint16_t)addr;
- (void)BNE:(uint16_t)addr;
- (void)BPL:(uint16_t)addr;
- (void)BVC:(uint16_t)addr;
- (void)BVS:(uint16_t)addr;

- (void)TAX;
- (void)TXA;
- (void)TAY;
- (void)TYA;
- (void)TSX;
- (void)TXS;

- (void)PHA;
- (void)PLA;
- (void)PHP;
- (void)PLP;

- (void)JMP:(uint16_t)addr;
- (void)JSR:(uint16_t)addr;
- (void)RTS;

- (void)SEC;
- (void)SED;
- (void)SEI;
- (void)CLC;
- (void)CLD;
- (void)CLI;
- (void)CLV;

- (void)NOP;

@end
