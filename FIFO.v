//////////////////////////////////////////////////////////////////////////////////
// Configurable FIFO
//////////////////////////////////////////////////////////////////////////////////

module FIFO
#(
    parameter ADDR_BITS = 3,
    DATA_WIDTH = 8
)
(
    input clk, rst,
    input wire wr, rd,
    input wire [DATA_WIDTH - 1 : 0] Din,

    output wire [DATA_WIDTH - 1 : 0] Dout,
    output wire full, empty
);

    // internal signals, r_ prefix means register type
    wire wr_en;
    reg r_full, r_empty;
    reg r_full_next, r_empty_next;
    reg [ADDR_BITS - 1 : 0] r_write_ptr, r_write_ptr_next, r_write_plus_one;
    reg [ADDR_BITS - 1 : 0] r_read_ptr, r_read_ptr_next, r_read_plus_one;

    // instantiate a register file
    register_file #(.ADDR_BITS(ADDR_BITS), .REG_BITS(DATA_WIDTH)) regfile
    (
        .clk(clk),                  // pass in our clock
        .wr_en(wr_en),              // wire up write enable
        .wr_data(Din),              // Din writes data to register file
        .r_data(Dout),              // Dout reads data from register file
        .wr_addr(r_write_ptr),      // connect the write pointer to the write addr
        .r_addr(r_read_ptr)         // connect the read pointer to the read addr
    );

    // we can write to the register file only if it is not full
    assign wr_en = wr & ~r_full;

    // connect our state to output wires
    assign full     = r_full;
    assign empty    = r_empty;

    // data path logic for fifo control
    always @(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            r_write_ptr <= 0;
            r_read_ptr  <= 0;
            r_full      <= 1'b0;
            r_empty     <= 1'b1;
        end
        else begin
            r_write_ptr <= r_write_ptr_next;    // update the write pointer
            r_read_ptr  <= r_read_ptr_next;     // update the read pointer
            r_full      <= r_full_next;         // update the full state
            r_empty     <= r_empty_next;        // update the empty state
        end
    end

    // control path logic - combinational logic
    always @*
    begin
        // default to previous values
        r_write_ptr_next    = r_write_ptr;
        r_read_ptr_next     = r_read_ptr;
        r_full_next         = r_full;
        r_empty_next        = r_empty;

        // compute the next ptr values
        r_write_plus_one    = r_write_ptr + 1;
        r_read_plus_one     = r_read_ptr + 1;

        // handle rd when not empty
        if (rd & ~r_empty)
        begin
            // can't be full if we weren't empty and just did a read
            r_full_next = 1'b0;

            // advance the read pointer
            r_read_ptr_next = r_read_plus_one;

            // if new/next read pointer now equals write pointer we are empty
            if (r_write_ptr == r_read_plus_one)
                r_empty_next = 1'b1;
        end

        // handle wr when not full
        if (wr & ~r_full)
        begin
            // can't be empty if we weren't full and just did a write
            r_empty_next = 1'b0;

            // advance the write pointer
            r_write_ptr_next = r_write_plus_one;

            // if new/next write pointer now equals read pointer we are full
            if (r_read_ptr == r_write_plus_one)
                r_full_next = 1'b1;
        end
    end
endmodule
