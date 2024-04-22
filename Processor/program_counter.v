module program_counter(
	inout [7:0] address,  // 8-hex address
	input enable, // Enable Flag
	input reset,
	input clk // Clock
);

reg [7:0] a = 8'h0;

always @(posedge clk) begin
	if (reset) begin
		a <= 8'h0;
	end else if (enable) begin
		a <= address + 1;
	end
end

assign address = a;

endmodule