`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2020 18:05:41
// Design Name: 
// Module Name: PictureMemory
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

/* /////////////// Instance Template ////////////////////

    PictureMemory #(.H_SIZE(607), .V_SIZE(455)) instance_name(
        .clk(),         // 1 bit Input: base clock (BRAM side A)
        .reset(),       // 1 bit Input: reset
        .uart_rx(),     // 1 bit Input: receive serial
        .pixel_clk(),   // 1 bit Input: vga pixel clock
        .x(),           // 10 bits Input: vga horizontal count
        .y(),           // 10 bits Input: vga vertical count
        .raw_rgb(),         // 18 bits Output: raw rgb pixel (6x3 bit colour data)
        .loaded()       // 1 bit Output: image stored
    );
    
*/ //////////////////////////////////////////////////////

module PictureMemory #(parameter H_SIZE = 607, V_SIZE = 455) (
    input clk,
    input reset,
    input uart_rx,
    input pixel_clk,
    input [9:0] x, 
    input [9:0] y,
    output [17:0] raw_rgb,
    output loaded
    );
    
    ///// RECEIVE & STORE IMAGE //////
    
    localparam PIXELS = H_SIZE * V_SIZE; // 276185;
    
    logic wea;
    logic [17:0] w_data;
    logic [18:0] w_address;

    input_interface #(.PIXELS(PIXELS)) bram_write_interface (
        .clk(clk),             // 1 bit Input: clock signal
        .reset(reset),           // 1 bit Input: CPu reset signal
        .uart_rx(uart_rx),         // 1 bit Input: serial receive signal
        .wea(wea),             // 1 bit Output: bram write enable signal
        .w_data(w_data),          // 18 bits Output: bram write data word
        .w_address(w_address),       // 19 bits Output: bram write address
        .done(loaded)             // 2 bits picture loaded flags
    );
    
    
    //// READ IMAGE FROM BRAM /////
    
    logic [17:0] r_data;
    logic [18:0] r_address;
    
    output_interface #(.H_SIZE(H_SIZE), .V_SIZE(V_SIZE)) bram_read_interface (
       .clk(clk),          // 1 bit Input: clock signal
       .reset(reset),        // 1 bit Input: CPU reset signal
       .pixel_clk(pixel_clk),    // 1 bit Input: vga clok
       .x(x),            // 10 bits Input: vga horizontal count
       .y(y),            // 10 bits Input: vga vertical count
       .r_data(r_data),       // 18 bits Output: bram read data
       .r_address(r_address),    // 19 bits Output: bram read address
       .raw_rgb(raw_rgb)       // 18 bits Output: raw rgb pixel (6 bits per color)
    );
    
    /////////// BRAM //////////

    blk_mem_gen_0 pictureRAM (
        // A side (R/W)
        .clka(clk),    // input wire clka
        .ena(1'b1),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(w_address[18:0]),  // input wire [18 : 0] addra
        .dina(w_data),    // input wire [17 : 0] dina
        // B side (R)
        .clkb(clk),    // input wire clkb
        .enb(1'b1),      // input wire enb
        .addrb(r_address),  // input wire [18 : 0] addrb
        .doutb(r_data)  // output wire [17 : 0] doutb
    );
        
endmodule
