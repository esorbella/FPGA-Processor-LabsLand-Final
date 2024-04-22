# FPGA-Board-Lab-Creation
Project at Pace University to create a program to make a small processor and run a basic program using an FPGA Board, Quartus/Labsland, and Verilog.

## Authors

- [@alexanderjhughes](https://www.github.com/alexanderjhughes)
- [@esorbella](https://github.com/esorbella)


# Files

## Top Files (Control Units)

The files that are used as the "main" file. Used to define all of the modules and contain the `control unit`. The `control unit` is the always loop that reads the instruction pased in when the clock is pulsed.

### Inputs for FPGA

**Switches (in binary)**
- 17-16
  - In an ideal world this is the program selection but Labsland does not let us click multiple buttons at once, so we must pivot
  - 17: If this is on, the next pusle of the clock will be a reset
  - 16: If this is on and SW 17 is off, the next pulse of the clock will be a latch pulse
- 15-8: Value to enter in the B register (B value)
- 7-0: Value to enter in the A register (A value)

**Keys (buttons)**
- Right most button: Pulse the clock
- Next button: Enable - not used atm
- Last 2 buttons (left 2 buttons): not used atm

### Outputs for FPGA

**Seven Seg Display (from left to right):**
- The first two numbers show what instruction the program is on
- The next two are whats in the w `bus`
- The following two are whats in the ALU `bus`
- The last two numbers shows the output register

**LEDS (from left to right):**
- Green LEDS
  - The very first green led on the left is the carry out flag if a number goes over 8 bits or is negative
  - The instruction the program is on in machine code (frist 4 is op code, next 2 are reg1 and the last 2 are reg2)
- Red LEDS
  - The left most 2 show what program is selected
  - The next 8 show whats in the b reg in binary
  - The last 8 show whats in the a reg in binary

### Buses

These bus data to and from the different `components` of the `CPU`. Every `component` of the `CPU` has acces to the `bus`.

**I bus:** this is the instruction bus. It buses the instructions from the `ROM` to the `control unit`. This uses the **i_drive_r** to determine what to drive into the bus.

**W bus:** this is the w bus. It buses the data from the different components like the ALU or the registers to the `control unit`. This uses the **w_drive_r** to determine what to drive into the bus.

**ALU bus:** this is the ALU bus. It buses the data from the ALU to the `control unit` which then busses it to the w_bus to get stored in registers or to get used in the next actions.

### Clock

**The clock:** this is the `wire` that holds the signal for the internal clock of the FPGA board. We use this in the one shot clock to get a pulsed clock.

**One Shot Clock:** this is a `wire` flag that is up only on the rising edge of the clock `wire` and when the pulse button is pressed.

### Buttons

**The latch button:** this is the button used to tell different `components` to latch data into their `component` and in some cases, latch data onto the bus.

**The reset button:** this is used to reset data on the `CPU`. Mostly for testing purposes.

**The enable button:** this button is not fully fuctional. This is supposed to tell `components` when to output things onto the `bus` but for now we are using the latch for that.

**The pulse button:** this button is used to pulse the clock. Every processor has a clock. This clock pulses and gives power on and off to components so it can function. With the pulse button, we can slow down the clock so we can visualize our programs, or else they would run instantly. 

### Registers

**A:** this is the register to hold the value of a

**B:** this is the register to hold the value of b

**Instruction:** this is the register to hold the value of what instruction the process is on

**Out:** this is the register to hold the value of what should be outputted to the 7 seg display. 

Each of the last 3 registers have a dedicated latch `reg` to tell it when to latch the data from the `w_bus` into the register



## Eight Bit ALU

The ALU module. Contains the logic to perform operations on 2 given numbers (A and B). The operations are as follows:
```
4'b0000 -> Addition (A + B)
4'b0001 -> Subtraction (A - B)
4'b0010 -> Multiplication (A * B)
4'b0011 -> Division (A / B)
4'b0100 -> Logical shift left of A
4'b0101 -> Logical shift right of A
4'b0110 -> A sqaured
4'b0111 -> B sqaured
4'b1000 -> Logical shift left of B
4'b1001 -> Logical shift right of B
```

#### Inputs: 
```
input [7:0] A,B,
input latch,               
input [3:0] ALU_Sel
```

**A and B:** the values being passed into the ALU

**ALU_Sel:** the 4 bit instruction with each operation in the ALU

**Latch:** the flag value that tells the ALU if the process is latched and it should output the value of A and B, basically tells the ALU if it is enabled or not as in this CPU structure, the ALU is always listening to the values of A, B, and ALU_Sel, so it needs a third instruction to tell it if it is enabled.

#### Outputs:
```
output [7:0] ALU_Out,
output CarryOut
```

**ALU_Out:** the output of the ALU, if latched returns the output of the operation on A and B, if not returns `8'bZZZZ_ZZZZ`. 

**CarryOut:** if the operation goes above 8 bits, this is the carry out flag

## Eight Bit Register

The Register Module. Contains the logic to mantain a register value. To create a new register, you create a new one of these modules.

#### Inputs:
```
input clk,
input enable,
input latch,
input wire reset
inout [7:0] DATA
```

**Clk:** This is the clock. It is used to only fire the logic in the register on the `posedge` of the clock. 

**Enable:** tells the register when to output to the data output which hooks up to the `w_bus`

**Latch:** tells the register whether or not to latch the data value into the register, will only get to this logic on the `posedge` of the clock. 

**DATA:** this is an inout. The register's link to the w_bus. When latch is enabled, it takes the value from this data inout. If latch is not enabled, inout is not read but rather used as the output, it outputs either itself or `8'bZZZZ_ZZZZ`.

#### Outputs:
```
inout [7:0] DATA,
output [7:0] REG_OUT
```

**DATA:** see above

**REG_OUT:** the register's output of its value to a value in the `control unit (top file)`.

## Eight Bit Rom

The ROM Module. Contains the data for the programs. For this architecture it is the way to program, in assaembly, the `CPU`. The `CPU` reads from the eight bit rom which tells it which acction to perfrom next. In a full fleged computer, this module would be replaced with something that loads files containt instructions into memory and then give the `CPU` the address of the first instruction. Here is the instruction set, the 4 bit number is the `opp_code` and the following word is the `assembly language` code:

```
0000 = add  // add a to b
0001 = sub  // sub b from a
0010 = mul  // mul a and b
0011 = div  // div a by b
0100 = shl  // shift a left 1
0101 = shr  // shift b left 1
0110 = sqa  // square a
0111 = sqb  // square b
1000 = push // push result of alu into reg
1001 = lda  // load a into reg
1010 = ldb  // load b into reg
1011 = out  // output reg
1100 = bshl // shift b left 1
1101 = bshr // shift b right 1
```

The instruction is an 8 bit code. Here is what makes up the 8 bits:
```
Breakdown (each bracket represents 4 bits):
[opp_code] [first reg, second reg]

Machine code example:
0000 0001

Assembly code example:
add reg1 reg2
```

An example program is as follows (the 8 bit number is the address of the program, instruction is what to return, the {} is the `assembly language` which gets converted to `machine code` for the `control unit`):

```
00000000: instruction = {lda, reg1, nullReg};
00000001: instruction = {out, reg1, nullReg};
```

#### Inputs
```
input [1:0] prog,
input [7:0] address
```

**Prog:** the 2 bit number to select the program. This means we can only store 4 programs in this cpu.

**Address:** the 8 bit address that tells the rom which instruction to return.

#### Outputs
```
output reg [7:0] instruction
```

**Instruction:** 8 bit instruction in machine code that the given memory address is mapped too

## Program Counter

This is used to increment the program counter. The program counter is used to tell the program what instruction it is on

#### Inputs
```
inout [7:0] address,  // 8-hex address
input enable, // Enable Flag
input reset,
input clk // Clock
```

**Enable:** currently mapped to the latch in the `control unit`. If this flag is up and the reset flag is down, this module will increment the memory address of the current instruction by 1 bit on the rising edge of the clock pulse

**Reset:** if this flag is up, the program counter will reset the memory address of the current instruction to 0

**Clk:** the pulsed clock, the program counter will only fire if this is pusled and it will fire on the `posedge`

**Address:** this is the 8 bit memory address that points to what instruction the program is on. It is both an input and output thus it is `inout`

## Utilities

There are some utilities we are using for this specifi application: seven_seg.v, one_shot_clock.v, debounce.v, and clock_pulse.v

For lab purposes, these will be given to any students doing the lab