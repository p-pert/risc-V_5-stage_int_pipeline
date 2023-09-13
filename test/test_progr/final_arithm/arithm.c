#include <stdio.h>
int main(){

  int a = 3;
  int b = 4;
  int c;
  c = a*b; // c = 3*4 = 12
  b = a/c; // b = 3/12 = 0
  a = a%c; // a = 3%12 = 3

  int d = (a + (b+3)*c - (c+200)/a)/(3*b + c/5); 
   // d = (3 + (0+3)*12 - (12+200)/3 ) / (3*0 + 12/5) = 
   //   = (39 - 70) / 2 = -15 = 0xFFFFFFF1

  int e = -4/0; 
  
  unsigned long int f = 0xFFFFFFFFFFFFFFFF;// -1 if signed, highest possible number 
                                           // if unsigned
  unsigned long int g1 = f + 1; // there is not ADD Unsigned instruction in RV64I 
                                // so f will be interepreted as -1 and g will just 
                                // be 0
  signed long int h = 0x7FFFFFFFFFFFFFFF; // 64-bit highest possible 2's complement 
                                          // signed number
  signed long int g2 = h + 1; // This time there should be an overflow

  signed long int g3 = h * 100; // This should overflow beyond 64 bits 
                                // (g3 = 0x31FFFFFFFFFFFFFF9C). The microarchitecture 
                                // doesn't have an overflow signal for MUL. 
                                // The MULH instruction should be used to check the 
                                // bits beyond the 64th. I'll add a MULH to the 
                                // instructions manually because the compiler doesn't 
                                // produce it on it's own to check that the bits 0x31 
                                // are there

  signed long int h2 = 0xFFFFFFFF80000000; // h2 contains the most negative 32-bit 
                                           // number possible in its first half 
                                           // (32-bits)...
  // ...for the following operation (g4) the compiler will use and ADDIW, that will 
  // operate on these 32 bits, neglecting the others, but doing so there will 
  // be an overflow in a Word operation:
  signed int g4 = h2 - 1; // it's int, not long int, so the compiler uses an ADDIW, 
                          // not ADDI

  unsigned int om1 = 0xFFFFFFFF; // this is 32-bit lenght
  unsigned int om2 = 3;
  unsigned long int rm = om1*om2; // here I'm trying to declare rm long int (64-bit), 
                                  // but the compiler still uses a MULW instruction, 
                                  // so this operation will encounter the same overflow 
                                  // situation as before (rm = 0x2FFFFFFFD > 32-bit).
                                  // A MUL instruction instead, would have produced an 
                                  // output containing immediately the right result in 
                                  // its least significant 64 bits.
  // This next attempt will use MUL and there won't be overflow problems, 
  // but obviously it will consume more memory because I'm just using 64-bit operands 
  // to host data that could fit in 32 bits:
  unsigned long long int o2m1 = 0xFFFFFFFF; 
  unsigned long long int o2m2 = 3;
  unsigned long long int r2m = o2m1*o2m2;
  return 0;
}