`timescale 1ns / 1ps


module top_morse_code (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start_i,
    input  wire [5:0] letter_code_i,
    input  wire       letter_space_en_i,
    input  wire       word_space_en_i,

    output wire       morse_o,   
    output wire       busy_o   
);

 
    wire [4:0] w_code;
    wire [2:0] w_code_length;
    wire [1:0] w_space_code;
    wire       w_half_sec_pulse;
    wire       w_half_sec_pulse_en;
    wire [3:0] w_half_sec_pulse_counter;
    wire       w_half_sec_pulse_counter_srst;
    wire [1:0] w_state;

    morse_code_decoder u_decoder (
        .letter_code_i     (letter_code_i),
        .letter_space_en_i (letter_space_en_i),
        .word_space_en_i   (word_space_en_i),
        .code_o            (w_code),
        .code_length_o     (w_code_length),
        .space_code_o      (w_space_code)
    );

    half_second_pulse #(
        .P_COUNT_MAX(49) // Mô ph?ng ??m 50 chu k?
    ) u_pulse_gen (
        .clk                 (clk),
        .rst_n               (rst_n),
        .enable_i            (w_half_sec_pulse_en),
        .half_second_pulse_o (w_half_sec_pulse)
    );

    half_sec_pull_counter u_counter (
        .clk                     (clk),
        .rst_n                   (rst_n),
        .srst_i                  (w_half_sec_pulse_counter_srst),
        .increase_i              (w_half_sec_pulse), // kich thich xung 0.5s
        .half_sec_pull_counter_o (w_half_sec_pulse_counter)
    );

    // 4. Module ?i?u khi?n trung tâm (FSM Controller)
    fsm_controller u_fsm (
        .clk                           (clk),
        .rst_n                         (rst_n),
        .start_i                       (start_i),
        .code_i                        (w_code),
        .code_length_i                 (w_code_length),
        .space_code_i                  (w_space_code),
        .half_sec_pulse_i              (w_half_sec_pulse),
        .half_sec_pulse_counter_i      (w_half_sec_pulse_counter),
        
        .half_sec_pulse_counter_srst_o (w_half_sec_pulse_counter_srst),
        .state_o                       (w_state),
        .half_sec_pulse_en_o           (w_half_sec_pulse_en)
    );

    morse_output u_output (
        .current_state_i (w_state),
        .morse_o         (morse_o),
        .busy_o          (busy_o)
    );

endmodule
