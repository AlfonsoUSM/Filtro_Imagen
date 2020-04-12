`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2020 21:15:27
// Design Name: 
// Module Name: segment7
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


module segment7(
    input clk,
    input reset,
    input [31:0] display_bcd,
    output [14:0] segments
    );
    
    logic [7:0] anodes, next_anodes;
    logic [6:0] cathodes;
    logic [3:0] bcd;
    
    assign segments = {anodes[7:0], cathodes[6:0]};
         
    always_ff @ (posedge clk) begin
        if (reset == 1'b1) begin
            anodes <= 8'b11111110;
        end
        else begin
            anodes <= next_anodes[7:0];
        end    
    end
    
    always_comb begin
        next_anodes = {anodes[6:0], anodes[7]};
        case (anodes)
            8'b11111110:
                bcd = display_bcd[3:0];
            8'b11111101:
                bcd = display_bcd[7:4];
            8'b11111011:
                bcd = display_bcd[11:8];
            8'b11110111:
                bcd = display_bcd[15:12];
            8'b11101111:
                bcd = display_bcd[19:16];
            8'b11011111:
                bcd = display_bcd[23:20];
            8'b10111111:
                bcd = display_bcd[27:24];
            8'b01111111:
                bcd = display_bcd[31:28];
            default:
                bcd = 4'd10;
        endcase
    end
        
    bcd2seg7 seg7(
        .bcd(bcd),
        .seg(cathodes)
    ); 
endmodule
