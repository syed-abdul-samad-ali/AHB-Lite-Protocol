`timescale 1ns/1ps

module ahb_slave (
    input  logic        HCLK,
    input  logic        HRESETn,
    input  logic [31:0] HADDR,
    input  logic        HWRITE,
    input  logic [1:0]  HTRANS,
    input  logic [2:0]  HSIZE,
    input  logic [2:0]  HBURST,
    input  logic [31:0] HWDATA,
    input  logic        HSEL,
    
    output logic        HREADYOUT,
    output logic [31:0] HRDATA,
    output logic        HRESP
);

    logic [31:0] mem [0:255]; // small memory for testing
    
    logic [31:0] addr_reg;
    logic        write_reg;
    logic        active_transfer;
    logic [1:0]  wait_cnt;

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_reg <= 0;
            write_reg <= 0;
            active_transfer <= 0;
            HREADYOUT <= 1;
            HRESP <= 0;
            HRDATA <= 0;
            wait_cnt <= 0;
        end else begin
            // check invalid address for error response (TC5)
            if (HSEL && (HTRANS == 2'b10 || HTRANS == 2'b11) && HADDR > 32'h03FC) begin
                HRESP <= 1;
                HREADYOUT <= 1;
                active_transfer <= 0;
            end 
            else begin
                HRESP <= 0;
                
                // capture address phase
                if (HSEL && HREADYOUT && (HTRANS == 2'b10 || HTRANS == 2'b11)) begin
                    addr_reg <= HADDR;
                    write_reg <= HWRITE;
                    active_transfer <= 1;
                    
                    // insert wait state for specific address (TC3)
                    if (HADDR == 32'h0020) begin
                        HREADYOUT <= 0;
                        wait_cnt <= 2; 
                    end
                end
                
                // execute data phase
                if (active_transfer) begin
                    if (wait_cnt > 0) begin
                        wait_cnt <= wait_cnt - 1;
                        if (wait_cnt == 1) HREADYOUT <= 1;
                    end else begin
                        if (write_reg)
                            mem[addr_reg[9:2]] <= HWDATA;
                        else
                            HRDATA <= mem[addr_reg[9:2]];
                            
                        active_transfer <= 0;
                    end
                end
            end
        end
    end
endmodule
