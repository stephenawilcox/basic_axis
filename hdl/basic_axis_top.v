`timescale 1 ns / 1 ps
module basic_axis_top #
	(
		// Users to add parameters here
		parameter integer FIFO_ENTRIES = 64,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
		//input wire  clk,
		//input wire resetn,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_areset,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_areset,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		input wire  m00_axis_tready
	);

	wire [C_S00_AXIS_TDATA_WIDTH-1:0] in_axis_data, out_axis_data;
	wire w_fifo_wr_en, w_fifo_rd_en, w_fifo_full, w_fifo_empty;


// Instantiation of Axi Bus Interface S00_AXIS
	slave_stream_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) slave_stream_S00_AXIS_inst (
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESET(s00_axis_areset),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TVALID(s00_axis_tvalid),
		.S_AXIS_TDATA_OUT(in_axis_data),
		.fifo_wr_en(w_fifo_wr_en),
		.fifo_full(w_fifo_full)
	);

// Instantiation of Axi Bus Interface M00_AXIS
	master_stream_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) master_stream_M00_AXIS_inst (
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESET(m00_axis_areset),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TREADY(m00_axis_tready),
		.M_AXIS_TDATA_IN(out_axis_data),
		.fifo_rd_en(w_fifo_rd_en),
		.fifo_empty(w_fifo_empty)
	);


//Instantiation of sync FIFO
	sfifo # (.num_entries(FIFO_ENTRIES), .num_data_bits(C_M00_AXIS_TDATA_WIDTH)) sfifo_inst (
		.clk(s00_axis_aclk),
		.reset(s00_axis_areset),
		.fifo_rd_en(w_fifo_rd_en),
		.fifo_wr_en(w_fifo_wr_en),
		.fifo_in(in_axis_data),
		.fifo_out(out_axis_data),
		.fifo_full(w_fifo_full),
		.fifo_empty(w_fifo_empty)
	);



	endmodule