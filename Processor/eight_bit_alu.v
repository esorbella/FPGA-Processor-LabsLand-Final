module eight_bit_alu(
		input [7:0] A,B,  // ALU 8-bit Inputs
		input latch,               
		input [3:0] ALU_Sel,// ALU Selection
		output [7:0] ALU_Out, // ALU 8-bit Output
		output CarryOut // Carry Out Flag
);
reg [8:0] ALU_Result;
// reg [3:0] REG_Result = 2'b10;
// wire [8:0] tmp;
always @(*)
begin
	case(ALU_Sel)
		4'b0000: begin // Addition
			ALU_Result = A + B;
		end
		4'b0001: begin // Subtraction
			ALU_Result = A - B;
		end
		4'b0010: begin // Multiplication
			ALU_Result = A * B;
		end
		4'b0011: begin // Division
			ALU_Result = A/B;
		end
		4'b0100: begin // Logical shift left of A
			ALU_Result = A<<1;
		end
		4'b0101: begin // Logical shift right of A
			ALU_Result = A>>1;
		end
		4'b0110: begin // A sqaured
			ALU_Result = A * A;
		end
		4'b0111: begin // B sqaured
			ALU_Result = B * B;
		end
		4'b1000: begin // Logical shift left of B
			ALU_Result = B<<1;
		end
		4'b1001: begin // Logical shift right of B
			ALU_Result = B>>1;
		end
		default: ALU_Result = 8'bZZZZ_ZZZZ; 
	endcase
end

assign ALU_Out = (latch) ? ALU_Result[7:0] : 8'bZZZZ_ZZZZ; // ALU out
assign CarryOut = (latch) ? ALU_Result[8] : 1'bZ; // Carryout flag

endmodule