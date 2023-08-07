`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// FIFO Testbench
//////////////////////////////////////////////////////////////////////////////////
 
module TopLevel();
    localparam T = 20;
    localparam ADDR_BITS = 3;
 
    reg clk;
    reg rd, wr, rst;
    reg [7 :0] Din;
    wire [7:0]Dout;
    wire full, empty;
        
    // declare the unit under test
    FIFO uut
    (
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .rd(rd),
        .Din(Din),

        .Dout(Dout),
        .full(full),
        .empty(empty)
    );
     
    // generate the clock signal    
    always begin
        #(T/2) clk = ~clk;
    end
 
    // set initial conditions
    initial begin
        clk = 0;
        rd = 0;
        wr = 0;
         
        rst = 1'b1;
        #(T/2);
        rst = 1'b0;
    end
 
    // perform some tests    
    initial begin
        // wait for reset to complete
        @(negedge rst)
         
        // fill the FIFO
        @(negedge clk);
        wr = 1'b1;
        Din = 1;

        while(~full && Din < 250) begin
            @(negedge clk);
            Din = Din + 1;            
        end

        // @(negedge clk) begin
        //     if (!full) begin
        //         Din = Din + 1;
        //     end
        // end
 
        // empty the FIFO       
        @(negedge clk);
        wr = 1'b0;       
        rd = 1'b1;
         
        wait(empty == 1'b1);
         
        #(4*T);
         
        $stop;      
    end
     
endmodule
