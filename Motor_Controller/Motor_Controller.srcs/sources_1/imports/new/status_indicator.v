`timescale 1ns / 1ps

module status_indicator(drive_clk, status, motor_green_LED, motor_red_LED);
    input drive_clk, status;
    output motor_green_LED, motor_red_LED;
    
    assign motor_green_LED = !status;
    assign motor_red_LED = status && drive_clk;
endmodule
