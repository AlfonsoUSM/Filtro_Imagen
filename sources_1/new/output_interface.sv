`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2020 19:36:17
// Design Name: 
// Module Name: output_interface
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

    output_interface #(.H_SIZE(607), .V_SIZE(455)) instance_name (
       .clk(),          // 1 bit Input: vga pixel clock signal
       .reset(),        // 1 bit Input: CPU reset signal
       .h_count(),      // 11 bits Input: vga horizontal count
       .v_count(),      // 10 bits Input: vga vertical count
       .synch_pulse(),  //1 bit Output: image start of line synchronization pulse
       .r_data(),       // 18 bits Output: bram read data
       .r_address(),    // 19 bits Output: bram read address
       .raw_rgb()       // 18 bits Output: raw rgb pixel (6 bits per color)
    );
    
*/ //////////////////////////////////////////////////////

module output_interface #(parameter H_SIZE = 607, V_SIZE = 455)(
    input clk,
    input reset,
    input [10:0] h_count,
    input [9:0] v_count,
    input [17:0] r_data,
    output synch_pulse,
    output [18:0] r_address,
    output [17:0] raw_rgb
    );
        
    localparam X_OFSET = 500;
    localparam Y_OFSET = 150;
    
    enum logic [1:0] {INACTIVE_LINE, ACTIVE, INACTIVE_SCREEN} state, next_state;
    logic [17:0] rgb, next_rgb;
    logic [18:0] read_addr, next_addr;
    logic [9:0] x, y, next_x, next_y;
    logic start, next_start;
    
    assign raw_rgb = rgb;
    assign r_address = read_addr;
    assign synch_pulse = start;
    
    always_ff @ (posedge clk) begin
        if (reset == 1'b1) begin
            state <= INACTIVE_SCREEN;
            x <= 10'd0;
            y <= 10'd0;
            read_addr <= 19'd0;
            rgb <= 18'd0;
            start <= 1'b0;
        end
        else begin
            state <= next_state;
            x <= next_x;
            y <= next_y;
            read_addr <= next_addr;
            rgb <= next_rgb;
            start <= next_start;
        end
    end
    
    
    always_comb begin
        // default values
        next_state = state;
        next_addr = read_addr;
        next_rgb = rgb;
        next_x = x;
        next_y = y;
        next_start = 1'b0;
        case (state)
            INACTIVE_LINE: begin
                if (h_count == (X_OFSET - 3))
                    next_start = 1'b1;
                if (h_count == (X_OFSET - 1)) begin
                    next_state = ACTIVE;
                end
                next_rgb = 18'd0;
            end
            ACTIVE: begin
                next_rgb = r_data; //r_data;
                next_addr = read_addr + 19'd1;
                if (x == (H_SIZE - 1)) begin
                    next_x = 0;
                    if (y == (V_SIZE -1)) begin
                        next_state = INACTIVE_SCREEN;
                        next_y = 10'd0; 
                        next_addr = 19'd0;
                    end
                    else begin
                        next_state = INACTIVE_LINE;
                        next_y = y + 10'd1;
                    end
                end
                else begin
                    next_x = x + 10'd1;
                end
            end
            INACTIVE_SCREEN: begin
                next_rgb = 18'd0;
                if (v_count == (Y_OFSET)) begin
                    next_state = INACTIVE_LINE;
                end
            end
            default: begin
            end
        endcase
    end
 
endmodule
