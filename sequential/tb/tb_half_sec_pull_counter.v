`timescale 1ns / 1ps

module tb_half_sec_pull_counter;

    localparam CLK_PERIOD = 10; // Chu k? clock 10ns

    reg        clk;
    reg        rst_n;
    reg        srst_i;
    reg        increase_i;
    wire [3:0] half_sec_pull_counter_o;

    // Kh?i t?o Device Under Test (DUT)
    half_sec_pull_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .srst_i(srst_i),
        .increase_i(increase_i),
        .half_sec_pull_counter_o(half_sec_pull_counter_o)
    );

    // T?o xung nh?p clock liên t?c
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        // Kh?i t?o tr?ng thái ban ??u
        clk        = 1'b0;
        rst_n      = 1'b0; // Kéo reset b?t ??ng b? m?c th?p
        srst_i     = 1'b0;
        increase_i = 1'b0;

        // 1. Nh? reset b?t ??ng b?
        #(CLK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLK_PERIOD * 2);

        // 2. Kích t?ng 3 l?n (??m 0 -> 1 -> 2 -> 3)
        repeat (3) begin
            @(posedge clk);
            increase_i = 1'b1;
            @(posedge clk);
            increase_i = 1'b0;
            #(CLK_PERIOD * 2);
        end

        // 3. Gi? nguyên giá tr? khi increase_i = 0
        #(CLK_PERIOD * 5);

        // 4. Kích t?ng thêm 4 l?n (??m 3 -> 4 -> 5 -> 6 -> 7)
        repeat (4) begin
            @(posedge clk);
            increase_i = 1'b1;
            @(posedge clk);
            increase_i = 1'b0;
            #(CLK_PERIOD * 2);
        end

        // 5. Ki?m tra Reset ??ng b? (srst_i = 1)
        @(posedge clk);
        srst_i = 1'b1;
        @(posedge clk);
        srst_i = 1'b0;

        // 6. Ch? vài chu k? r?i k?t thúc
        #(CLK_PERIOD * 5);
        $finish;
    end

    // Theo dõi giá tr? b? ??m xu?t ra Console khi có thay ??i
    always @(posedge clk) begin
        $display("[Time %0t ps] srst_i = %b, increase_i = %b, counter_o = %0d", 
                 $time, srst_i, increase_i, half_sec_pull_counter_o);
    end

endmodule
