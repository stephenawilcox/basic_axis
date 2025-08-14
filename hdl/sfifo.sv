/*
 *Syncronous FIFO 
 */
`timescale 1 ns / 1 ps

module sfifo #(
    parameter integer num_entries = 8,
    parameter integer num_data_bits = 32
    )
    (
    input clk,
    input reset,
    input fifo_rd_en,
    input fifo_wr_en,
    input [num_data_bits-1:0] fifo_in,
    output reg [num_data_bits-1:0] fifo_out,
    output fifo_full,
    output fifo_empty
    );

    localparam num_ptr_bits = $clog2(num_entries);

    reg [num_data_bits-1:0] data [num_entries];
    logic [num_ptr_bits:0] rd_ptr;
    logic [num_ptr_bits:0] wr_ptr;

    assign fifo_full = (rd_ptr[num_ptr_bits] != wr_ptr[num_ptr_bits]) && (rd_ptr[num_ptr_bits-1:0] == wr_ptr[num_ptr_bits-1:0]);
    assign fifo_empty = (rd_ptr == wr_ptr);


    always @(posedge clk) begin
        if(reset) begin
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