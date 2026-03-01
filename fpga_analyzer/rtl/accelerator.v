module parallel_accelerator #(
    parameter CORE_ID = 0
)(
    input  wire         clk,
    input  wire         reset_n,
    input  wire [127:0] data_in,
    input  wire [7:0]   mode,
    input  wire         data_valid,
    output reg  [127:0] result,
    output reg          result_valid
);

    wire [31:0] v0 = data_in[31:0];
    wire [31:0] v1 = data_in[63:32];
    wire [31:0] v2 = data_in[95:64];
    wire [31:0] v3 = data_in[127:96];

    localparam [31:0] CORE_FACTOR = CORE_ID + 1;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            result <= 128'd0;
            result_valid <= 1'b0;
        end else if (data_valid) begin
            case (mode)
                8'd4:   result <= (v0 + v1) * CORE_FACTOR;

                8'd8:   result <= {64'd0, (v1 + v3), (v0 + v2)};

                8'd16:  begin
                    result[31:0]   <= v0 + CORE_ID[31:0];
                    result[63:32]  <= v1 + CORE_ID[31:0];
                    result[95:64]  <= v2 + CORE_ID[31:0];
                    result[127:96] <= v3 + CORE_ID[31:0];
                end

                8'd32:  result <= (v0 * v1) + (v2 * v3);

                8'd64:  result <= {data_in[63:0], data_in[127:64]} ^ CORE_ID[31:0];


                8'd128: result <= v0 + (v1 << 1) + ((v2 << 1) + v2) + (v3 << 2) + CORE_ID[31:0];

                default: result <= data_in ^ CORE_ID[31:0];
            endcase
            result_valid <= 1'b1;
        end else begin
            result_valid <= 1'b0;
        end
    end
endmodule