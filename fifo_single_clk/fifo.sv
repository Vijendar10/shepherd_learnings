//module: fifo.sv
`include "define.h"
module fifo #(
    parameter width = 8,
    parameter depth = 8
) (
    input logic                 clk,
    input logic                 rst_n,
    //write port
    input logic                 wr_en,
    input logic [width-1:0]     data_in,
    output logic                full,
    //read port
    input logic                 rd_en,
    output logic [width-1:0]    data_out,
    output logic                empty
);


//fifo 2d reg array
logic [width-1:0] data_mem [depth-1:0];

//reference pointers 
logic [$clog2(depth)-1:0] wr_ptr;
logic [$clog2(depth)-1:0] rd_ptr;

//counter to store byte count
logic [$clog2(depth):0] count;
logic [$clog2(depth):0] count_next;

logic write;
logic read;

assign write = wr_en & !full;
assign read  = rd_en & !empty;

//write data into data_mem
always_ff @( posedge clk or negedge rst_n ) begin : wr_data
    if (!rst_n) begin
        data_mem <= `SD '{default: 0};
    end
    else if (write) begin
        data_mem [wr_ptr] <= `SD data_in; 
    end
end
always_ff @( posedge clk or negedge rst_n ) begin : wr_ptr_logic
    if (!rst_n) begin
        wr_ptr <= `SD 'h0;
    end
    else if (write) begin
        wr_ptr <= `SD wr_ptr + 1;
    end
end

//counter logic 
always_comb begin : counter_next
    case({write,read})
    2'b10   : count_next = count + 1;
    2'b01   : count_next = count - 1;
    default : count_next = count;
    endcase
end
always_ff @(posedge clk or negedge rst_n ) begin : counter
    if (!rst_n) begin
        count <= `SD 'h0;
    end
    else begin
        count <= `SD count_next;
    end 
end

//read data from data memory
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_out <= `SD 'h0; 
    end
    else if (read) begin
        data_out <= `SD data_mem[rd_ptr];
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= `SD 'h0;
    end
    else if (read) begin
        rd_ptr <= `SD rd_ptr + 1 ;
    end
end

assign full  =  (count == depth);
assign empty =  (count == 0);
    
endmodule