`timescale 1ns / 1ps

module motor_controller(int_clk,vibration_sensor, blue_led, panic_btn, drive_en, drive_dir, drive_step, din,green_LED, red_LED, motor_green_LED, motor_red_LED, motor_relay, led);

    input int_clk, panic_btn, din ,vibration_sensor;
    output drive_en, drive_dir, drive_step;
    output green_LED, red_LED, motor_green_LED, motor_red_LED, blue_led ;
    output motor_relay;
    output [7:0] led; 
  
  
    reg blue_led;
    wire drive_clk, panic;
    
    wire rx_dv;                // UART data valid signal
    wire [7:0] rx_byte;        // UART received byte
    wire [7:0] temp_data;
    reg state, en, dir, receiving;  
    
    assign led = rx_byte[7:0];
    
	initial begin
		state <= 1;
		en <= 0;
		dir <= 0;
	end
    
	UART_RX_NEW #(
        .g_CLKS_PER_BIT(10416)   // Set this according to baud rate and clock frequency
    ) UART_RX_NEW_inst (
        .i_Clk(int_clk),
        .i_RX_Serial(din),
        .o_RX_DV(rx_dv),           // Data valid signal
        .o_RX_Byte(rx_byte)        // Received byte
    );
    
    drive_clock module1 (int_clk, state, drive_clk,  panic, rx_byte);
    protection_module module3 (panic_btn, panic);
    status_indicator module4 (drive_clk, drive_en, motor_green_LED, motor_red_LED);
    
    assign drive_step = drive_clk;
    assign drive_en =  en;
    assign drive_dir = dir;
    assign motor_relay = !(panic);
    
     // Initial values
    initial begin
        en = 0;
        dir = 0;
    end
    
    // Logic to control motor enable and direction based on rx_byte
    always @(posedge int_clk) begin
        if (rx_dv) begin // Check if new data is valid
            case (rx_byte)
                8'b00000000: en <= 1; // Motor enable = 1
                8'b00000001: en <= 0; // Motor enable = 0
                8'b00000010: dir <= 1; // Motor direction = 1
                8'b00000011: dir <= 0; // Motor direction = 0
                default: begin
                    en <= en;  // Retain previous state for enable
                    dir <= dir; // Retain previous state for direction
                end
            endcase
        end
    end
    // Detecting IR Sensor
   // assign IR_detected = IR_sensor; // Directly output the state of the IR sensor
    always @(*) begin
    if (vibration_sensor) begin
        blue_led = 1;             // Turn on the LED if vibration sensor is high
        
    end else begin
        blue_led = 0;             // Turn off the LED if vibration sensor is low
        
    end
end

endmodule

module drive_clock (int_clk, run, drive_clk, panic_display,rx_byte);
	
	input int_clk, run, panic_display;
	input [7:0] rx_byte;
	output reg drive_clk;
	
	reg [25:0] counter;
	reg [12:0] drive_speed_init = 13'b0_0000_0000_0000;
	
	// Drive Speed: b1111,1110,0000,0000,0000 >>> b0000,0010,0000,0000,0000
	reg [25:0] drive_speed;
	
	
	initial begin
		counter <= 24'b0_0000_0000_0000_0000_0000;
	end
	
	always @(posedge int_clk) begin
	
		if (run) begin
			counter <= counter + 24'b0_0000_0000_0000_0000_0000_0001;
			
			if (counter == drive_speed) begin
				counter <= 24'b0_0000_0000_0000_0000_0000;
				drive_clk <= ~drive_clk;
			end
		end else begin
			counter <= drive_speed;
			drive_clk <= 0;
		end
	
	end
	

   always @(*) begin
    if (rx_byte >= 8'd5 && rx_byte <= 8'd185) begin
        // Invert and scale rx_byte to map it to the range [5 to 255] -> [8'b1111_1111 to 8'b0000_0101]
        drive_speed[19:12] = 8'd185 - (rx_byte - 8'd5);
        drive_speed[11:0] = drive_speed_init[11:0];
        drive_speed[25:20] = 6'b000000; // Assign all bits from 20 to 25 to 0
    end else begin
        drive_speed = 24'b0_0000_0111_0011_0000_0000_0000; // Retain previous value
    end
end

endmodule

