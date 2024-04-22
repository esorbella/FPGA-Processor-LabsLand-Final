module debounce(
    input clk,
    input btn,
    output btn_debounced
);

parameter DEBOUNCE_TIME = 500000;

reg [31:0] counter;
reg state;

always @(posedge clk ) begin
    if (btn !== state && counter < DEBOUNCE_TIME) begin
        counter <= counter + 1;
    end else if (counter == DEBOUNCE_TIME) begin
        state <= btn;
        counter <= 0;
    end else begin
        counter <= 0;
    end
end

assign btn_debounced = state;

endmodule