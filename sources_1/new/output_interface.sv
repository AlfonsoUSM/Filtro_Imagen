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
       .pixel_clk(),    // 1 bit Input: vga clok
       .x(),            // 10 bits Input: vga horizontal count
       .y(),            // 10 bits Input: vga vertical count
       .r_data(),       // 18 bits Output: bram read data
       .r_address(),    // 19 bits Output: bram read address
       .raw_rgb()       // 18 bits Output: raw rgb pixel (6 bits per color)
    );
    
*/ //////////////////////////////////////////////////////

module output_interface #(parameter H_SIZE = 607, V_SIZE = 455)(
    input clk,
    input reset,
    input pixel_clk,
    input [9:0] x,
    input [9:0] y,
    input [17:0] r_data,
    output [18:0] r_address,
    output [17:0] raw_rgb
    );
    
    localparam PIXELS = H_SIZE * V_SIZE;
    localparam SCREEN = 525;
    localparam LINE =   800;
    
    enum logic {ACTIVE, INACTIVE} state, next_state;
    logic pixel_flag;
    logic [17:0] rgb, next_rgb;
    logic [18:0] read_addr, next_addr;
    
    assign raw_rgb = rgb;
    assign r_address = read_addr;
    
    always_ff @ (posedge clk) begin
        if (reset == 1'b1) begin
            state <= ACTIVE;
            read_addr <= 19'd2;
            rgb <= 18'd0;
        end
        else begin
            state <= next_state;
            read_addr <= next_addr;
            rgb <= next_rgb;
        end
    end
    
    always_comb begin
        // default values
        next_state = state;
        next_addr = read_addr;
        next_rgb = rgb;
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
            next_rgb = 18'b0;
            if (pixel_flag == 1'b1) begin
                if (y == (SCREEN - 1) && x == (LINE - 4))
                    next_state = ACTIVE;
            end                
        end
    end
    
    single_posedge_detector pixel_posedge_detector ( //  
        .clk(clk),             // 1 bit INPUT : clock
        .reset(reset),           // 1 bit INPUT : reset
        .in_signal(pixel_clk),       // 1 bit INPUT : input signal
        .signal_edges(pixel_flag)     // 1 bit OUTPUT : signal posedges 
    );
    
    
    
endmodule
