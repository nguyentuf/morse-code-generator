`timescale 1ns / 1ps

module tb_half_second_pulse;

    localparam P_COUNT_MAX      = 49;
    localparam P_COUNT_BITWIDTH = $clog2(P_COUNT_MAX) + 1;
    localparam CLK_PERIOD       = 10;

    reg  clk;
    reg  rst_n;
    reg  enable_i;
    wire half_second_pulse_o;

    // Bi?n ??m chu k? clock
    integer clk_cnt;

    half_second_pulse #(
        .P_COUNT_MAX(P_COUNT_MAX),
        .P_COUNT_BITWIDTH(P_COUNT_BITWIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable_i(enable_i),
        .half_second_pulse_o(half_second_pulse_o)
    );

    // T?o xung clock
    always #(CLK_PERIOD / 2) clk = ~clk;

    // B? ??m chu k? clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= 0;
        end else if (enable_i) begin
            clk_cnt <= clk_cnt + 1;
        end else begin
            clk_cnt <= 0; // Reset v? 0 khi t?t enable ?? ??ng b? v?i DUT
        end
    end

    // Theo dõi và in chu k? khi có xung tick
    always @(posedge clk) begin
        if (half_second_pulse_o) begin
            $display("[TICK] Xuat hien tai chu ky clock thu: %0d (Time: %0t ps)", clk_cnt, $time);
        end
    end

    initial begin
        clk      = 1'b0;
        rst_n    = 1'b0;
        enable_i = 1'b0;

        #(CLK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLK_PERIOD * 2);

        // B?t ??u ??m (ch?y 120 chu k?)
        enable_i = 1'b1;
        #(CLK_PERIOD * 120);

        // T?t th? nghi?m ki?m tra reset bi?n ??m
        enable_i = 1'b0;
        #(CLK_PERIOD * 10);

        // B?t l?i
        enable_i = 1'b1;
        #(CLK_PERIOD * 60);

        $finish;
    end

endmodule
