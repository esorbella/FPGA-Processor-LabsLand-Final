module eight_bit_rom(
    input [1:0] prog,
    input [7:0] address,
    output reg [7:0] instruction
);

// Instruction breakdown
// 8 bit instruction
// first 4 are the opp_code
// next 2 is the first reg
// next 2 is the second reg


// CONSTANTS

reg[1:0] nullReg = 2'b00;

reg[1:0] reg1 = 2'b00;
reg[1:0] reg2 = 2'b01;
// reg[1:0] reg3 = 2'b10;
// reg[1:0] reg4 = 2'b11;

reg[3:0] add = 4'b0000; // add a to b
reg[3:0] sub = 4'b0001; // sub b from a
reg[3:0] mul = 4'b0010; // mul a and b
reg[3:0] div = 4'b0011; // div a by b
reg[3:0] shl = 4'b0100; // shift a left 1
reg[3:0] shr = 4'b0101; // shift b left 1
reg[3:0] sqa = 4'b0110; // square a
reg[3:0] sqb = 4'b0111; // square b
reg[3:0] push = 4'b1000; // push result of alu into reg
reg[3:0] lda = 4'b1001; // load a into reg
reg[3:0] ldb = 4'b1010; // load b into reg
reg[3:0] out = 4'b1011; // output reg
reg[3:0] bshl = 4'b1100; // shift b left 1
reg[3:0] bshr = 4'b1101; // shift b right 1

always @(*) begin
	case (prog)
		2'b00: begin case (address)
			  8'b00000000: instruction = {lda, reg1, nullReg};     // {1001, 00, 00} = 10010000 
			  8'b00000001: instruction = {ldb, reg2, nullReg};     // {1010, 01, 00} = 10100100 // 1010 01 00
			  8'b00000010: instruction = {mul, reg1, reg2};        // {0010, 00, 01} = 00100001 // 0010 00 01
			  8'b00000011: instruction = {push, reg1, nullReg};
			  8'b00000100: instruction = {shr, reg1, nullReg};
			  8'b00000101: instruction = {push, reg1, nullReg};
			  8'b00000111: instruction = {out, reg1, nullReg};
			  default:  instruction = 8'bZZZZZZZZ;
		endcase end
		2'b01: begin case (address)
			  8'b00000000: instruction = {lda, reg1, nullReg};
			  8'b00000001: instruction = {ldb, reg2, nullReg};
			  8'b00000010: instruction = {add, reg1, reg2};
			  8'b00000011: instruction = {push, reg1, nullReg};
			  8'b00000100: instruction = {shr, reg1, nullReg};
			  8'b00000101: instruction = {push, reg1, nullReg};
			  8'b00000110: instruction = {out, reg1, nullReg};
			  default:  instruction = 8'bZZZZZZZZ;
		endcase end
		2'b10:  begin case (address)
			  8'b00000000: instruction = {lda, reg1, nullReg};     // {1001, 00, 00} = 10010000 
			  8'b00000001: instruction = {ldb, reg2, nullReg};     // {1010, 01, 00} = 10100100 // 1010 01 00
			  8'b00000010: instruction = {sqa, reg1, nullReg};     // {0010, 00, 01} = 00100001 // 0010 00 01
			  8'b00000011: instruction = {push, reg1, nullReg};
			  8'b00000100: instruction = {mul, reg1, reg2};
			  8'b00000101: instruction = {push, reg1, nullReg};
			  8'b00000111: instruction = {out, reg1, nullReg};
			  default:  instruction = 8'bZZZZZZZZ;
		endcase end
		2'b11: begin case (address)
			  8'b00000000: instruction = {lda, reg1, nullReg};
			  8'b00000001: instruction = {ldb, reg2, nullReg};
			  8'b00000010: instruction = {sqa, reg1, nullReg};
			  8'b00000011: instruction = {push, reg1, nullReg};
			  8'b00000100: instruction = {shr, reg1, nullReg};
			  8'b00000101: instruction = {push, reg1, nullReg};
			  8'b00000110: instruction = {sqb, reg2, nullReg};
			  8'b00000111: instruction = {push, reg2, nullReg};
			  8'b00001000: instruction = {bshr, reg2, nullReg};
			  8'b00001001: instruction = {push, reg2, nullReg};
			  8'b00001010: instruction = {sub, reg1, reg2};
			  8'b00001011: instruction = {push, reg1, nullReg};
			  8'b00001100: instruction = {out, reg1, nullReg};
			  default:  instruction = 8'bZZZZZZZZ;
		endcase end
	endcase
end

// lda
// ldb
// sqr a
// push a
// sqr b
// push b
// shr a
// push a
// shr b
// push b
// add a, b
// push a
// out a

//   8'b00000001: instruction = {ldb, reg2, nullReg};
//   8'b00000010: instruction = {add, reg1, reg2};
//   8'b00000011: instruction = {push, reg1, nullReg};
//   8'b00000100: instruction = {shr, reg1, nullReg};
//   8'b00000101: instruction = {push, reg1, nullReg};
//   8'b00000110: instruction = {out, reg1, nullReg};

endmodule