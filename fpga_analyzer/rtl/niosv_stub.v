module niosvfifo (
    input  wire       clk_clk,
    input  wire       reset_reset_n,
    input  wire [9:0] pio_fifo_status_external_connection_export,
    output wire [2:0] pio_mode_ctrl_external_connection_export,
    output wire       pio_led_alert2_external_connection_export
);

    assign pio_mode_ctrl_external_connection_export = (pio_fifo_status_external_connection_export > 800) ? 3'd7 : 3'd1;
    assign pio_led_alert2_external_connection_export = (pio_fifo_status_external_connection_export > 800);

endmodule