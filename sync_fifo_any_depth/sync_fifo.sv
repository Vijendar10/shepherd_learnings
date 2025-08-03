//This module is sync fifo which can support non power of 2 depth 
//module : sync_fifo.sv
//Date   : 28 jul 2025

`include "define.h"

module sync_fifo # (
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 10 //can be any positive integer
)
(
    input  logic                    clk,
    input  logic                    rst_n,
    //write port
    input  logic                    wr_en,
    input  logic  [DATA_WIDTH-1:0]  wr_data,
    //read port
    input  logic                    rd_en,
    output logic  [DATA_WIDTH-1:0]  rd_data,
    //empty,full conditions
    output logic                    empty,
    output logic                    full 
);

logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];

//rd_ptr,wr_ptr
logic [$clog2(DEPTH)-1:0] rd_ptr;
logic [$clog2(DEPTH)-1:0] wr_ptr;
logic [$clog2(DEPTH)-1:0] rd_ptr_d;
logic [$clog2(DEPTH)-1:0] wr_ptr_d;
//counter logic 
logic [$clog2(DEPTH):0]   count;
logic [$clog2(DEPTH):0]   count_d;


//write transaction
always_comb begin
    wr_ptr_d = wr_ptr;
    if (wr_en && !full) begin
        if(wr_ptr == DEPTH-1) begin
            wr_ptr_d = '0;
        end
        else begin
            wr_ptr_d = wr_ptr + 1;     
        end    
    end   
end
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr      <=  `SD '0;      
    end
    else begin
        wr_ptr      <=  `SD wr_ptr_d;  
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem <= `SD '{default:0};
    end
    else if (wr_en && !full) begin
        mem[wr_ptr] <= `SD wr_data;
    end
end

//read Transaction
always_comb begin
    rd_ptr_d = rd_ptr ;
    if (rd_en && !empty) begin
        if (rd_ptr == DEPTH-1) begin
            rd_ptr_d = '0;
        end
        else begin
            rd_ptr_d = rd_ptr + 1;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= `SD '0;
    end
    else begin
        rd_ptr  <= `SD rd_ptr_d;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_data <= `SD 0;
    end
    else if (rd_en && !empty) begin
        rd_data <= `SD mem[rd_ptr];
    end
end

always_comb begin
    count_d = count;
    case ({wr_en &!full,rd_en & !empty})
        2'b10  : count_d = count + 1; 
        2'b01  : count_d = count - 1;
        default: count_d = count;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= `SD '0;
    end
    else begin
        count <= `SD count_d;
    end
end

assign empty = ~|count;
assign full  = count == DEPTH;

endmodule
