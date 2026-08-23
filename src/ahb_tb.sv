`timescale 1ns/1ps

module ahb_tb;
    logic        HCLK;
    logic        HRESETn;
    logic [31:0] HADDR;
    logic        HWRITE;
    logic [1:0]  HTRANS;
    logic [2:0]  HSIZE;
    logic [2:0]  HBURST;
    logic [31:0] HWDATA;
    logic        HSEL;
    logic        HREADY;
    logic [31:0] HRDATA;
    logic        HRESP;

    ahb_slave dut (.*, .HREADYOUT(HREADY));

    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end

    initial begin
        $dumpfile("ahb_sim.vcd");
        $dumpvars(0, ahb_tb);
        
        HRESETn = 0; HSEL = 0; HADDR = 0; HWRITE = 0; HTRANS = 0;
        HSIZE = 3'b010; HBURST = 0; HWDATA = 0;
        
        #15 HRESETn = 1;
        
        // tc1: single write
        @(posedge HCLK);
        HSEL = 1; HADDR = 32'h0004; HWRITE = 1; HTRANS = 2'b10;
        @(posedge HCLK);
        HTRANS = 2'b00; 
        HWDATA = 32'hAABBCCDD;
        wait(HREADY);
        
        // tc2: single read
        @(posedge HCLK);
        HADDR = 32'h0004; HWRITE = 0; HTRANS = 2'b10;
        @(posedge HCLK);
        HTRANS = 2'b00;
        wait(HREADY);
        $display("read data: %h", HRDATA);
        
        // tc3: write with wait states
        @(posedge HCLK);
        HADDR = 32'h0020; HWRITE = 1; HTRANS = 2'b10;
        @(posedge HCLK);
        HTRANS = 2'b00;
        HWDATA = 32'h12345678;
        wait(HREADY); 
        
        // tc4: incr4 burst
        @(posedge HCLK);
        HBURST = 3'b011; 
        HADDR = 32'h0100; HWRITE = 1; HTRANS = 2'b10; 
        
        @(posedge HCLK);
        HADDR = 32'h0104; HTRANS = 2'b11;
        HWDATA = 32'h11111111;
        
        @(posedge HCLK);
        HADDR = 32'h0108; HTRANS = 2'b11;
        HWDATA = 32'h22222222;
        
        @(posedge HCLK);
        HADDR = 32'h010C; HTRANS = 2'b11;
        HWDATA = 32'h33333333;
        
        @(posedge HCLK);
        HTRANS = 2'b00;
        HWDATA = 32'h44444444;
        
        // tc5: invalid address error
        @(posedge HCLK);
        HBURST = 3'b000;
        HADDR = 32'hFFFFFFFF; HWRITE = 0; HTRANS = 2'b10;
        @(posedge HCLK);
        HTRANS = 2'b00;
        wait(HREADY);
        if (HRESP == 1) $display("error working");

        #20 $finish;
    end
endmodule
