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
       .clk(),          // 1 bit Input: clock signal
       .reset(),        // 1 bit Input: CPU reset signal
       .pixel_clk(),    // 1 bit Input: vga pixel clock
       .h_count(),            // 11 bits Input: vga horizontal count
       .v_count(),            // 10 bits Input: vga vertical count
       .r_data(),       // 18 bits Output: bram read data
       .r_address(),    // 19 bits Output: bram read address
       .raw_rgb()       // 18 bits Output: raw rgb pixel (6 bits per color)
    );
    
*/ //////////////////////////////////////////////////////

module output_interface #(parameter H_SIZE = 607, V_SIZE = 455)(
    input clk,
    input reset,
    input pixel_clk,
    input [10:0] h_count,
    input [9:0] v_count,
    input [17:0] r_data,
    output [18:0] r_address,
    output [17:0] raw_rgb
    );
    
//    localparam PIXELS = H_SIZE * V_SIZE;
//    localparam V_ACT_END = 480;
//    localparam H_ACT_START = 160;
//    localparam H_IMAGE_END = H_ACT_START + H_SIZE;
//    localparam SCREEN = 525;
//    localparam LINE =   800;
    
    localparam X_OFSET = 290; // 500;
    localparam Y_OFSET = 10; // 150;
    
    enum logic [1:0] {INACTIVE_LINE, ACTIVE, INACTIVE_SCREEN} state, next_state;
    logic [17:0] rgb, next_rgb;
    logic [18:0] read_addr, next_addr;
    logic [9:0] x, y, next_x, next_y;
    
    assign raw_rgb = rgb;
    assign r_address = read_addr;
    
    always_ff @ (posedge pixel_clk) begin
        if (reset == 1'b1) begin
            state <= INACTIVE_SCREEN;
            x <= 10'd0;
            y <= 10'd0;
            read_addr <= 19'd0;
            rgb <= 18'd0;
        end
        else begin
            state <= next_state;
            x <= next_x;
            y <= next_y;
            read_addr <= next_addr;
            rgb <= next_rgb;
        end
    end
    
    
    always_comb begin
        // default values
        next_state = state;
        next_addr = read_addr;
        next_rgb = rgb;
        next_x = x;
        next_y = y;
        //if (pixel_clk == 1'b1) begin
            case (state)
                INACTIVE_LINE: begin
                    if (h_count == (X_OFSET- 1)) begin
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
        //end
    end
    
        
        /*if (v_count < V_SIZE) begin // inside the image
            if (h_count >= (H_ACT_START - 1)) begin
                if (h_count < (H_IMAGE_END)) begin
                    if (pixel_clk) begin
                        next_rgb = r_data;
                        if (read_addr == (PIXELS - 1)) begin
                            next_addr = 19'd0;
                        end
                        else
                            next_addr = read_addr + 19'd1; 
                    end
                end
                else
                    next_rgb = 18'b111111_111111_111111;
            end
            else
                next_rgb = 18'b111111_000000_000000;
        end
        else begin
            if (v_count < V_ACT_END) begin // out of the image, inside the screen 
                next_rgb = 18'b111111_111111_000000;
            end
            else begin  // outside the screen
                next_rgb = 18'b111111_000000_111111;
            end
        end
        if ( v_count == SCREEN && h_count == LINE )
            next_addr = 19'd0;
        */
            
            
        /*
        if (state == ACTIVE) begin
            if (pixel_flag == 1'b1) begin
                next_rgb = r_data;
                if (read_addr == (PIXELS - 1)) begin
                    next_addr = 19'd0;
                    next_state = INACTIVE;
                end
                else
                    next_addr = read_addr + 19'd1; 
            end
        end
        else begin      // state == INACTIVE
            //next_rgb = 18'b0;
            //if (pixel_flag == 1'b1) begin
                if (y == (SCREEN - 2) && x == (LINE - 4))
                    next_state = ACTIVE;
            //end                
        end
        */
 
endmodule
