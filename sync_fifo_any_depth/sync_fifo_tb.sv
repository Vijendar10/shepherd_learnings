`timescale 1ns/1ps

module sync_fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 10;

    logic clk, rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data, rd_data;
    logic empty, full;

    // Reference model
    logic [DATA_WIDTH-1:0] ref_mem [DEPTH-1:0];
    int wr_idx, rd_idx, error_count;

    // DUT instantiation
    sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .full(full)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        wr_idx = 0;
        rd_idx = 0;
        error_count = 0;

        // Reset
        #15;
        rst_n = 1;

        // Write phase
        repeat (DEPTH) begin
            @(negedge clk);
            if (!full) begin
                wr_en = 1;
                wr_data = $random;
                ref_mem[wr_idx] = wr_data;
                wr_idx++;
            end
        end
        wr_en = 0;

        // Read phase
        repeat (DEPTH) begin
            @(negedge clk);
            if (!empty) begin
                rd_en = 1;
                @(posedge clk); // Wait for rd_data to update
                #2; // Allow for `SD` delay in design
                rd_en = 0;
                if (rd_data !== ref_mem[rd_idx]) begin
                    $display("ERROR at idx %0d: expected %0h, got %0h", rd_idx, ref_mem[rd_idx], rd_data);
                    error_count++;
                end else begin
                    $display("PASS: idx %0d, data %0h", rd_idx, rd_data);
                end
                rd_idx++;
            end
        end

        // Results
        if (error_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED with %0d errors", error_count);

        #10;
    end
endmodule