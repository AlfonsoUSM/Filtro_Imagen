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

    image_editor instance_name(
      .clk(),
      .reset(),
      .control(),
      .raw_rgb(),
      .rgb()
    );
    
*/ ////////////////////////////////////////////////////////

module image_editor(
    input clk,
    input reset,
    input [2:0] control,
    input [17:0] raw_rgb,
    output [11:0] rgb
    );
    
    logic [3:0] red, green, blue;
    
    assign rgb = {red, green, blue};
    
    always_comb begin
        red = (control[0] == 1'b1) ? raw_rgb[17:14] : 4'd0;
        green = (control[1] == 1'b1) ? raw_rgb[11:8] : 4'd0;
        blue = (control[2] == 1'b1) ? raw_rgb[5:2] : 4'd0; 
    end
    
endmodule
