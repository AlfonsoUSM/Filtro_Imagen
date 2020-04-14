`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2020 15:30:33
// Design Name: 
// Module Name: dithering
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

    dithering #(.H_SIZE(607), .V_SIZE(455)) instance_name(
        .clk(),       // 1 bit Input: clock signal 
        .reset(),     // 1 bit Input: CPU reset signal
        .synch_pulse(),  //1 bit Output: image start of line synchronization pulse
        //.h_count(),   // 11 bits Input: vga horizontal count
        .raw_rgb(),   // 18 bits Input: input rgb pixels
        .out_rgb()    // 12 bits Output: filtered pixels
    );
    
*/ ////////////////////////////////////////////////////////

module dithering #(parameter H_SIZE = 607, V_SIZE = 455)(
    input clk,
    input reset,
    input synch_pulse,
    input [17:0] raw_rgb,
    output [11:0] out_rgb
    );
          
    localparam X_OFSET = 290; // 500;
    localparam Y_OFSET = 10; // 150;
    
    enum logic {INACTIVE, ACTIVE} state, next_state;
    logic [11:0] rgb, next_rgb; //, output_rgb;
    logic [9:0] x, y, next_x, next_y;
    
    localparam BITS = (H_SIZE + 2) * 21; //12747
    localparam UR = 7;
    localparam DR = 1;
    localparam DC = 5;
    localparam DL = 3;
    localparam R = 2;
    localparam G = 1;
    localparam B = 0;
    
    logic [6:0] error_red, error_green, error_blue; // signed error /16 (shifted)
    logic [7:0] sum_red, sum_green, sum_blue; // signed raw color + accumulated error with carry
    logic [5:0] approx_red, approx_green, approx_blue; // signed value to display with carry
    logic [11:0] result;
    logic [(H_SIZE + 1):0][2:0][6:0] quantization ; // signed error accumulation
    logic [(H_SIZE + 1):0][2:0][6:0] next_quant; 
    
    assign out_rgb = rgb;  
    
    always_ff @ (posedge clk) begin
        if (reset == 1'b1) begin
            state <= INACTIVE;
            x <= 10'd0;
            y <= 10'd0;
            rgb <= 18'd0;
            quantization <= 12747'd0;
        end
        else begin
            state <= next_state;
            x <= next_x;
            y <= next_y;
            rgb <= next_rgb;
            quantization <= next_quant;
        end
    end
    
    always_comb begin 
      // error calculation
        // red
        case (sum_red[2:0])
            3'b000: begin
                approx_red[5:0] = sum_red[7:2];
                error_red = 7'b0000000; // +0
            end
            3'b001: begin
                approx_red[5:0] = sum_red[7:2];
                error_red = 7'b0000001; // +1
            end
            3'b010: begin
                approx_red[5:0] = sum_red[7:2];
                error_red = 7'b0000010; // +2
            end
            3'b011: begin
                approx_red[5:0] = sum_red[7:2] + 6'd1;
                error_red = 7'b1111111; // -1
            end
            3'b100: begin
                approx_red[5:0] = sum_red[7:2];
                error_red = 7'b0000000; // +0
            end
            3'b101: begin
                approx_red[5:0] = sum_red[7:2];
                error_red = 7'b0000001; // +1
            end
            3'b110: begin
                approx_red[5:0] = sum_red[7:2] + 6'd1;
                error_red = 7'b1111110; // -2
            end
            3'b111: begin
                approx_red[5:0] = sum_red[7:2] + 6'd1;
                error_red = 7'b1111111; // -1
            end
        endcase
        // green
        case (sum_green[2:0])
            3'b000: begin
                approx_green[5:0] = sum_green[7:2];
                error_green = 7'b0000000; // +0
            end
            3'b001: begin
                approx_green[5:0] = sum_green[7:2];
                error_green = 8'b00000001; // +1
            end
            3'b010: begin
                approx_green[5:0] = sum_green[7:2];
                error_green = 7'b0000010; // +2
            end
            3'b011: begin
                approx_green[5:0] = sum_green[7:2] + 6'd1;
                error_green = 7'b1111111; // -1
            end
            3'b100: begin
                approx_green[5:0] = sum_green[7:2];
                error_green = 7'b0000000; // +0
            end
            3'b101: begin
                approx_green[5:0] = sum_green[7:2];
                error_green = 7'b0000001; // +1
            end
            3'b110: begin
                approx_green[5:0] = sum_green[7:2] + 6'd1;
                error_green = 7'b1111110; // -2
            end
            3'b111: begin
                approx_green[5:0] = sum_green[7:2] + 6'd1;
                error_green = 7'b1111111; // -1
            end
        endcase
        // blue
        case (sum_blue[2:0])
            3'b000: begin
                approx_blue[5:0] = sum_blue[7:2];
                error_blue = 7'b0000000; // +0
            end
            3'b001: begin
                approx_blue[5:0] = sum_blue[7:2];
                error_blue = 7'b0000001; // +1
            end
            3'b010: begin
                approx_blue[5:0] = sum_blue[7:2];
                error_blue = 7'b0000010; // +2
            end
            3'b011: begin
                approx_blue[5:0] = sum_blue[7:2] + 6'd1;
                error_blue = 7'b1111111; // -1
            end
            3'b100: begin
                approx_blue[5:0] = sum_blue[7:2];
                error_blue = 7'b0000000; // +0
            end
            3'b101: begin
                approx_blue[5:0] = sum_blue[7:2];
                error_blue = 7'b0000001; // +1
            end
            3'b110: begin
                approx_blue[5:0] = sum_blue[7:2] + 6'd1;
                error_blue = 7'b1111110; // -2
            end
            3'b111: begin
                approx_blue[5:0] = sum_blue[7:2] + 6'd1;
                error_blue = 7'b1111111; // -1
            end
        endcase
        
      // color saturation
        // red
        case (approx_red[5:4])
            2'b01: result[11:8] = 4'd15;
            2'b00: result[11:8] = approx_red[3:0];
            default: result[11:8] = 4'd0;
        endcase
        // green
        case (approx_green[5:4])
            2'b01: result[7:4] = 4'd15;
            2'b00: result[7:4] = approx_green[3:0];
            default: result[7:4] = 4'd0;
        endcase
        // blue
        case (approx_blue[5:4])
            2'b01: result[3:0] = 4'd15;
            2'b00: result[3:0] = approx_blue[3:0];
            default: result[3:0] = 4'd0;
        endcase
    end
    
    always_comb begin
      // default values
        next_state = state;
        next_x = x;
        next_y = y;
        next_quant = quantization;
        case (state)
            INACTIVE: begin
                next_rgb = 12'd0;
                sum_red[7:0] = 8'd0;
                sum_green[7:0] = 8'd0;
                sum_blue[7:0] = 'd0;
                if (synch_pulse == 1'b1) begin
                    next_state = ACTIVE;
                end
            end
            ACTIVE: begin
                // shift left the rest of the erros
                next_quant = quantization << 21;
                next_rgb = result;
                if (x == (H_SIZE - 1)) begin
                    next_x = 10'd0;
                    next_state = INACTIVE;
                    if (y == V_SIZE)
                        next_y = 10'd0;
                    else
                        next_y = y + 10'd1;
                end
                else
                    next_x = x + 10'd1;
                // calculate current pixel value
                sum_red[7:0] = {2'd0, raw_rgb[17:12]} +  {quantization[0][R][6], quantization[0][R][6], quantization[0][R][6], quantization[0][R][6], quantization[0][R][6], quantization[0][R][6], quantization[0][R][5:4]};
                sum_green[7:0] = {2'd0, raw_rgb[11:6]} + {quantization[0][G][6], quantization[0][G][6], quantization[0][G][6], quantization[0][G][6], quantization[0][G][6], quantization[0][G][6], quantization[0][G][5:4]};
                sum_blue[7:0] = {2'd0, raw_rgb[5:0]} +   {quantization[0][B][6], quantization[0][B][6], quantization[0][B][6], quantization[0][B][6], quantization[0][B][6], quantization[0][B][6], quantization[0][B][5:4]};
              // accumuluate error on adjacent pixels
                // Upper right pixel
                if (x == (H_SIZE - 1)) begin
                    next_quant[0][R][6:0] = 7'd0;
                    next_quant[0][G][6:0] = 7'd0;
                    next_quant[0][B][6:0] = 7'd0;
                end
                else begin
                    next_quant[0][R][6:0] = quantization[0][R][6:0] + error_red[6:0] * UR;
                    next_quant[0][G][6:0] = quantization[0][G][6:0] + error_green[6:0] * UR;
                    next_quant[0][B][6:0] = quantization[0][B][6:0] + error_blue[6:0] * UR;
                end
                // Down left pixel
                if (y == (V_SIZE - 1) || x == 0) begin
                    next_quant[(H_SIZE - 1)][R][6:0] = 7'd0;
                    next_quant[(H_SIZE - 1)][G][6:0] = 7'd0;
                    next_quant[(H_SIZE - 1)][B][6:0] = 7'd0;
                end
                else begin
                    next_quant[(H_SIZE - 1)][R][6:0] = quantization[H_SIZE][R][6:0] + error_red[6:0] * DL;
                    next_quant[(H_SIZE - 1)][G][6:0] = quantization[H_SIZE][G][6:0] + error_green[6:0] * DL;
                    next_quant[(H_SIZE - 1)][B][6:0] = quantization[H_SIZE][B][6:0] + error_blue[6:0] * DL;
                end
                // Down center pixel
                if (y == (V_SIZE - 1)) begin
                    next_quant[H_SIZE][R][6:0] = 7'd0;
                    next_quant[H_SIZE][G][6:0] = 7'd0;
                    next_quant[H_SIZE][B][6:0] = 7'd0;
                end
                else begin
                    next_quant[H_SIZE][R][6:0] = quantization[(H_SIZE + 1)][R][6:0] + error_red[6:0] * DC;
                    next_quant[H_SIZE][G][6:0] = quantization[(H_SIZE + 1)][G][6:0] + error_green[6:0] * DC;
                    next_quant[H_SIZE][B][6:0] = quantization[(H_SIZE + 1)][B][6:0] + error_blue[6:0] * DC;
                end
                // Down right pixel
                if (y == (V_SIZE - 1) || x == (H_SIZE - 1)) begin
                    next_quant[(H_SIZE + 1)][R][6:0] = 7'd0;
                    next_quant[(H_SIZE + 1)][G][6:0] = 7'd0;
                    next_quant[(H_SIZE + 1)][B][6:0] = 7'd0;
                end
                else begin
                    next_quant[(H_SIZE + 1)][R][6:0] = error_red[6:0] * DR;
                    next_quant[(H_SIZE + 1)][G][6:0] = error_green[6:0] * DR;
                    next_quant[(H_SIZE + 1)][B][6:0] = error_blue[6:0] * DR;
                end
            end
        endcase
    end
    
endmodule
