`timescale 1ns / 1ps

module protection_module(panic_btn, panic);

    input panic_btn;
    output panic;

    assign panic = panic_btn;

endmodule
