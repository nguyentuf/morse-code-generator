`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2026 02:04:37 PM
// Design Name: 
// Module Name: half_sec_pull_counter
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


module half_sec_pull_counter(
    input wire clk,
    input wire rst_n,
    input wire srst_i,
    input wire increase_i,
    output reg [3:0] half_sec_pull_counter_o
    );
  always @(posedge clk or negedge rst_n) begin
  if ( !rst_n) begin
    half_sec_pull_counter_o <= 0;
  end else if ( srst_i) begin
    half_sec_pull_counter_o <= 0;
  end else if ( increase_i)  begin
  half_sec_pull_counter_o <= half_sec_pull_counter_o + 4'd1;
  end
 end
endmodule
