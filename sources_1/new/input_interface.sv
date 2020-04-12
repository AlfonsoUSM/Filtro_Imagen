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

    input_interface #(.PIXELS(276185)) instance_name (
        .clk(),             // 1 bit Input: clock signal
        .reset(),           // 1 bit Input: CPu reset signal
        .uart_rx(),         // 1 bit Input: serial receive signal
        .wea(),             // 1 bit Output: bram write enable signal
        .w_data(),          // 18 bits Output: bram write data word
        .w_address(),       // 19 bits Output: bram write address
        .done()             // 1 bit picture loaded flags
    );
    
*/ //////////////////////////////////////////////////////

module input_interface #(parameter PIXELS = 276185) (
    input clk,
    input reset,
    input uart_rx,
    output wea,
    output [17:0] w_data,
    output [18:0] w_address,
    output done
    );
    
    //localparam PIXELS = 19'd276_185; // RAM_SIZE = 19'd276480
    enum logic {RECEIVE, LOADED} state, next_state;
   
    logic rx_flag;                      // uart's byte received flag
    logic finished;
    logic write_enable;                 // memory side A enable & write enable
    logic [7:0] rx_byte;                // received byte from uart
    logic [1:0] index, next_index;                          // to count 3 color bytes per pixel
    logic [11:0] w_data_msb, next_data_msb;  // buffer for keeping first 2 colors (6msbs from each color byte)
    logic [18:0] write_address, next_addr;                      // write address
        
    assign wea = write_enable;
    assign done = finished;
    assign w_address = write_address;
    assign w_data[17:0] = {w_data_msb[11:0], rx_byte[7:2] }; // write data array, 3 colors (6msbs from each color byte)
    
    always_ff @ (posedge clk) begin
        if (reset == 1'b1) begin
            state <= RECEIVE;
            index[1:0] <= 2'b0;
            w_data_msb[11:0] <= 12'b0;
            write_address[18:0] <= 19'b0;
        end
        else begin
            state <= next_state;
            index[1:0] <= next_index[1:0];
            w_data_msb[11:0] <= next_data_msb;
            write_address[18:0] <= next_addr[18:0];
        end
    end
    
    always_comb begin
        finished = 1'b0;
        next_state = state; // deafault next state
        next_data_msb[11:0] = w_data_msb[11:0];
        next_addr[18:0] = write_address[18:0];
        next_index[1:0] = index[1:0];
        write_enable = 1'b0;
        case (state)
            RECEIVE: begin
                write_enable = 1'b1;
                if (rx_flag == 1'b1) begin
                    next_data_msb[11:0] = {w_data_msb[5:0], rx_byte[7:2] }; 
                    if (index[1:0] == 2'b10) begin
                        next_index[1:0] = 2'b0;
                        if (write_address == (PIXELS - 1))
                            next_state = LOADED;
                        else
                            next_addr = write_address + 19'd1; 
                    end
                    else
                        next_index[1:0] = index[1:0] + 2'b1;
                end
            end
            LOADED: begin
                write_enable = 1'b0;
                finished = 1'b1;
            end 
        endcase
    end
    
    always_comb begin
    
    end
    
    uart_rx #(.CLKS_PER_BIT(100)) uart_receiver(
        .Clock(clk),
        .reset(reset),
        .Rx_Serial(uart_rx),
        .Rx_DV(rx_flag),
        .Rx_Byte(rx_byte[7:0])
    );
endmodule