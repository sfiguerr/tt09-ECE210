`default_nettype none

module lif(
    input wire[ 7:0]    current,
    input wire          clk,
    input wire          reset_n,
    output reg [7:0]    state,
    output wire         spike
);

    wire [7:0] next_state, next_leak, leak;
    reg [7:0] threshold, timer;
    reg [15:0] beta, delta;

    always @(posedge clk) begin
        //timer ++;
        //if (spk) reset
        if (!reset_n) begin
            state <= 0;
            threshold <= 200;
            beta <= 16'b0000000010000000;    //0.5
            delta <= 16'b0000000001000000;  //0.25
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

    assign next_leak = leak + (delta / timer);

    assign next_state = current + (spike ? 0: (beta * state)) - leak;
    //assign next_state = current + (state >> 1);

    //spiking logic
    assign spike = (state >= threshold);

endmodule