module resource_manager (
    input wire clk,
    input wire reset_n,
    input wire [9:0] fifo_used,
    output reg [2:0] mode
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mode <= 3'b101;
        end else begin
            if (fifo_used > 900) begin
                mode <= 3'b000;
            end else if (fifo_used > 700) begin
                mode <= 3'b001;
            end else if (fifo_used > 500) begin
                mode <= 3'b010;
            end else if (fifo_used > 300) begin
                mode <= 3'b011;
            end else if (fifo_used > 100) begin
                mode <= 3'b100;
            end else begin
                mode <= 3'b101;
            end
        end
    end
endmodule