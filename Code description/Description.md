# Description of the code

In this section, you will find the explanation of the code in sections.

```verilog
module Chronometer (
    input  wire CLOCK_50,      // 50 Mhz clock
    input  wire A,             // KEY0: start/pause
    input  wire B,             // KEY1: reset
    output reg  [6:0] HEX0,
    output reg  [6:0] HEX1,
    output reg  [6:0] HEX2,
    output reg  [6:0] HEX3,
    output reg  [6:0] HEX4,
    output reg  [6:0] HEX5
);
```

This is the module description. We have the module name and its inputs. Although all inputs for this board (the ones already included by default) are of type wire, we explicitly declare them as such for good practice, keeping in mind that wire does not store values and literally represents a physical connection. We use output reg so that the outputs retain their value until a new one is assigned, and also as a good practice since reg has memory.

```verilog
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
```

First, a 19-bit register is created to serve as the counter register. Nineteen bits are sufficient for the range we need to represent, and this register is initialized to zero.

Next, another register is created to act as our clock signal that generates a tick every 10 ms (the advance signal), which is also initialized to zero.

Then, on every rising edge of the main 50 MHz clock, the system checks whether the counter has reached the end of its cycle. If it has, the 10 ms tick is set to 1; otherwise, it remains at 0 while the counter increments by 1.

The number of cycles is determined based on the minimum resolution required for our counter and is calculated using the formula cycles = frequency × period. In this case, the resulting frequency is 100 Hz (since 10 ms × 10 = 0.1 s).

```verilog
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

```

It is known that mechanical buttons have a bouncing problem and can generate incorrect or unstable signals. Therefore, for our specific application that requires precision, a debouncing mechanism is implemented. This system determines that the button is pressed only when 16 consecutive samples confirm it. This approach is feasible because the main clock frequency is quite high, making those 16 samples correspond to an insignificant amount of time while pressing the button (approximately 0.5 ms).

```verilog
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
```

First, several registers are declared. The first one indicates whether the stopwatch is currently running or not, which allows a single button to perform almost inverse functions.

For the hundredths and tenths of a second, only 4 bits are used, while 6 bits are used for the seconds and minutes. When the reset signal is activated, everything else is ignored, and the entire system stops.

Since only two buttons are used, the start/pause button is configured so that when pressed, it toggles the register indicating whether the stopwatch is running — changing its state each time it is pressed (toggle function).

Finally, through a series of conditional statements, the hundredths, seconds, and other time units increment by one unless they reach their maximum value, in which case the next time unit is incremented. In this way, the time count progresses sequentially.

```verilog
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
```

It performs the translation of each number to its corresponding 7-segment representation (considering that these values are "inverted" if the display is common cathode, as the FPGA is common cathode). Then, each display is assigned a specific “time” unit.

For hundredths and tenths, it is not necessary to divide by 2 because they only range from 0 to 9. However, for seconds and minutes, division by 10 is applied to obtain the units (using the modulo operation) and the division result is used for the tens.
