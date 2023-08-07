module register_file
    #(
        parameter REG_BITS = 8,  // default to 8b wide registers
        ADDR_BITS = 3            // default to 8 registers total
    )
    (
        input clk,                                // clock signal
        input wr_en,                              // write enable
        input wire [ADDR_BITS - 1 : 0] wr_addr,   // write address
        input wire [ADDR_BITS - 1 : 0] r_addr,    // read address
        input wire [REG_BITS - 1 : 0] wr_data,    // input port

        output wire [REG_BITS - 1 : 0] r_data     // output port
    );

    // declare an array of registers
    reg [REG_BITS - 1 : 0] register_array [2 ** ADDR_BITS - 1 : 0];

    // handle synchronous write operation
    always @(posedge clk)
        if (wr_en)
            register_array[wr_addr] <= wr_data;

    // handle read operation
    assign r_data = register_array[r_addr];

endmodule
