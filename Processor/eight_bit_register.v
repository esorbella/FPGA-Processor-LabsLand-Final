module eight_bit_register(
    input clk,
	input enable,
	input latch,
	input wire reset,
    inout [7:0] DATA,
    output [7:0] REG_OUT
);

reg [7:0] r;// = 8'b0;

always @(posedge clk) begin
	if (reset) begin
		r <= 0;
	end else begin
		if (latch) begin
			r <= DATA;
		end
	end
end

assign DATA = (enable) ? r : 8'bZZZZZZZZ;
assign REG_OUT = r;

endmodule