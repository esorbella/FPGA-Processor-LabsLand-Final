module one_shot_clock(
    input clk,
    input btn,
    output reg pulse
);

reg q;

always @(posedge btn or posedge pulse) begin
    if (pulse) begin
        q <= 0;
    end else begin
        q <= 1;
    end
end

always @(posedge clk) begin
    pulse <= q;
end

endmodule