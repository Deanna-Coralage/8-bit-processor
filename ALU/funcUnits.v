`timescale 1ns/100ps

/*                                          ALU FUNCTIONAL UNITS MODULES                                    */



// ********************** FORWARD FUNCTIONAL UNIT *************************
module FORWARD_8bit (IN, OUT);

    // Input output port declaration
    input [7:0] IN;
    output [7:0] OUT;
                  
    assign #1  OUT = IN;           // delay 1 simulation time unit    

endmodule
// ************************************************************************



// ************************ ADDER FUNCTIONAL UNIT *************************
module ADDER_8bit (IN1, IN2, OUT);    

    // Input output port declaration
    input [7:0] IN1, IN2;
    output [7:0] OUT;

    assign #2 OUT = IN1 + IN2;            // delay 2 simulation time units

endmodule
// ************************************************************************



// *************************** AND FUNCTIONAL UNIT ************************
module AND_8bit (IN1, IN2, OUT);

    // Input output port declaration 
    input [7:0] IN1, IN2;
    output [7:0] OUT;

    assign #1 OUT = IN1 & IN2;        // delay 1 simulation time unit

endmodule
// ************************************************************************



// ************************* OR FUNCTIONAL UNIT ***************************
module OR_8bit (IN1, IN2, OUT);

    // Input output port declaration 
    input [7:0] IN1, IN2;
    output [7:0] OUT;
       
    assign #1 OUT = IN1 | IN2;        // delay 1 simulation time unit

endmodule
// ************************************************************************