module adaptive (
    input  wire         clk,
    input  wire         reset_n,
    input  wire [127:0] data_in_bus,
    input  wire [7:0]   mode,
    input  wire         data_valid,
    output reg  [127:0] data_out_bus,
    output reg          data_out_valid,
    output wire         alert_led
);

    wire [135:0] fifo_in = {mode, data_in_bus};
    wire [135:0] fifo_out;
    
    wire [9:0]   fifo_usedw;
    wire         fifo_empty, fifo_rdreq;
    
    my_fifo_136 fifo_inst (
        .clock(clk), 
        .reset_n(reset_n),
        .data(fifo_in), 
        .rdreq(fifo_rdreq),
        .wrreq(data_valid), 
        .empty(fifo_empty), 
        .q(fifo_out), 
        .usedw(fifo_usedw)
    );

    assign fifo_rdreq = !fifo_empty;
    assign alert_led  = (fifo_usedw > 10'd800);

    wire [127:0] current_data = fifo_out[127:0];
    wire [7:0]   current_mode = fifo_out[135:128];

    wire [127:0] core_results [23:0];
    wire [23:0]  core_valids;

    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin : gen_cores
            parallel_accelerator #( .CORE_ID(i) ) core_inst (
                .clk(clk), 
                .reset_n(reset_n), 
                .data_in(current_data),
                .mode(current_mode), 
                .data_valid(fifo_rdreq),
                .result(core_results[i]), 
                .result_valid(core_valids[i])
            );
        end
    endgenerate

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out_bus <= 0;
            data_out_valid <= 0;
        end else begin
            if (core_valids[0] && core_valids[12] && core_valids[23]) begin
                data_out_bus <= core_results[0] ^ core_results[12] ^ core_results[23];
                data_out_valid <= 1'b1;
            end else begin
                data_out_bus <= 128'd0;
                data_out_valid <= 1'b0;
            end
        end
    end
endmodule

module my_fifo_136 (
    input  wire [135:0] data,
    input  wire         clock,
    input  wire         reset_n,
    input  wire         rdreq,
    input  wire         wrreq,
    output reg  [135:0] q,
    output wire         empty,
    output wire [9:0]   usedw
);
    reg [135:0] mem [0:1023];
    reg [9:0] wr_ptr, rd_ptr;
    reg [10:0] count;
    assign empty = (count == 0);
    assign usedw = count[9:0];
    integer j;
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr <= 0; rd_ptr <= 0; count <= 0; q <= 0;
            for (j = 0; j < 1024; j = j + 1) mem[j] <= 0;
        end else begin
            if (wrreq && count < 1024) begin mem[wr_ptr] <= data; wr_ptr <= wr_ptr + 1; end
            if (rdreq && !empty) begin q <= mem[rd_ptr]; rd_ptr <= rd_ptr + 1; end
            if (wrreq && !rdreq) count <= count + 1;
            else if (!wrreq && rdreq) count <= count - 1;
        end
    end
endmodule