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
    wire [31:0] scaled_delta, leak_sum, scaled_state, state_sum;

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

    //assign next_leak = leak + (delta / timer);

    //assign next_state = current + (spike ? 0: (beta * state)) - leak;
    assign scaled_delta = delta << 16;
    assign leak_sum = {24'b0, leak} + (scaled_delta / timer);
    assign next_leak = leak_sum[7:0];  // Extend leak to 16 bits

    assign state_sum = beta * state;
    assign scaled_state = {24'b0, current} + (spike ? 32'b0 : (state_sum >> 16)) - {24'b0, leak};
    //assign state_sum = {8'b0, current} + (spike ? 0 : (beta * state)) - {8'b0, leak};
    assign next_state = scaled_state[7:0];     //assign next_state = current + (state >> 1);

    //spiking logic
    assign spike = (state >= threshold);

endmodule