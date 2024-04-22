module labsland_top(
    // Clocks
    CLOCK_50,

    // LEDs
    LEDG,
    LEDR,

    // KEY
    KEY,

    // SW
    SW,

    // SEG7
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,
    HEX6,
    HEX7
);

// INPUT

input CLOCK_50;

output [8:0] LEDG;
output [17:0] LEDR;

input [3:0] KEY;

input [17:0] SW;

output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;
output [6:0] HEX6;
output [6:0] HEX7;

// WIRES

wire clk = CLOCK_50;
wire one_shot_clock_latch;
wire one_shot_clock_reset;
wire latch = SW[16]; //start program
wire reset = SW[17]; //restart program
wire enable = ~KEY[2]; // not used
wire pusle = ~KEY[3]; //pulse - go to next instruction
wire a_enable = 1'b0; // not used atm
wire b_enable = 1'b0; // not used atm
wire o_enable = 1'b0; // not used atm

reg latch_a_reg = 0;
reg latch_b_reg = 0;
reg latch_o_reg = 0;
reg latch_alu = 0;

wire [7:0] i_bus;
wire [7:0] w_bus;
wire [7:0] alu_bus;

wire [7:0] i_drive_r;
reg [7:0] w_drive_r;

reg [7:0] alu_drive_a;
reg [7:0] alu_drive_b;
reg [7:0] alu_drive_o;

wire [7:0] instruction_reg;
wire [7:0] a_reg;
wire [7:0] b_reg;
wire [7:0] out_reg;

wire [7:0] a = SW[7:0];
wire [7:0] b = SW[15:8];

wire [1:0] program_selection = 2'b00; //default area of rectangle
//wire [1:0] program_selection = SW[1:0];

wire [7:0] instruction;
reg [3:0] alu_instruction;

// Components

clock_pulse clock_pulse_inst0(
    .clk(clk),
    .btn(pusle),
    .pulse(one_shot_clock)
);

always @(posedge one_shot_clock) begin
    if (reset) begin
        latch_alu = 1'b0;
        w_drive_r = 8'bZZZZZZZZ;
        alu_instruction = 8'bZZZZ_ZZZZ;
    end
    if (latch) begin
        case (instruction[7:4]) // 1001 00 00
            4'b0000: begin // add
                latch_alu = 1'b1;
                alu_instruction = 4'b0000;
            end
            4'b0001: begin // subtract
                latch_alu = 1'b1;
                alu_instruction = 4'b0001;
            end
            4'b0010: begin // multiply // 0010 00 01
                latch_alu = 1'b1;
                alu_instruction = 4'b0010;
            end
            4'b0011: begin // divide
                latch_alu = 1'b1;
                alu_instruction = 4'b0011;
            end
            4'b0100: begin // shift left
                latch_alu = 1'b1;
                alu_instruction = 4'b0100;
            end
            4'b0101: begin // shift right
                latch_alu = 1'b1;
                alu_instruction = 4'b0101;
            end
            4'b0110: begin // square a
                latch_alu = 1'b1;
                alu_instruction = 4'b0110;
            end
            4'b0111: begin // square b
                latch_alu = 1'b1;
                alu_instruction = 4'b0111;
            end
            4'b1000: begin // store alu
                w_drive_r = alu_bus;
                latch_a_reg = instruction[3:2] == 2'b00 ? 1'b1 : 1'b0;
                latch_b_reg = instruction[3:2] == 2'b01 ? 1'b1 : 1'b0;
                latch_o_reg = 1'b0;
            end
            4'b1001: begin // load a
                w_drive_r = a;
                latch_a_reg = instruction[3:2] == 2'b00 ? 1'b1 : 1'b0;
                latch_b_reg = instruction[3:2] == 2'b01 ? 1'b1 : 1'b0;
                latch_o_reg = 1'b0;
            end
            4'b1010: begin // load b
                w_drive_r = b;
                latch_a_reg = 1'b0;
                latch_b_reg = 1'b1;
                latch_o_reg = 1'b0;
                alu_drive_a = instruction[3:2] == 2'b00 ? a_reg : b_reg;
                alu_drive_b = instruction[1:0] == 2'b00 ? a_reg : b_reg;
            end
            4'b1011: begin // output
                w_drive_r = instruction[3:2] == 2'b00 ? a_reg : b_reg;
                latch_a_reg = 1'b0;
                latch_b_reg = 1'b0;
                latch_o_reg = 1'b1;
            end
            default: begin
                latch_alu = 1'b0;
                w_drive_r = 8'bZZZZ_ZZZZ;
                latch_a_reg = 1'b0;
                latch_b_reg = 1'b0;
                latch_o_reg = 1'b0;
                alu_instruction = 8'bZZZZ_ZZZZ;
            end
        endcase
    end
end

// always @(*) begin
//     if (enableReg) begin
//         latch_alu = 1'b0;
//     end
// end

eight_bit_register intruction_register(
	.clk(one_shot_clock),
	.enable(enable),
    .latch(latch),
	.reset(reset),
	.DATA(i_bus),
	.REG_OUT(instruction_reg)
);

eight_bit_register a_register(
	.clk(one_shot_clock),
	.enable(a_enable),
    .latch(latch_a_reg),
	.reset(reset),
	.DATA(w_bus),
	.REG_OUT(a_reg)
);

eight_bit_register b_register(
	.clk(one_shot_clock),
	.enable(b_enable),
    .latch(latch_b_reg),
	.reset(reset),
	.DATA(w_bus),
	.REG_OUT(b_reg)
);

eight_bit_register out_register(
	.clk(one_shot_clock),
	.enable(o_enable),
    .latch(latch_o_reg),
	.reset(reset),
	.DATA(w_bus),
	.REG_OUT(out_reg)
);

seven_seg seven_seg_inst0(
    .in(instruction_reg[3:0]),
    .hex(HEX6)
);
seven_seg seven_seg_inst1(
    .in(instruction_reg[7:4]),
    .hex(HEX7)
);
seven_seg seven_seg_inst2(
    .in(w_bus[7:4]),
    .hex(HEX5)
);
seven_seg seven_seg_inst3(
    .in(w_bus[3:0]),
    .hex(HEX4)
);

seven_seg seven_seg_inst4(
    .in(alu_bus[7:4]),
    .hex(HEX3)
);
seven_seg seven_seg_inst5(
    .in(alu_bus[3:0]),
    .hex(HEX2)
);

seven_seg seven_seg_inst6(
    .in(out_reg[7:4]),
    .hex(HEX1)
);
seven_seg seven_seg_inst7(
    .in(out_reg[3:0]),
    .hex(HEX0)
);

program_counter program_counter_inst0(
    .address(i_drive_r),
    .enable(latch),
    .reset(reset),
    .clk(one_shot_clock)
);

eight_bit_rom rom(
    .prog(program_selection),
    .address(instruction_reg),
    .instruction(instruction)
);

eight_bit_alu alu(
    .A(a_reg),
    .B(b_reg),
    .latch(latch_alu),
    .ALU_Sel(alu_instruction),
    .ALU_Out(alu_bus),
    .CarryOut(LEDG[8])
);

// logic

// assign LEDG = alu_drive_o;
assign LEDG[7:0] = instruction;
assign LEDR[17:16] = {reset, latch};
assign LEDR[15:8] = b_reg;
assign LEDR[7:0] = a_reg;
assign i_bus = (latch) ? i_drive_r : 8'bZZZZZZZZ;
assign w_bus = (latch) ? w_drive_r : 8'bZZZZZZZZ;

endmodule