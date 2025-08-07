/*
 *Syncronous FIFO 
 */
`timescale 1 ns / 1 ps

module sfifo (clk, resetn, fifo_rd_en, fifo_wr_en, fifo_in, fifo_out, fifo_full, fifo_empty);
    //FIFO depth = B - B * freq_rd / freq_wr
    //B num data bits
    parameter num_entries = 8;
    parameter num_data_bits = 32;
    localparam num_ptr_bits = $clog2(num_entries);

    input clk;
    input resetn;
    input fifo_rd_en;
    input fifo_wr_en;
    input [num_data_bits-1:0] fifo_in;
    output reg [num_data_bits-1:0] fifo_out;
    output fifo_full;
    output fifo_empty;

    reg [num_data_bits-1:0] data [num_entries];
    logic [num_ptr_bits:0] rd_ptr;
    logic [num_ptr_bits:0] wr_ptr;

    assign fifo_full = (rd_ptr[num_ptr_bits] != wr_ptr[num_ptr_bits]) && (rd_ptr[num_ptr_bits-1:0] == wr_ptr[num_ptr_bits-1:0]);
    assign fifo_empty = (rd_ptr == wr_ptr);


    always @(posedge clk) begin
        if(!resetn) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            fifo_out <= 0;
        end
        else begin
            if(fifo_rd_en && !fifo_empty) begin
                fifo_out <= data[rd_ptr[num_ptr_bits-1:0]];
                rd_ptr <= rd_ptr + 1;
            end
            if(fifo_wr_en & !fifo_full) begin
            data[wr_ptr[num_ptr_bits-1:0]] <= fifo_in;
            wr_ptr <= wr_ptr + 1;
        end
        end
    end

endmodule