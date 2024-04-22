module clock_pulse(
    input clk,
    input btn,
    output pulse
);

wire pulse_debounced;
wire one_shot_clock;

debounce debounce_inst0(
    .clk(clk),
    .btn(btn),
    .btn_debounced(pulse_debounced)
);

one_shot_clock one_shot_clock_inst0(
    .clk(clk),
    .btn(pulse_debounced),
    .pulse(one_shot_clock)
);

assign pulse = one_shot_clock;

endmodule