`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2026 07:45:14 AM
// Design Name: 
// Module Name: morse_output_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module morse_output_sync(
    input wire clk,
    input wire rst_n,
    input wire [1:0] current_state,
    output reg morse_o,
    output reg busy_o
    );
    localparam P_IDLE      = 2'd0;
    localparam P_LETTER_ON = 2'd1;
  always @(posedge clk or negedge rst_n) begin
    if ( !rst_n) begin
        morse_o <= 0;
        busy_o <= 0;
    end else begin
        morse_o <= ( current_state == P_LETTER_ON );
        busy_o <= ( current_state != P_IDLE);
    end
    end
endmodule
