module top_module(
    input clk,
    input rst,
    
    input enterA,
    input enterB,
    input [2:0] letterIn,            
    
    output [7:0] led,
    output a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out,
    output [3:0] an
);
    
    wire clk_50hz;
    wire clean_enterA, clean_enterB;

    
    wire [7:0] led_game_signal; 
    
    wire [6:0] s3_wire;        
    wire [6:0] s2_wire;
    wire [6:0] s1_wire;
    wire [6:0] s0_wire;
   

    wire [7:0] s3_8bit;
    wire [7:0] s2_8bit;
    wire [7:0] s1_8bit;
    wire [7:0] s0_8bit;

    assign s3_8bit = {1'b0, s3_wire};
    assign s2_8bit = {1'b0, s2_wire};
    assign s1_8bit = {1'b0, s1_wire};
    assign s0_8bit = {1'b0, s0_wire};
    
    wire [7:0] seven_out;
    wire [3:0] segment_out;

    assign led = led_game_signal;

    assign a_out = seven_out[0];
    assign b_out = seven_out[1];
    assign c_out = seven_out[2];
    assign d_out = seven_out[3];
    assign e_out = seven_out[4];
    assign f_out = seven_out[5];
    assign g_out = seven_out[6];
    assign p_out = seven_out[7];

    assign an = segment_out;

    clk_divider u_clk_div (
        .clk_in(clk), 
        .divided_clk(clk_50hz)
    );

    debouncer db_playerA(
        .clk(clk_50hz),
        .rst(~rst),      
        .noisy_in(~enterA), 
        .clean_out(clean_enterA)
    );

    debouncer db_playerB(
        .clk(clk_50hz),
        .rst(~rst),      
        .noisy_in(~enterB), 
        .clean_out(clean_enterB)
    );

    mastermind u_game(
        .clk(clk_50hz),
        .rst(rst),         
        .enterA(clean_enterA),
        .enterB(clean_enterB),
        .letterIn(letterIn),

        .LEDX(led_game_signal), 
        .SSD3(s3_wire),
        .SSD2(s2_wire),
        .SSD1(s1_wire),
        .SSD0(s0_wire)
    );

    ssd u_display(
        .clk(clk),
        .disp0(s0_8bit), 
        .disp1(s1_8bit),
        .disp2(s2_8bit),
        .disp3(s3_8bit),
        .seven(seven_out),
        .segment(segment_out)
    );

endmodule