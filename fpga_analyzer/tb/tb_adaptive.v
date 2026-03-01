`timescale 1ns/1ps

module tb_adaptive();

    parameter DATA_WIDTH = 128;
    parameter CLK_PERIOD = 20;
    parameter SAMPLES_PER_MODE = 100;
    parameter TOTAL_MODES = 6;
    parameter TOTAL_SAMPLES = SAMPLES_PER_MODE * TOTAL_MODES;

    reg clk;
    reg reset_n;
    reg [DATA_WIDTH-1:0] data_in_bus;
    reg [7:0] mode;
    reg data_in_valid;
    
    wire [DATA_WIDTH-1:0] data_out_bus;
    wire data_out_valid;
    wire alert_led;

    reg [DATA_WIDTH-1:0] test_mem [0:TOTAL_SAMPLES-1]; 
    reg [7:0] mode_list [0:TOTAL_MODES-1];
    integer out_file;
    integer i, m_idx;
    integer data_count;

    adaptive dut (
        .clk            (clk),
        .reset_n        (reset_n),
        .data_in_bus    (data_in_bus),
        .mode           (mode),
        .data_valid     (data_in_valid),
        .data_out_bus   (data_out_bus),
        .data_out_valid (data_out_valid),
        .alert_led      (alert_led)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        mode_list[0] = 8'd4;   
        mode_list[1] = 8'd8;   
        mode_list[2] = 8'd16;
        mode_list[3] = 8'd32;  
        mode_list[4] = 8'd64;  
        mode_list[5] = 8'd128;

        reset_n = 0;
        data_in_valid = 0;
        data_in_bus = 0;
        mode = 8'd0;
        data_count = 0;

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_adaptive);

        $readmemh("input_data.hex", test_mem);
        
        out_file = $fopen("fpga_out.hex", "w");
        if (out_file == 0) begin
            $display("ERROR: Could not create fpga_out.hex");
            $finish;
        end

        #(CLK_PERIOD * 10);
        reset_n = 1;
        #(CLK_PERIOD * 5);

        $display(">>> Starting Multi-Mode Verification (%d samples total)", TOTAL_SAMPLES);

        for (m_idx = 0; m_idx < TOTAL_MODES; m_idx = m_idx + 1) begin
            
            @(posedge clk);
            mode <= mode_list[m_idx];
            $display(">>> Testing Mode: %d", mode_list[m_idx]);
            
            repeat (10) @(posedge clk);

            for (i = 0; i < SAMPLES_PER_MODE; i = i + 1) begin
                @(posedge clk);
                data_in_valid <= 1;
                data_in_bus   <= test_mem[m_idx * SAMPLES_PER_MODE + i];
            end

            @(posedge clk);
            data_in_valid <= 0;
            data_in_bus   <= 0;
            
            repeat (50) @(posedge clk); 
        end

        $display(">>> Simulation Finished. Total samples processed: %d", data_count);
        $fclose(out_file);
        $finish;
    end

    always @(posedge clk) begin
        if (reset_n && data_out_valid) begin
            $fwrite(out_file, "%h\n", data_out_bus);
            data_count = data_count + 1;
        end
    end

endmodule