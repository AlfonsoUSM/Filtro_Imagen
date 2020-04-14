`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2020 15:30:33
// Design Name: 
// Module Name: grayscale
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

    grayscale instance_name(
      .raw_rgb(),   // 18 bits Input: input rgb pixels
      .out_rgb()    // 12 bits Output: filtered pixels
    );
    
*/ ////////////////////////////////////////////////////////

module grayscale(
    input [11:0] raw_rgb,
    output [11:0] out_rgb
    );
    
    //assign out_rgb = raw_rgb;
    
    logic [4:0] int0;
    logic [3:0] result, equal, sum0, int1;
    logic [2:0] sum1, int2;
    logic [1:0] sum2;
    
    assign equal = raw_rgb[11:8] & raw_rgb[7:4] & raw_rgb[3:0];
    assign int0 = (raw_rgb[11:8] & (~equal)) + (raw_rgb[7:4] & (~equal)) + (raw_rgb[3:0] & (~equal));
    
    assign result = equal + sum0 + sum1 + sum2;
    assign out_rgb = {result, result, result};
    
    always_comb begin
        case (int0[4:3])
            2'b11: begin
                int1 = int0 - 5'd24;
                sum0 = 4'd6;
            end
            2'b10: begin
                int1 = int0 - 5'd15;
                sum0 = 4'd5;
            end
            default: begin
                int1 = int0[3:0];
                sum0 = 4'd0;
            end
        endcase
        case (int1[3:2])
            2'b11: begin
                int2 = int1 - 4'd12;
                sum1 = 3'd4;
            end
            2'b10: begin
                int2 = int1 - 4'd6;
                sum1 = 3'd2;
            end
            default: begin
                int2 = int1[2:0];
                sum1 = 3'd0;
            end
        endcase
        case (int2[2:0])
            3'b111: sum2 = 2'd2;
            3'b110: sum2 = 2'd2;
            3'b101: sum2 = 2'd2;
            3'b100: sum2 = 2'd1;
            3'b011: sum2 = 2'd1;
            3'b010: sum2 = 2'd1;
            default: sum2 = 2'd0;
        endcase
    end
    
endmodule
