`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2020 17:32:02
// Design Name: 
// Module Name: vga1024x768
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

    vga1024x768 instance_name(
        .clk(),         // 1 bit Input: base clock
        .pix_stb(),     // 1 bit Input: pixel clock strobe
        .reset(),       // 1 bit Input: reset: restarts frame
        .hsync(),       // 1 bit Output: horizontal sync
        .vsync(),       // 1 bit Output: vertical sync
        .blanking(),    // 1 bit Output: high during blanking interval
        .active(),      // 1 bit Output: high during active pixel drawing
        .screenend(),   // 1 bit Output: high for one tick at the end of screen
        .animate(),     // 1 bit Output: high for one tick at end of active drawing
        .x(),           // 10 bit Output: current pixel x position
        .y()            // 10 bit Output: current pixel y position
    );
    
*/ ////////////////////////////////////////////////////////


module vga1024x768(
    input clk,           // base clock
    input pix_stb,       // pixel clock strobe
    input reset,         // reset: restarts frame
    output hsync,        // horizontal sync
    output vsync,        // vertical sync
    output blanking,     // high during blanking interval
    output active,       // high during active pixel drawing
    output screenend,    // high for one tick at the end of screen
    output animate,      // high for one tick at end of active drawing
    output [9:0] x,     // current pixel x position
    output [9:0] y       // current pixel y position
    );
    
// pixel clock 78.750MHz
    localparam HS_STA = 16;             // horizontal sync start (front porch)
    localparam HS_END = 16 + 96;        // horizontal sync end (hfp + sync pulse)
    localparam HA_STA = 16 + 96 + 176;  // horizontal active pixel start (hfp + sp + back porch)
    localparam LINE   = 1312;           // complete line (pixels) (total horizontal pixels)
    localparam VA_END = 768;            // vertical active pixel end (active video)
    localparam VS_STA = 768 + 1;        // vertical sync start (av + vertical front porch) 
    localparam VS_END = 768 + 1 + 3;    // vertical sync end (av + vfp + sync pulse)
    localparam SCREEN = 800;            // complete screen (lines) (total vertical lines)
    
//    localparam HS_STA = 16;              // horizontal sync start
//    localparam HS_END = 16 + 96;         // horizontal sync end
//    localparam HA_STA = 16 + 96 + 48;    // horizontal active pixel start
//    localparam VS_STA = 480 + 10;        // vertical sync start
//    localparam VS_END = 480 + 10 + 2;    // vertical sync end
//    localparam VA_END = 480;             // vertical active pixel end
//    localparam LINE   = 800;             // complete line (pixels)
//    localparam SCREEN = 525;             // complete screen (lines)

//    localparam HS_STA = 24;             // horizontal sync start
//    localparam HS_END = 24 + 136;         // horizontal sync end
//    localparam HA_STA = 24 + 136 + 160;    // horizontal active pixel start
//    localparam VS_STA = 768 + 3;        // vertical sync start
//    localparam VS_END = 768 + 3 + 6;    // vertical sync end
//    localparam VA_END = 768;             // vertical active pixel end
//    localparam LINE   = 1344;             // complete line (pixels)
//    localparam SCREEN = 806;             // complete screen (lines)
    

    logic [10:0] h_count;  // line position
    logic [9:0] v_count;  // screen position

    // generate sync signals (active low for 640x480)
    assign hsync = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign vsync = ~((v_count >= VS_STA) & (v_count < VS_END));

    // keep x and y bound within the active pixels
    assign x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
    assign y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);

    // blanking: high within the blanking period
    assign blanking = ((h_count < HA_STA) | (v_count > VA_END - 1));

    // active: high during active pixel drawing
    assign active = ~((h_count < HA_STA) | (v_count > VA_END - 1)); 

    // screenend: high for one tick at the end of the screen
    assign screenend = ((v_count == SCREEN - 1) & (h_count == LINE));

    // animate: high for one tick at the end of the final active pixel line
    assign animate = ((v_count == VA_END - 1) & (h_count == LINE));

    always @ (posedge clk) begin
        if (reset) begin // reset to start of frame
            h_count <= 0;
            v_count <= 0;
        end
        if (pix_stb) begin // once per pixel
            if (h_count == LINE) begin // end of line
                h_count <= 0;
                v_count <= v_count + 1;
            end
            else 
                h_count <= h_count + 1;
            if (v_count == SCREEN)  // end of screen
                v_count <= 0;
        end
    end
endmodule
