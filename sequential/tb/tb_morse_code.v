`timescale 1ns / 1ps


module tb_top_morse_code;

    // Khai báo các tín hi?u
    reg        clk;
    reg        rst_n;
    reg        start_i;
    reg  [5:0] letter_code_i;
    reg        letter_space_en_i;
    reg        word_space_en_i;
    
    wire       morse_o;
    wire       busy_o;

    // Chu k? clock = 10ns
    localparam CLK_PERIOD = 10;
    
    // =========================================================================
    // BI?N PH? TR? CHO VI?C T? ??NG KI?M TRA (AUTO-CHECKING)
    // =========================================================================
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Thanh ghi 40-bit ?? l?u chu?i 5 ký t? (m?i ký t? 8-bit ASCII)
    reg [39:0] observed_pattern; 
    integer    pattern_len;
    time       start_time, end_time, duration;

    // Kh?i t?o Top Module
    top_morse_code dut (
        .clk               (clk),
        .rst_n             (rst_n),
        .start_i           (start_i),
        .letter_code_i     (letter_code_i),
        .letter_space_en_i (letter_space_en_i),
        .word_space_en_i   (word_space_en_i),
        .morse_o           (morse_o),
        .busy_o            (busy_o)
    );

    // T?o xung clock
    always #(CLK_PERIOD/2) clk = ~clk;

    // =========================================================================
    // KH?I MONITOR: B?T MÃ MORSE T? ?? R?NG XUNG & L?U VÀO BUFFER
    // =========================================================================
    always @(posedge morse_o) begin
        start_time = $time;
    end

    always @(negedge morse_o) begin
        end_time = $time;
        duration = end_time - start_time;
        
        // ?o ?? r?ng xung: > 1200ns là Dash (-), ng??c l?i là Dot (.)
        if (duration > 1200) begin
            $write("-");
            // Ghi ký t? '-' vào ?úng v? trí trong thanh ghi chu?i
            case (pattern_len)
                0: observed_pattern[39:32] = "-";
                1: observed_pattern[31:24] = "-";
                2: observed_pattern[23:16] = "-";
                3: observed_pattern[15:8]  = "-";
                4: observed_pattern[7:0]   = "-";
            endcase
        end else begin
            $write(".");
            // Ghi ký t? '.' vào ?úng v? trí trong thanh ghi chu?i
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

    // =========================================================================
    // TASK G?I KÝ T? VÀ KI?M TRA (CHECKER)
    // =========================================================================
    task send_char;
        input [5:0]    code;
        input          l_space;
        input          w_space;
        input [8*15:1] char_name;        // Tên hi?n th? (T?i ?a 15 ký t?)
        input [39:0]   expected_pattern; // Chu?i mong ??i (Chính xác 5 ký t?)
        begin
            // Xóa buffer tr??c khi nh?n mã m?i (Ghi 5 d?u cách tr?ng)
            observed_pattern = "     "; 
            pattern_len      = 0;
            
            $write("[Time: %0t ps] Kiem tra %s: ", $time, char_name);
            
            // Dùng Non-blocking (<=) ?? ??ng b? hóa, tránh Race Condition
            letter_code_i     <= code;
            letter_space_en_i <= l_space;
            word_space_en_i   <= w_space;
            
            // Kích xung start
            @(posedge clk);
            start_i <= 1'b1;
            @(posedge clk);
            start_i <= 1'b0;
            
            // ??i FSM b?t ??u x? lý r?i ch? nó xong (busy_o r?t xu?ng 0)
            @(posedge clk); 
            wait(busy_o == 1'b0);
            
            // T? ??ng ki?m tra sau khi FSM phát xong
            if (observed_pattern == expected_pattern) begin
                $display("  -> [PASS]");
                pass_count = pass_count + 1;
            end else begin
                $display("  -> [FAIL] Expected: '%s', Got: '%s'", expected_pattern, observed_pattern);
                fail_count = fail_count + 1;
            end
            
            // Ch? thêm 1 kho?ng nh? tr??c khi test ca ti?p theo
            #(CLK_PERIOD * 10);
        end
    endtask

    // =========================================================================
    // K?CH B?N TEST (20 Cases)
    // =========================================================================
    initial begin
        // Kh?i t?o
        clk               = 0;
        rst_n             = 0;
        start_i           = 0;
        letter_code_i     = 6'd0;
        letter_space_en_i = 0;
        word_space_en_i   = 0;

        // Reset h? th?ng
        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 5);

        $display("\n=======================================================");
        $display("   BAT DAU TESTBENCH MORSE CODE (AUTO-CHECKING)");
        $display("=======================================================\n");

        // Tham s?: send_char( Mã, L_Space, W_Space, "Tên", "Chu?i mong ??i (?úng 5 ký t?)" )
        // L?u ý: Chu?i mong ??i ph?i bù thêm phím cách (space) cho ?? 5 ký t?

        // --- Nhóm 1: Các nguyên âm và ch? cái ph? bi?n ---
        send_char(6'd0,  1, 0, "Chu A", ".-   "); 
        send_char(6'd4,  1, 0, "Chu E", ".    "); 
        send_char(6'd8,  1, 0, "Chu I", "..   "); 
        send_char(6'd14, 1, 0, "Chu O", "---  "); 
        send_char(6'd20, 1, 0, "Chu U", "..-  "); 

        // --- Nhóm 2: Các ch? cái ?? dài t?i ?a (4 ph?n t?) ---
        send_char(6'd1,  1, 0, "Chu B", "-... "); 
        send_char(6'd2,  1, 0, "Chu C", "-.-. "); 
        send_char(6'd5,  1, 0, "Chu F", "..-. "); 
        send_char(6'd16, 1, 0, "Chu Q", "--.- "); 
        send_char(6'd25, 1, 0, "Chu Z", "--.. "); 

        // --- Nhóm 3: Test kho?ng ng?t t? (Word Space) - Mô ph?ng SOS ---
        $display("\n--- Kiem tra tu SOS kem Word Space ---");
        send_char(6'd18, 1, 0, "Chu S", "...  "); // Letter space
        send_char(6'd14, 1, 0, "Chu O", "---  "); // Letter space
        send_char(6'd18, 0, 1, "Chu S (End)", "...  "); // Word space (K?t thúc t?)

        // --- Nhóm 4: Các ch? s? (5 ph?n t?) ---
        $display("\n--- Kiem tra Chu So ---");
        send_char(6'd26, 1, 0, "So 1", ".----"); 
        send_char(6'd28, 1, 0, "So 3", "...--"); 
        send_char(6'd30, 1, 0, "So 5", "....."); 
        send_char(6'd32, 1, 0, "So 7", "--..."); 
        send_char(6'd34, 1, 0, "So 9", "----."); 
        send_char(6'd35, 1, 0, "So 0", "-----"); // Edge case default

        // --- Nhóm 5: M?t s? ch? cái ng?u nhiên còn l?i ---
        $display("\n--- Kiem tra Bo sung ---");
        send_char(6'd19, 0, 0, "Chu T", "-    "); // Không space
        send_char(6'd12, 1, 0, "Chu M", "--   "); 

        $display("\n=======================================================");
        $display("                   KET QUA TONG HOP                    ");
        $display("=======================================================");
        $display(" Tong so case  : 20");
        $display(" So case PASS  : %0d", pass_count);
        $display(" So case FAIL  : %0d", fail_count);
        if (fail_count == 0)
            $display(" TRANG THAI    : THANH CONG TOAN TAP!");
        else
            $display(" TRANG THAI    : CO LOI XAY RA, KIEM TRA LAI!");
        $display("=======================================================\n");
        
        $finish;
    end

endmodule
