`timescale 1ns / 1ps

module tb_top_morse_code_pipeline;

    // Khai báo tín hi?u
    reg        clk;
    reg        rst_n;
    reg        start_i;
    reg  [5:0] letter_code_i;
    reg        letter_space_en_i;
    reg        word_space_en_i;
    
    wire       morse_o;
    wire       busy_o;

    localparam CLK_PERIOD = 10;
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    reg [39:0] observed_pattern; 
    integer    pattern_len;
    time       start_time, end_time, duration;

    // Kh?i t?o DUT
    top_morse_code_pipeline dut (
        .clk               (clk),
        .rst_n             (rst_n),
        .start_i           (start_i),
        .letter_code_i     (letter_code_i),
        .letter_space_en_i (letter_space_en_i),
        .word_space_en_i   (word_space_en_i),
        .morse_o           (morse_o),
        .busy_o            (busy_o)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    // B?t mã Morse
    always @(posedge morse_o) begin
        start_time = $time;
    end

    always @(negedge morse_o) begin
        end_time = $time;
        duration = end_time - start_time;
        
        if (duration > 1200) begin
            $write("-");
            case (pattern_len)
                0: observed_pattern[39:32] = "-";
                1: observed_pattern[31:24] = "-";
                2: observed_pattern[23:16] = "-";
                3: observed_pattern[15:8]  = "-";
                4: observed_pattern[7:0]   = "-";
            endcase
        end else begin
            $write(".");
            case (pattern_len)
                0: observed_pattern[39:32] = ".";
                1: observed_pattern[31:24] = ".";
                2: observed_pattern[23:16] = ".";
                3: observed_pattern[15:8]  = ".";
                4: observed_pattern[7:0]   = ".";
            endcase
        end
        pattern_len = pattern_len + 1;
    end

    // Task truy?n ch?
    task send_char;
        input [5:0]  code;
        input        l_space;
        input        w_space;
        input [7:0]  char_name;        
        input [39:0] expected_pattern; 
        begin
            observed_pattern = "     "; 
            pattern_len      = 0;
            
            $write("[Time: %0t ps] Kiem tra ky tu '%c': ", $time, char_name);
            
            letter_code_i     <= code;
            letter_space_en_i <= l_space;
            word_space_en_i   <= w_space;
            
            @(posedge clk);
            start_i <= 1'b1;
            @(posedge clk);
            start_i <= 1'b0;
            
            // ??i 3 chu k? ?? tín hi?u truy?n qua 2 t?ng Pipeline tr??c khi soi c? busy_o
            repeat(3) @(posedge clk); 
            wait(busy_o == 1'b0);
            
            if (observed_pattern == expected_pattern) begin
                $display("  -> [PASS]");
                pass_count = pass_count + 1;
            end else begin
                $display("  -> [FAIL] Expected: '%s', Got: '%s'", expected_pattern, observed_pattern);
                fail_count = fail_count + 1;
            end
            
            #(CLK_PERIOD * 10);
        end
    endtask

    // Hàm quy ??i
    function [5:0] ascii_to_code;
        input [7:0] char;
        begin
            if (char >= "A" && char <= "Z")      ascii_to_code = char - "A";
            else if (char >= "a" && char <= "z") ascii_to_code = char - "a";
            else if (char >= "1" && char <= "9") ascii_to_code = char - "1" + 6'd26;
            else if (char == "0")                ascii_to_code = 6'd35;
            else                                 ascii_to_code = 6'd63; 
        end
    endfunction

    function [39:0] get_expected_morse;
        input [7:0] char;
        begin
            case(char)
                "A", "a": get_expected_morse = ".-   ";
                "B", "b": get_expected_morse = "-... ";
                "C", "c": get_expected_morse = "-.-. ";
                "D", "d": get_expected_morse = "-..  ";
                "E", "e": get_expected_morse = ".    ";
                "F", "f": get_expected_morse = "..-. ";
                "G", "g": get_expected_morse = "--.  ";
                "H", "h": get_expected_morse = ".... ";
                "I", "i": get_expected_morse = "..   ";
                "L", "l": get_expected_morse = ".-.. ";
                "M", "m": get_expected_morse = "--   ";
                "N", "n": get_expected_morse = "-.   ";
                "O", "o": get_expected_morse = "---  ";
                "S", "s": get_expected_morse = "...  ";
                "T", "t": get_expected_morse = "-    ";
                "U", "u": get_expected_morse = "..-  ";
                // B? sung các kı t? khác n?u c?n...
                default : get_expected_morse = "     ";
            endcase
        end
    endfunction

    // K?ch b?n 30 ch? cái
    reg [8*39:1] paragraph = "HELLO HCMUT I AM HIEU SOC TESTING END  "; 
    
    integer i;
    reg [7:0] current_char, next_char;
    reg l_space, w_space;
    
    initial begin
        clk               = 0;
        rst_n             = 0;
        start_i           = 0;
        letter_code_i     = 6'd0;
        letter_space_en_i = 0;
        word_space_en_i   = 0;

        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 5);

        $display("\n=======================================================");
        $display("   BAT DAU TRUYEN VAN BAN (PIPELINED STRING PARSER)");
        $display("   Van ban: %s", paragraph);
        $display("=======================================================\n");

        for (i = 39; i > 0; i = i - 1) begin
            current_char = paragraph[i*8 -: 8]; 

            if (current_char != " ") begin
                if (i > 1) 
                    next_char = paragraph[(i-1)*8 -: 8];
                else       
                    next_char = " "; 

                if (next_char == " ") begin
                    l_space = 0; 
                    w_space = 1;
                end else begin
                    l_space = 1; 
                    w_space = 0;
                end

                send_char(ascii_to_code(current_char), l_space, w_space, current_char, get_expected_morse(current_char));
            end
        end

        $display("\n=======================================================");
        $display("                   KET QUA TONG HOP                    ");
        $display(" So case PASS  : %0d", pass_count);
        $display(" So case FAIL  : %0d", fail_count);
        $display("=======================================================\n");
        $finish;
    end

endmodule
