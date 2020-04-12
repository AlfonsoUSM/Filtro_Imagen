`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2020 18:09:36
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

////////    Instance template   /////////////
/* 
    segment7 instance_name(
        .bcd(),
        .seg()
    );
*/
////////////////////////////////////////////

module bcd2seg7(
    input [3:0] bcd,
    output [6:0] seg
    );
    
    logic [6:0] cathodes;
    
    assign seg[6:0] = cathodes[6:0]; 
    
    always_comb begin
        case (bcd[3:0])
            4'd0:
                cathodes = 7'b0000001;
            4'd1:        
                cathodes = 7'b1001111;
            4'd2:       
                cathodes = 7'b0010010;
            4'd3:        
                cathodes = 7'b0000110;
            4'd4:        
                cathodes = 7'b1001100;
            4'd5:        
                cathodes = 7'b0100100;
            4'd6:        
                cathodes = 7'b0100000;
            4'd7:        
                cathodes = 7'b0001111;
            4'd8:        
                cathodes = 7'b0000000;
            4'd9:        
                cathodes = 7'b0000100;
            4'd10:        
                cathodes = 7'b0001000;
            4'd11:        
                cathodes = 7'b1100000;
            4'd12:        
                cathodes = 7'b0011001;
            4'd13:        
                cathodes = 7'b1000010;
            4'd14:        
                cathodes = 7'b0110000;
            4'd15:        
                cathodes = 7'b0111000;
            default :
                cathodes = 7'b1111110; // -
        endcase
    end
    
endmodule
