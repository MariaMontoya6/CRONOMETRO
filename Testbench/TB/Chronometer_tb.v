`timescale 1ns / 1ps
`include "Chronometer.v"

module Chronometer_tb;

    // Inputs
    reg CLOCK_50;
    reg A;
    reg B;

    // Outputs
    wire [6:0] HEX0;
    wire [6:0] HEX1;
    wire [6:0] HEX2;
    wire [6:0] HEX3;
    wire [6:0] HEX4;
    wire [6:0] HEX5;

    // Instantiate the Unit Under Test (UUT)
    chronometer uut (
        .CLOCK_50(CLOCK_50), 
        .A(A), 
        .B(B), 
        .HEX0(HEX0), 
        .HEX1(HEX1), 
        .HEX2(HEX2), 
        .HEX3(HEX3), 
        .HEX4(HEX4), 
        .HEX5(HEX5)
    );

    initial begin

        $dumpfile("Chronometer_tb.vcd");
        $dumpvars(0, Chronometer_tb);

        // Initialize Inputs
        CLOCK_50 = 0;
        A = 0; // Not pressed
        B = 0; // Not pressed

        // Wait 100 ns for global reset to finish
        #100;
        
        // Start the chronometer
        A = 0; #20; A = 1; // Press and release A
        #100000000; // Wait for some time (simulate running)
        
        // Pause the chronometer
        A = 0; #20; A = 1; // Press and release A
        #50000000; // Wait for some time (simulate paused)
        
        // Resume the chronometer
        A = 0; #20; A = 1; // Press and release A
        #100000000; // Wait for some time (simulate running)
        
        // Reset the chronometer
        B = 0; #20; B = 1; // Press and release B
        
        // Finish simulation after some time
        #10000000;
        $finish;

        $display("Simulation complete");
    end
    
    // Clock generation
    always #10 CLOCK_50 = ~CLOCK_50; // 50 MHz clock
