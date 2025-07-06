//module: fifo_tb.sv
`timescale 1ns/1ps
module fifo_tb ();

parameter width = 8;
parameter depth = 8;

logic                 clk;
logic                 rst_n;
logic                 wr_en;
logic [width-1:0]     data_in;
logic                 full;
logic                 rd_en;
logic [width-1:0]     data_out;
logic                 empty;

integer wr_idx;
integer rd_idx;
integer error_count;

//ref model
logic [width-1:0] ref_mem [depth];

//instantiate the design
fifo dut (.*);

localparam delay = 10 ;

//clock generation
always # (delay) clk = ~clk;

initial begin
    clk         = 0;
    rst_n       = 0;
    wr_en       = 0;
    rd_en       = 0;
    data_in     = 0;
    wr_idx      = 0;
    rd_idx      = 0;
    error_count = 0;
    #15;
    rst_n       = 1;

//write data into fifo 
repeat(depth) begin
    @(negedge clk);
    if (!full) begin
        wr_en = 1;
        data_in = $random;
        ref_mem[wr_idx] = data_in;
        wr_idx++;
    end
end
@(negedge clk);
wr_en = 0;

//read data from fifo 
repeat(depth) begin
    @(negedge clk);
    if (!empty) begin
        rd_en = 1;
    end
    @(posedge clk);
    #2; 
    if (data_out !==ref_mem[rd_idx]) begin
        $display("ERROR AT INDEX %0d: expected %0d, received %0d",rd_idx,ref_mem[rd_idx],data_out);
        error_count += 1;
    end
    rd_idx++;
end

//print result
if (error_count == 0) begin
    $display ("TEST PASSED");
end
else begin
    $display ("TEST FAILED");
end

end

endmodule