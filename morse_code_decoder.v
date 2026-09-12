`timescale 1ns / 1ps

module morse_code_decoder (
    input  wire [5:0] letter_code_i,
    input  wire       letter_space_en_i,
    input  wire       word_space_en_i,
    
    output reg  [4:0] code_o,
    output reg  [2:0] code_length_o,
    output wire [1:0] space_code_o
);

    assign space_code_o = (word_space_en_i)   ? 2'b11 :
                          (letter_space_en_i) ? 2'b10 : 2'b00;

    always @(*) begin
        case (letter_code_i)
            // Ch? cái (A-Z)
            6'd0 : begin code_o = 5'b01000; code_length_o = 3'd2; end // A
            6'd1 : begin code_o = 5'b10000; code_length_o = 3'd4; end // B
            6'd2 : begin code_o = 5'b10100; code_length_o = 3'd4; end // C
            6'd3 : begin code_o = 5'b10000; code_length_o = 3'd3; end // D
            6'd4 : begin code_o = 5'b00000; code_length_o = 3'd1; end // E
            6'd5 : begin code_o = 5'b00100; code_length_o = 3'd4; end // F
            6'd6 : begin code_o = 5'b11000; code_length_o = 3'd3; end // G
            6'd7 : begin code_o = 5'b00000; code_length_o = 3'd4; end // H
            6'd8 : begin code_o = 5'b00000; code_length_o = 3'd2; end // I
            6'd9 : begin code_o = 5'b01110; code_length_o = 3'd4; end // J
            6'd10: begin code_o = 5'b10100; code_length_o = 3'd3; end // K
            6'd11: begin code_o = 5'b01000; code_length_o = 3'd4; end // L
            6'd12: begin code_o = 5'b11000; code_length_o = 3'd2; end // M
            6'd13: begin code_o = 5'b10000; code_length_o = 3'd2; end // N
            6'd14: begin code_o = 5'b11100; code_length_o = 3'd3; end // O
            6'd15: begin code_o = 5'b01100; code_length_o = 3'd4; end // P
            6'd16: begin code_o = 5'b11010; code_length_o = 3'd4; end // Q
            6'd17: begin code_o = 5'b01000; code_length_o = 3'd3; end // R
            6'd18: begin code_o = 5'b00000; code_length_o = 3'd3; end // S
            6'd19: begin code_o = 5'b10000; code_length_o = 3'd1; end // T
            6'd20: begin code_o = 5'b00100; code_length_o = 3'd3; end // U
            6'd21: begin code_o = 5'b00010; code_length_o = 3'd4; end // V
            6'd22: begin code_o = 5'b01100; code_length_o = 3'd3; end // W
            6'd23: begin code_o = 5'b10010; code_length_o = 3'd4; end // X
            6'd24: begin code_o = 5'b10110; code_length_o = 3'd4; end // Y
            6'd25: begin code_o = 5'b11000; code_length_o = 3'd4; end // Z
            6'd26: begin code_o = 5'b01111; code_length_o = 3'd5; end // 1
            6'd27: begin code_o = 5'b00111; code_length_o = 3'd5; end // 2
            6'd28: begin code_o = 5'b00011; code_length_o = 3'd5; end // 3
            6'd29: begin code_o = 5'b00001; code_length_o = 3'd5; end // 4
            6'd30: begin code_o = 5'b00000; code_length_o = 3'd5; end // 5
            6'd31: begin code_o = 5'b10000; code_length_o = 3'd5; end // 6
            6'd32: begin code_o = 5'b11000; code_length_o = 3'd5; end // 7
            6'd33: begin code_o = 5'b11100; code_length_o = 3'd5; end // 8
            6'd34: begin code_o = 5'b11110; code_length_o = 3'd5; end // 9
            default: begin code_o = 5'b11111; code_length_o = 3'd5; end // 0
        endcase
    end

endmodule