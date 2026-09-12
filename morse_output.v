module morse_output (
  input [1:0] current_state_i,
  output morse_o,
  output busy_o
);
  localparam P_IDLE  = 2'd0;
  localparam P_LETTER_ON  = 2'd1;
  
  assign morse_o = (current_state_i == P_LETTER_ON);
  assign busy_o = (current_state_i != P_IDLE);
  
endmodule
         
