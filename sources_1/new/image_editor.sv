`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2020 22:06:44
// Design Name: 
// Module Name: image_editor
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

    image_editor #(.H_SIZE(607), .V_SIZE(455)) instance_name(
      .clk(),
      .reset(),
      .synch_pulse(),
      .control(),
      .raw_rgb(),
      .rgb()
    );
    
*/ ////////////////////////////////////////////////////////

module image_editor #(parameter H_SIZE = 607, V_SIZE = 455)(
    input clk,
    input reset,
    input synch_pulse,
    input [7:0] control,
    input [17:0] raw_rgb,
    output [11:0] rgb
    );
    
    logic [11:0] dith_rgb, gray_rgb;
    logic [11:0] t_rgb, rgb0, rgb1, rgb2;
    
    assign t_rgb[11:8] = raw_rgb[17:14];
    assign t_rgb[7:4] = raw_rgb[11:8];
    assign t_rgb[3:0] = raw_rgb[5:2];
    
    always_ff @ (posedge clk) begin
        if (reset == 1'b1)
            rgb0 <= 12'b0;
        else
            rgb0 <= t_rgb;
    end
        
    always_comb begin
        rgb1 = (control[0] == 1'b1) ? dith_rgb : rgb0;
        rgb2 = (control[1] == 1'b1) ? gray_rgb : rgb1;
    end
    
    dithering #(.H_SIZE(H_SIZE), .V_SIZE(V_SIZE)) dither (
      .clk(clk),       // 1 bit Input: clock signal 
      .reset(reset),     // 1 bit Input: CPU reset signal
      .synch_pulse(synch_pulse),   // 1 bit Input: image start of line synchronization pulse
      .raw_rgb(raw_rgb),   // 18 bits Input: input rgb pixels
      .out_rgb(dith_rgb)    // 12 bits Output: filtered pixels
    );
    
    grayscale gray (
      .raw_rgb(rgb1),   // 18 bits Input: input rgb pixels
      .out_rgb(gray_rgb)    // 12 bits Output: filtered pixels
    );
    
    scrambler scramble (
      .control(control[7:2]),   // 6 bits Input: control
      .raw_rgb(rgb2),   // 18 bits Input: input rgb pixels
      .out_rgb(rgb)    // 12 bits Output: filtered pixels
    );
    
    
endmodule
