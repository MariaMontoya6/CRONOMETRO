// Cronometer implementation in Verilog for an FPGA board with 6 seven-segment displays and 2 buttons
module Chronometer (
    input  wire CLOCK_50,      // Principal clock of 50 Mhz
    input  wire A,             // KEY0: boton for start and pause 
    input  wire B,             // KEY1: boton for reset
    output reg  [6:0] HEX0,
    output reg  [6:0] HEX1,
    output reg  [6:0] HEX2,
    output reg  [6:0] HEX3,
    output reg  [6:0] HEX4,
    output reg  [6:0] HEX5
);
    // Clock divider

    reg [18:0] div_cnt = 19'd0;   
    reg tick_10ms = 1'b0;

    always @(posedge CLOCK_50) begin
        if (div_cnt == 19'd499_999) begin
            div_cnt   <= 19'd0;
            tick_10ms <= 1'b1;
        end else begin
            div_cnt   <= div_cnt + 1'b1;
            tick_10ms <= 1'b0;
        end
    end

    
    // Anti-debounce 
    
    reg [15:0] shA = 16'h0, shB = 16'h0;
    reg btnA_db = 1'b0, btnB_db = 1'b0;

    always @(posedge CLOCK_50) begin
        shA <= {shA[14:0], A};
        shB <= {shB[14:0], B};
        btnA_db <= &shA;  // when the 16 bits are 1
        btnB_db <= &shB;
    end

    
    reg btnA_prev = 1'b0, btnB_prev = 1'b0;
    wire start_pulse = btnA_db & ~btnA_prev;
    wire reset_pulse = btnB_db & ~btnB_prev;

    always @(posedge CLOCK_50) begin
        btnA_prev <= btnA_db;
        btnB_prev <= btnB_db;
    end

    //Chronometer logic 
    
    reg running = 1'b0;
    reg [3:0] cent  = 4'd0;   // centésimas (0-9)
    reg [3:0] deci  = 4'd0;   // décimas   (0-9)
    reg [5:0] sec   = 6'd0;   // segundos  (0-59)
    reg [5:0] min   = 6'd0;   // minutos   (0-59)

    always @(posedge CLOCK_50) begin
        if (reset_pulse) begin
            running <= 1'b0;
            cent <= 0; deci <= 0; sec <= 0; min <= 0;
        end
        else if (start_pulse) begin
            running <= ~running; // toggle start/pause
        end
        else if (tick_10ms && running) begin
            // cada 10 ms aumenta centésimas
            if (cent == 4'd9) begin
                cent <= 0;
                if (deci == 4'd9) begin
                    deci <= 0;
                    if (sec == 6'd59) begin
                        sec <= 0;
                        if (min == 6'd59) min <= 0;
                        else min <= min + 1'b1;
                    end else sec <= sec + 1'b1;
                end else deci <= deci + 1'b1;
            end else cent <= cent + 1'b1;
        end
    end

    //7 segments display decoder

    function [6:0] seg7;
        input [3:0] d;
        case (d)
            4'd0: seg7 = 7'b1000000;
            4'd1: seg7 = 7'b1111001;
            4'd2: seg7 = 7'b0100100;
            4'd3: seg7 = 7'b0110000;
            4'd4: seg7 = 7'b0011001;
            4'd5: seg7 = 7'b0010010;
            4'd6: seg7 = 7'b0000010;
            4'd7: seg7 = 7'b1111000;
            4'd8: seg7 = 7'b0000000;
            4'd9: seg7 = 7'b0010000;
            default: seg7 = 7'b1111111;
        endcase
    endfunction

    always @(*) begin
        HEX0 = seg7(cent);          // hundredths
        HEX1 = seg7(deci);          // decimals
        HEX2 = seg7(sec % 10);      // seconds units
        HEX3 = seg7(sec / 10);      // seconds tenths
        HEX4 = seg7(min % 10);      // minutes units
        HEX5 = seg7(min / 10);      // minutes tenths
    end

endmodule