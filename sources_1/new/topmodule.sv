`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.12.2019 11:51:41
// Design Name: 
// Module Name: topmodule
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


module topmodule(
    input CLK100MHZ,
    input CPU_RESETN,
    input [15:0] SW,
    input UART_TXD_IN,
    output JA1,
    output [3:0] VGA_R,
    output [3:0] VGA_G, 
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output LED16_B
    );
    
    
    localparam H_SIZE = 607;
    localparam V_SIZE = 455;
    
    logic CLK78M75HZ;
    logic hsync, vsync;
    logic [9:0] y;
    logic [10:0] x;
    logic [17:0] raw_rgb ;
    logic synch_pulse;
    logic loaded;
    
    assign VGA_HS = hsync;
    assign VGA_VS = vsync;
    assign JA1 = UART_TXD_IN;
    assign LED16_B = loaded;
   
   //// MEMORY CONTROL ////////////////////////
   
    PictureMemory #(.H_SIZE(H_SIZE), .V_SIZE(V_SIZE)) memory_ctrl(
        .clk(CLK100MHZ),         // 1 bit Input: base clock (BRAM side A)
        .reset(~CPU_RESETN),       // 1 bit Input: reset
        .uart_rx(UART_TXD_IN),     // 1 bit Input: receive serial
        .pixel_clk(CLK78M75HZ),   // 1 bit Input: pixel clock
        .h_count(x),           // 10 bits Input: vga horizontal count
        .v_count(y),           // 10 bits Input: vga vertical count
        .raw_rgb(raw_rgb),         // 18 bits Output: raw rgb pixel (6x3 bit colour data)
        .synch_pulse(synch_pulse),
        .loaded(loaded)       // 1 bit Output: image stored
    );
    
    //// IMAGE EDITING //////////////////////////
    
    image_editor #(.H_SIZE(H_SIZE), .V_SIZE(V_SIZE)) editor (
      .clk(CLK78M75HZ),
      .reset(~CPU_RESETN),
      .synch_pulse(synch_pulse),
      .control({SW[15:10], SW[1:0]}),
      .raw_rgb(raw_rgb),
      .rgb({VGA_R, VGA_G, VGA_B})
    );
    
    //// VGA CONTROL & CLOCK ////////////////////////////
    
    clk_wiz_0 vga_clock_divider(
        .clk_in100MHZ(CLK100MHZ),       // input clk_in100MHZ
        .reset(~CPU_RESETN),            // input reset
        .locked(),                      // output locked
        .clk_out78M75HZ(CLK78M75HZ)   // output clk_out78M750HZ
    );
     
    vga1024x768 vga_synch(
        .clk(CLK100MHZ),         // 1 bit Input: base clock
        .pix_stb(CLK78M75HZ),     // 1 bit Input: pixel clock strobe
        .reset(~CPU_RESETN),       // 1 bit Input: reset: restarts frame
        .hsync(hsync),       // 1 bit Output: horizontal sync
        .vsync(vsync),       // 1 bit Output: vertical sync
        .blanking(),    // 1 bit Output: high during blanking interval
        .active(),      // 1 bit Output: high during active pixel drawing
        .screenend(),   // 1 bit Output: high for one tick at the end of screen
        .animate(),     // 1 bit Output: high for one tick at end of active drawing
        .x(x),           // 11 bit Output: current horizontal count position
        .y(y)            // 10 bit Output: current vertical count position
    );
            
endmodule
