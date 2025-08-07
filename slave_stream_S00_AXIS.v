`timescale 1 ns / 1 ps
module slave_stream_S00_AXIS #
(
    // AXI4Stream sink: Data Width
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32
)
(
    // AXI4Stream sink: Clock
    input wire  S_AXIS_ACLK,
    // AXI4Stream sink: Reset
    input wire  S_AXIS_ARESETN,
    // Ready to accept data in
    output reg  S_AXIS_TREADY,
    // Data in
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
    // Data is in valid
    input wire  S_AXIS_TVALID,

    //other
    output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA_OUT,
    output reg fifo_wr_en,
    input wire fifo_full
);


// states IDLE, BUSY
localparam IDLE = 1'b0, BUSY = 1'b1;

reg current_state, next_state;

assign S_AXIS_TDATA_OUT = S_AXIS_TDATA; 

//STATE TRANSITION LOGIC
always @ (*) begin
    next_state = fifo_full ? IDLE : (S_AXIS_TVALID ? BUSY : IDLE);
end

always @ (posedge S_AXIS_ACLK) begin
    if (!S_AXIS_ARESETN) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

//OUTPUT LOGIC
always @ (*) begin
    S_AXIS_TREADY = fifo_full ? 1'b0 : 1'b1;
    fifo_wr_en = (S_AXIS_TVALID & S_AXIS_TREADY);
end

endmodule
