
module half_second_pulse #
( parameter P_COUNT_MAX = 49,
    parameter P_COUNT_BITWIDTH = $clog2(P_COUNT_MAX) + 1
)
( input wire clk,
  input wire rst_n,
  input wire enable_i,
  output wire half_second_pulse_o
);
reg [P_COUNT_BITWIDTH-1:0] count;
 always@(posedge clk or negedge rst_n) begin
    if( !rst_n) begin
        count <= 0;
    end else if ( enable_i == 1) begin 
        if ( count == P_COUNT_MAX) begin
            count <= 0;
        end else
            count <= count + 1;
        end 
        else count <= 0;
    end
 assign half_second_pulse_o = enable_i & ( count == P_COUNT_MAX);
 
    
endmodule
