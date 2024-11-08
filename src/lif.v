`default_nettype none

module lif #(
    parameter DELTA_NUM = 1,
    parameter DELTA_DEN = 4,
    parameter BETA_NUM = 1,
    parameter BETA_DEN = 2
) (
    input wire[ 7:0]    current,
    input wire          clk,
    input wire          reset_n,
    output reg [7:0]    state,
    output wire         spike
);

    wire [7:0] next_state, next_leak;
    reg [7:0] threshold, timer, leak;

    always @(posedge clk) begin

        if (!reset_n) begin
            state <= 0;
            leak <= 0;
            threshold <= 200;
            timer <= 8'b00000000;
        end else begin
            state <= next_state;
            leak <= next_leak;
            if (spike) begin
                timer <=8'b00000000;
            end else begin
                if (timer == 8'b11111111) begin
                    timer <= 8'b00000000;
                end else begin
                    timer <= timer + 1;
                end
            end
        end
    end

    //adaptive leaky potential
    assign next_leak = leak + ((DELTA_NUM / DELTA_DEN)/ timer);

    //LIF equation with leak adjustment
    assign next_state = current + ( spike ? 0 : ((BETA_NUM/BETA_DEN) * state)) - leak;

    //spiking logic
    assign spike = (state >= threshold);

endmodule