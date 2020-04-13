`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.12.2019 11:51:41
// Design Name: 
// Module Name: topmodule
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


module topmodule(
    input CLK100MHZ,
    input CPU_RESETN,
    input [2:0] SW,
    input SW15,
    input UART_TXD_IN,
    output JA1,
    output [3:0] VGA_R,
    output [3:0] VGA_G, 
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output LED16_B
    //output CA, CB, CC, CD, CE, CF, CG,
    //output [7:0] AN
    //output [7:0]LED
    );
    
    logic serial;
    
    localparam H_SIZE = 607;
    localparam V_SIZE = 455;
    
    logic hsync, vsync;
    logic CLK78M75HZ;
    logic CLK25MHZ;
    //logic pulse78M75HZ;
    logic [3:0] Red, Green, Blue;
    logic vga_stb;
    logic hs1, vs1, hs2, vs2;
    logic [9:0] y, y1, x2, y2;
    logic [10:0] x, x1;
    
    assign VGA_HS = hsync;
    assign VGA_VS = vsync;
    
     //generate a 25 MHz pixel strobe
//    logic [3:0] cnt;
//    logic clk_stb;
//    always @(posedge CLK100MHZ)
//        {clk_stb, cnt} <= cnt + 4'h4;  // divide by 4: (2^16)/4 = 0x4000
    
    assign JA1 = UART_TXD_IN;
    
    
    always_comb begin
        if (SW15 == 1'b1) begin
            hsync = hs1;
            vsync = vs1;
            x = x1;
            y = y1;
            vga_stb = CLK78M75HZ;
        end
        else begin
            hsync = hs2;
            vsync = vs2;
            x = {1'b0, x2};
            y = y2;
            vga_stb = CLK25MHZ;
        end
    end
    
    logic [17:0] rgb ;
    logic loaded;
    assign LED16_B = loaded;
//    assign VGA_R[3:0] = rgb[17:14];
//    assign VGA_G[3:0] = rgb[11:8];
//    assign VGA_B[3:0] = rgb[5:2];

    /*
    // image simulation
    
    logic send, next_send;
    logic [7:0] tx_byte, next_tx_byte;
    logic [9:0] counter, next_counter;
    logic [18:0] r_address, v_offset, next_v_offset;
    
    //assign JA1 = serial;
    //assign JA3 = CLK100MHZ;
    //assign LED[1:0] = done [1:0];
    
    assign r_address = v_offset[18:0] + {8'b0, x[9:0]};
    
    always_ff @ (posedge CLK100MHZ) begin
        if (CPU_RESETN == 1'b0) begin
            tx_byte[7:0] <= 8'b0;
            counter[9:0] <= 10'd1;
            send <= 1'b1;
            v_offset[18:0] <= 19'b0;
        end
        else begin
            tx_byte[7:0] <= next_tx_byte[7:0];
            counter[9:0] <= next_counter[9:0];
            send <= next_send;
            v_offset[18:0] <= next_v_offset[18:0];
        end
    end
    
    always_comb begin
        next_tx_byte[7:0] = tx_byte[7:0];
        next_counter[9:0] = counter[9:0];
        next_send = 1'b0;
        if (done[0] == 1'b1)
            next_send = 1'b1;
        if (send == 1'b1) begin
            if ( counter[9:0] == H_SIZE ) begin
                next_counter[9:0] = 10'd1;
                next_tx_byte[7:0] = 8'b0;
            end
            else begin
                next_counter[9:0] = counter[9:0] + 10'd1;
                if ( tx_byte[7:0] == 8'd254 )
                    next_tx_byte[7:0] = 8'b0;
                else
                    next_tx_byte[7:0] = tx_byte[7:0] + 8'd1;
            end
        end
    end
    
    always_comb begin
        next_v_offset[18:0] = v_offset[18:0];
        if (x[9:0] == 10'd1023)
            next_v_offset[18:0] = v_offset[18:0] + V_SIZE;
    end*/
    
  
     // Four overlapping squares
//    wire sq_a, sq_b, sq_c, sq_d;
//    assign sq_a = ((x > 120) & (y >  40) & (x < 280) & (y < 200)) ? 1 : 0;
//    assign sq_b = ((x > 200) & (y > 120) & (x < 360) & (y < 280)) ? 1 : 0;
//    assign sq_c = ((x > 280) & (y > 200) & (x < 440) & (y < 360)) ? 1 : 0;
//    assign sq_d = ((x > 360) & (y > 280) & (x < 520) & (y < 440)) ? 1 : 0;

//    assign VGA_R[3] = sq_b;         // square b is red
//    assign VGA_G[3] = sq_a | sq_d;  // squares a and d are green
//    assign VGA_B[3] = sq_c;         // square c is blue

    PictureMemory #(.H_SIZE(H_SIZE), .V_SIZE(V_SIZE)) memory_ctrl(
        .clk(CLK100MHZ),         // 1 bit Input: base clock (BRAM side A)
        .reset(~CPU_RESETN),       // 1 bit Input: reset
        .uart_rx(UART_TXD_IN),     // 1 bit Input: receive serial
        .pixel_clk(vga_stb),   // 1 bit Input: pixel clock
        .h_count(x),           // 10 bits Input: vga horizontal count
        .v_count(y),           // 10 bits Input: vga vertical count
        .raw_rgb(rgb),         // 18 bits Output: raw rgb pixel (6x3 bit colour data)
        .loaded(loaded)       // 1 bit Output: image stored
    );
    
    image_editor instance_name(
      .clk(CLK100MHZ),
      .reset(~CPU_RESETN),
      .control(SW[2:0]),
      .raw_rgb(rgb),
      .rgb({VGA_R, VGA_G, VGA_B})
    );
   
//    uart #(.BAUD_RATE(1000000)) instance_name (
//        .clk(CLK100MHZ),         // 1 bit Input: clock
//        .reset(~CPU_RESETN),       // 1 bit Input: reset        
//        .Tx_Byte(SW[7:0]),     // 8 bits Input: data byte to send 
//        .Tx_Ready(1'b1),    // 1 bit Input: start transmittion
//        .Rx_Serial(serial),   // 1 bit Input: serial receive data pin
//        .Tx_Serial(serial),   // 1 bit Output: serial transmit data pin
//        .Tx_Active(),   // 1 bit Output: transmition in process
//        .Tx_Done(),     // 1 bit Output: transmittion completed pulse
//        .Rx_Byte(LED[7:0]),     // 8 bits Output: received data byte
//        .Rx_Flag()      // 1 bit Output: reception comleted pulse
//    );        

    
    clk_wiz_0 vga_clock_divider(
        .clk_in100MHZ(CLK100MHZ),       // input clk_in100MHZ
        .reset(~CPU_RESETN),            // input reset
        .locked(),                      // output locked
        .clk_out78M75HZ(CLK78M75HZ),   // output clk_out78M750HZ
        .clk_out25MHZ(CLK25MHZ)     // output clk_out25MHZ
    );
     
    vga1024x768 vga_synch(
        .clk(CLK100MHZ),         // 1 bit Input: base clock
        .pix_stb(CLK78M75HZ),     // 1 bit Input: pixel clock strobe
        .reset(~CPU_RESETN),       // 1 bit Input: reset: restarts frame
        .hsync(hs1),       // 1 bit Output: horizontal sync
        .vsync(vs1),       // 1 bit Output: vertical sync
        .blanking(),    // 1 bit Output: high during blanking interval
        .active(),      // 1 bit Output: high during active pixel drawing
        .screenend(),   // 1 bit Output: high for one tick at the end of screen
        .animate(),     // 1 bit Output: high for one tick at end of active drawing
        .x(x1),           // 11 bit Output: current pixel x position
        .y(y1)            // 10 bit Output: current pixel y position
    );
    
    vga640x480 vga2(
        .clk(CLK100MHZ),         // 1 bit Input: base clock
        .pix_stb(CLK25MHZ),     // 1 bit Input: pixel clock strobe
        .reset(~CPU_RESETN),       // 1 bit Input: reset: restarts frame
        .hsync(hs2),       // 1 bit Output: horizontal sync
        .vsync(vs2),       // 1 bit Output: vertical sync
        .blanking(),    // 1 bit Output: high during blanking interval
        .active(),      // 1 bit Output: high during active pixel drawing
        .screenend(),   // 1 bit Output: high for one tick at the end of screen
        .animate(),     // 1 bit Output: high for one tick at end of active drawing
        .x(x2),           // 10 bit Output: current pixel x position
        .y(y2)            // 10 bit Output: current pixel y position
    );
    
//    logic dispclk;
//    logic [31:0] display_bcd;
//    logic [4:0] bcd;
//    assign display_bcd = {27'd0, bcd};
    
//    clock_divider #(.d(1000)) instance_name(
//        .clk_in(CLK100MHZ),
//        .reset(~CPU_RESETN),
//        .clk_out(dispclk)
//    );
        
//    bin2bcd #(.W(4)) instance_n (   // input width
//        .bin(rgb[17:14]),       // binary
//        .bcd(bcd)        // bcd {...,thousands,hundreds,tens,ones}
//    );
    
//    segment7 display (
//        .clk(dispclk),
//        .reset(~CPU_RESETN),
//        .display_bcd(display_bcd),
//        .segments({AN[7:0], CA, CB, CC, CD, CE, CF, CG})
//    );
            
endmodule
