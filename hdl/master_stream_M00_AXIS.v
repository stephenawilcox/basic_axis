`timescale 1 ns / 1 ps
module master_stream_M00_AXIS #
(
    // Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
    parameter integer C_M_AXIS_TDATA_WIDTH	= 32
)
(
    // Global ports
    input wire  M_AXIS_ACLK,
    // 
    input wire  M_AXIS_ARESET,
    // Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
    output reg  M_AXIS_TVALID,
    // TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
    output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
    // TREADY indicates that the slave can accept a transfer in the current cycle.
    input wire  M_AXIS_TREADY,

    //other
    input wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA_IN,
    output reg fifo_rd_en,
    input wire fifo_empty
);

assign M_AXIS_TDATA = M_AXIS_TDATA_IN;

// states IDLE, READ, SEND
localparam IDLE = 3'b001, READ = 3'b010, SEND = 3'b100;

reg [2:0] current_state, next_state;
// STATE TRANSITION LOGIC
always @ (*) begin
	case (current_state)
		IDLE: begin
			next_state = fifo_empty ? IDLE : READ;
		end
		READ: begin
			next_state = SEND;
		end
		SEND: begin
			next_state = (M_AXIS_TVALID & M_AXIS_TREADY) ? (fifo_empty ? IDLE : SEND) : SEND;
		end
		default:
			next_state <= IDLE;
	endcase
end


always @ (posedge M_AXIS_ACLK) begin
	if (M_AXIS_ARESET) begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

// STATE OUTPUT LOGIC
always @ (*) begin
	M_AXIS_TVALID = current_state[2];
	fifo_rd_en = fifo_empty ? 1'b0 : (current_state[1] ? 1'b1 : (M_AXIS_TVALID & M_AXIS_TREADY));
end

endmodule
