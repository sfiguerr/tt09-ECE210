`default_nettype none

module lif(
    input wire[ 7:0]    current,
    input wire          clk,
    input wire          reset_n,
    output reg [7:0]    state,
    output wire         spike
);

    wire [7:0] next_state;
    reg [7:0] threshold;
    //reg [7:0] beta;

    always @(posedge clk) begin
        if (!reset_n) begin
            state <= 0;
            threshold <= 200;
            //beta <= 8'b00000010;
            //change beta value as fraction
        end else begin
            state <= next_state;
        end    
    end

    //assign next_state = current + beta * state
    assign next_state = current + (state >> 1);

    //spiking logic
    assign spike = (state >= threshold);

endmodule