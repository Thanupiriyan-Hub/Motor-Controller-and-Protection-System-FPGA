`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 11/21/2024 10:27:35 PM
// Design Name: 
// Module Name: TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module TOP(
    input wire clk,
    input wire [4:0] btn,
    input wire [15:0] sw,
    input wire RX,
    input wire vibration_sensor,
    output wire [15:0] led,
    output wire [7:0] cat,
    output wire [7:0] an,
    output wire TX,
    inout wire TMP_SCL,
    inout wire TMP_SDA,
    output wire green_LED,
    output wire red_LED,
    output wire motor_green_LED,
    output wire motor_red_LED,
    output wire BlueTest,
    output wire blue_led,
    output wire motor_relay,
    output wire drive_en,
    output wire drive_dir,
    output wire drive_step
);


    //Internal signal declarations
    wire [12:0] tempValue;
    wire tempRdy, tempErr;
    wire [15:0] realValue;
    wire [31:0] date;
    wire [7:0] rx_8;
    wire btn_rst, btn_start;
    wire [7:0] trimitere_mesaje;
    wire start, activ, done;
    wire [7:0] asciiUnit, asciiZeci;
    wire [23:0] message;
    wire clk_1_sec;
    wire broadcast, send;

    // Motor controller signals
    wire [7:0] motor_led;
   // wire [31:0] vibrationCountInternal;
    
    // VHDL submodule instances
    TempSensorCtl #(
        .CLOCKFREQ(100)
    ) Inst_TempSensorCtl (
        .TMP_SCL(TMP_SCL),
        .TMP_SDA(TMP_SDA),
        .TEMP_O(tempValue),
        .RDY_O(tempRdy),
        .ERR_O(tempErr),
        .CLK_I(clk),
        .SRST_I(btn_rst)
    );

    HexToDecimalConverter DecimalConverter (
        .hexValue(realValue),
        .decValue(date[15:0])
    );

    displ7seg afisor (
        .Clk(clk),
        .Rst(btn_rst),
        .Data(date),
        .An(an),
        .Seg(cat)
    );

    mpg btn_c (
        .btn(btn[0]),
        .clk(clk),
        .en(btn_rst)
    );

    mpg btn_u (
        .btn(btn[1]),
        .clk(clk),
        .en(btn_start)
    );

    UART_tx #(
        .g_CLKS_PER_BIT(10416)
    ) b1_tx (
        .i_Clk(clk),
        .i_TX_DV(start),
        .i_TX_Byte(trimitere_mesaje),
        .o_TX_Active(activ),
        .o_TX_Serial(TX),
        .o_TX_Done(done)
    );

    DecToAsciiConverter DecToAsciiUnit (
        .decDigit(date[3:0]),
        .asciiValue(asciiUnit)
        //.vibrationSensor(vibration_sensor),
        //.vibrationCountOut(),
       // .clk(clk)
    );

    DecToAsciiConverter DecToAsciiZeci (
        .decDigit(date[7:4]),
        .asciiValue(asciiZeci)
        //.vibrationSensor(vibration_sensor),
        //.vibrationCountOut(vibrationCountInternal),
        //.clk(clk)
    );

    FrequencyDivider OneSecClock (
        .CLK(clk),
        .CLK_1_sec(clk_1_sec)
    );

    TemperatureBroadcast TempBroadcast (
        .CLK(clk_1_sec),
        .CurrTemp(realValue),
        .Broadcast(broadcast)
    );

    UCC unitate_cc (
        .clk(clk),
        .rst(btn_rst),
        .btn_start(send),
        .date_intrare(message),
        .activ(activ),
        .done(done),
        .date_iesire(trimitere_mesaje),
        .start(start)
    );

// Motor controller instantiation
    motor_controller motor_controller_inst (
        .int_clk(clk),                       // Internal clock
        .vibration_sensor(vibration_sensor), // Vibration sensor input
        .blue_led(blue_led),                 // Blue LED output
        .panic_btn(btn[2]),                  // Panic button input
        .drive_en(drive_en),                 // Drive enable signal
        .drive_dir(drive_dir),               // Drive direction signal
        .drive_step(drive_step),             // Drive step signal
        .din(RX),                            // UART RX input
        .green_LED(green_LED),               // Green LED output
        .red_LED(red_LED),                   // Red LED output
        .motor_green_LED(motor_green_LED),   // Motor green LED
        .motor_red_LED(motor_red_LED),       // Motor red LED
        .motor_relay(motor_relay),           // Motor relay output
        .led(motor_led)                      // Motor-related LEDs
    );

// Internal signal declarations
reg [31:0] vibrationCountInternal;

// Increment vibration count based on vibration sensor
always @(posedge clk) begin
    if (vibration_sensor) begin
        if (vibrationCountInternal < 100000) begin
            vibrationCountInternal <= vibrationCountInternal + 1; // Increment count
        end else begin
            vibrationCountInternal <= 0; // Reset count if limit is reached
        end
    end else begin
        vibrationCountInternal <= 0; // Reset count if sensor is inactive
    end
end

        // Logic for message assignment
        wire vibration_triggered;
        // Turn on BlueTest LED when vibration_triggered is high
        assign BlueTest = vibration_triggered;
        assign vibration_triggered = (vibrationCountInternal > 99999);
        assign message = vibration_triggered ? {8'h0A, 8'h31, 8'h31} : {8'h0A, asciiZeci, asciiUnit};

    assign realValue = tempValue * 625 / 10000;
    //assign message = {8'h0A, asciiZeci, asciiUnit};
    assign send = btn_start | broadcast;
    assign led = {8'b0, motor_led};  // Upper 8 bits for motor controller status

endmodule
