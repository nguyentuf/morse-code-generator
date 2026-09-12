`timescale 1ns / 1ps

module fsm_controller(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start_i,
    input  wire [4:0] code_i,
    input  wire [2:0] code_length_i,
    input  wire [1:0] space_code_i,
    input  wire       half_sec_pulse_i,
    input  wire [3:0] half_sec_pulse_counter_i,

    output reg        half_sec_pulse_counter_srst_o,
    output reg  [1:0] state_o, 
    output reg        half_sec_pulse_en_o
);

    localparam IDLE         = 2'd0;
    localparam LETTER_ON    = 2'd1;
    localparam LETTER_OFF   = 2'd2;
    localparam SPACE_OFF    = 2'd3;

    reg [1:0] current_state, next_state;

    reg [4:0] shift_reg;
    reg [2:0] bit_count;



    wire current_bit = shift_reg[4]; 
// ondone=1 <=> dot(0) va xung 0,5s hay dash(1) xung 1.5s   
    wire on_done = half_sec_pulse_i & ((~current_bit & (half_sec_pulse_counter_i == 4'd0)) | 
                                       ( current_bit & (half_sec_pulse_counter_i == 4'd2)));
                                       
//offdone = 1 <=>  counter==0 & 0.5s
    wire off_done = half_sec_pulse_i & (half_sec_pulse_counter_i == 4'd0);
    
    // Letter Space (10) -> counter == 2, Word Space (11) -> counter == 6
    wire space_done = half_sec_pulse_i & ((space_code_i == 2'b10 & half_sec_pulse_counter_i == 4'd2) | 
                                          (space_code_i == 2'b11 & half_sec_pulse_counter_i == 4'd6));

    wire is_last_bit = (bit_count == code_length_i - 1'b1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 5'b0;
            bit_count <= 3'd0;
        end else if (current_state == IDLE && start_i) begin
            shift_reg <= code_i; 
            bit_count <= 3'd0;
        end else if (current_state == LETTER_ON && on_done) begin
            shift_reg <= {shift_reg[3:0], 1'b0}; 
            bit_count <= bit_count + 1'b1;       
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state; 
        
        case (current_state)
            IDLE: begin
                if (start_i) 
                    next_state = LETTER_ON;
            end
            
            LETTER_ON: begin
                if (on_done) begin
                    if (is_last_bit) begin
                        if (space_code_i != 2'b00) 
                            next_state = SPACE_OFF;
                        else 
                            next_state = IDLE;
                    end else begin
                        next_state = LETTER_OFF;
                    end
                end
            end
            
            LETTER_OFF: begin
                if (off_done)
                    next_state = LETTER_ON;
            end
            
            SPACE_OFF: begin
                if (space_done)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
        state_o = current_state;
        half_sec_pulse_en_o = (current_state != IDLE) | start_i;
        half_sec_pulse_counter_srst_o = (current_state != next_state);
    end

endmodule
