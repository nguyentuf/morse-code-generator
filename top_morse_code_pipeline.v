module top_morse_code_pipeline (
    input  wire       clk,
    input  wire       rst_n,
    
    input  wire       start_i,
    input  wire [5:0] letter_code_i,
    input  wire       letter_space_en_i,
    input  wire       word_space_en_i,
    
    output wire       morse_o,
    output wire       busy_o
);
    wire [4:0] w_code_comb;
    wire [2:0] w_code_length_comb;
    wire [1:0] w_space_comb;
    
    reg [4:0] r_code_pipe;
    reg [2:0] r_code_length_pipe;
    reg [1:0] r_space_code_pipe;
    reg       r_start_pipe;
    
    wire       w_half_sec_pulse;              // xung 0.5s -> increase trong counter
    wire       w_half_sec_pulse_en;           
    wire [3:0] w_half_sec_pulse_counter;      
    wire       w_half_sec_pulse_counter_srst; 
    wire [1:0] w_state;
    
    morse_code_decoder u_decoder (
        .letter_code_i     (letter_code_i),
        .letter_space_en_i (letter_space_en_i),
        .word_space_en_i   (word_space_en_i),
        .code_o            (w_code_comb),
        .code_length_o     (w_code_length_comb),
        .space_code_o      (w_space_comb)
    );
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_code_pipe        <= 0;
            r_code_length_pipe <= 0;
            r_space_code_pipe  <= 2'b00;
            r_start_pipe       <= 0;
        end else begin
            r_code_pipe        <= w_code_comb;
            r_code_length_pipe <= w_code_length_comb;
            r_space_code_pipe  <= w_space_comb;
            r_start_pipe       <= start_i; 
        end
    end
 half_second_pulse #(
        .P_COUNT_MAX(49)                      // ??m 50 chu k? clock cho mô ph?ng
    ) u_pulse_gen (
        .clk                 (clk),
        .rst_n               (rst_n),
        .enable_i            (w_half_sec_pulse_en),
        .half_second_pulse_o (w_half_sec_pulse)
    );
 half_sec_pull_counter u_counter (
        .clk                     (clk),
        .rst_n                   (rst_n),
        .srst_i                  (w_half_sec_pulse_counter_srst), // Xóa b? ??m khi chuy?n state
        .increase_i              (w_half_sec_pulse),              // T?ng ??m khi có xung 0.5s
        .half_sec_pull_counter_o (w_half_sec_pulse_counter)
       );
 fsm_controller u_fsm (
        .clk                           (clk),
        .rst_n                         (rst_n),
        // Pipe stage 1
        .start_i                       (r_start_pipe),
        .code_i                        (r_code_pipe),
        .code_length_i                 (r_code_length_pipe),
        .space_code_i                  (r_space_code_pipe),
        // counter va pluse
        .half_sec_pulse_i              (w_half_sec_pulse),
        .half_sec_pulse_counter_i      (w_half_sec_pulse_counter),
        .half_sec_pulse_counter_srst_o (w_half_sec_pulse_counter_srst),
        .state_o                       (w_state),
        .half_sec_pulse_en_o           (w_half_sec_pulse_en)
    );
  morse_output_sync u_output (
        .clk             (clk),
        .rst_n           (rst_n),
        .current_state (w_state),
        .morse_o         (morse_o),
        .busy_o          (busy_o)
    );
   endmodule    