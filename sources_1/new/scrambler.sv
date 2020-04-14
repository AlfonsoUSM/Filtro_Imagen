`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2020 15:30:33
// Design Name: 
// Module Name: scrambler
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

    scrambler instance_name(
      .control(),   // 6 bits Input: control
      .raw_rgb(),   // 18 bits Input: input rgb pixels
      .out_rgb()    // 12 bits Output: filtered pixels
    );
    
*/ ////////////////////////////////////////////////////////

module scrambler(
    input [5:0] control,
    input [11:0] raw_rgb,
    output [11:0] out_rgb
    );
    
    logic [3:0] in_red, in_green, in_blue;
    logic [3:0] out_red, out_green, out_blue;
    
    assign in_red = raw_rgb[11:8];
    assign in_green = raw_rgb[7:4];
    assign in_blue = raw_rgb[3:0];
    assign out_rgb = {out_red, out_green, out_blue};
    
    always_comb begin
        case (control[5:4])
            2'b00: out_red = in_red;
            2'b01: out_red = in_green;
            2'b10: out_red = in_blue;
            2'b11: out_red = 4'd0;
        endcase
        case (control[3:2])
            2'b00: out_green = in_red;
            2'b01: out_green = in_green;
            2'b10: out_green = in_blue;
            2'b11: out_green = 4'd0;
        endcase
        case (control[1:0])
            2'b00: out_blue = in_red;
            2'b01: out_blue = in_green;
            2'b10: out_blue = in_blue;
            2'b11: out_blue = 4'd0;
        endcase
    end
endmodule
