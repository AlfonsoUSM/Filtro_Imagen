`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.02.2020 12:57:49
// Design Name: 
// Module Name: simu_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module simu_ram(
    );
    
    logic CLK100MHZ, reset;
    logic uart_rx;
    logic [18:0] r_address;
    logic [1:0] done;
    logic [17:0] rgb;
    
    logic [15:0] cnt;
    logic pix_stb;
    
    always #5 CLK100MHZ = ~CLK100MHZ;
    
    initial begin
        CLK100MHZ = 1'b0;
        reset = 1'b0;
        uart_rx = 1'b1;
        cnt = 16'b0;
        r_address = 19'b0;
        #5;
        reset = 1'b1;
        #15
        reset = 1'b0;
        #10;
        
        uart_rx = 1'b0;//start bit
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0; // end bit
        #1000;
        uart_rx = 1'b1;
        #1200;
         
        uart_rx = 1'b0;//start bit
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0; // end bit
        #1000;
        uart_rx = 1'b1;
        #1500;  
          
        uart_rx = 1'b0;//start bit
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0; // end bit
        #1000;
        uart_rx = 1'b1;
        #1200; 
        
        uart_rx = 1'b0;//start bit
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0; // end bit
        #1000;
        uart_rx = 1'b1;
        #1200; 
          
        uart_rx = 1'b0;//start bit
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0; // end bit
        #1000;
        uart_rx = 1'b1;
        #1200; 
          
        uart_rx = 1'b0;//start bit
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b1;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0;
        #1000;
        uart_rx = 1'b0; // end bit
        #1000;
        uart_rx = 1'b1;
        #1200; 
        
        r_address = 19'd1;
        
    end
    
     //generate a 25 MHz pixel strobe
    always @(posedge CLK100MHZ)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000
  
  
    PictureMemory instance_name(
        .clk(CLK100MHZ),         // 1 bit Input: base clock (BRAM side A)
        .reset(reset),       // 1 bit Input: reset
        .uart_rx(uart_rx),     // 1 bit Input: receive serial
        .pixel_clk(pix_stb),   // 1 bit Input: pixel clock (BRAM side B)
        .r_address(r_address[18:0]),   // 19 bits Input: BRAM side B reading address
        .rgb(rgb[17:0]),          // 18 bits Output: pixel 6x3 bit colour data
        .done(done[1:0])
    );
    
endmodule
