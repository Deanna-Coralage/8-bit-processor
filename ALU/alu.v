`timescale 1ns/100ps

/*                                              ALU module                                  */

// Including verilog files of sub-modules
`include "ALU/funcUnits.v"
`include "ALU/mux.v"


module alu (DATA1, DATA2, RESULT, ZERO, SELECT);


    // Input output port declaration--
    input [7:0] DATA1, DATA2;
    input [2:0] SELECT;
    output [7:0] RESULT;
    output ZERO;
    // -------------------------------


    // Declaring wires to connect the outputs of functional units
    wire [7:0] OUT_fwd, OUT_add, OUT_and, OUT_or;


    // Instantiation of modules of functional units
    FORWARD_8bit forwardUnit (DATA2, OUT_fwd);          // DATA2 is passed as input 
    ADDER_8bit adderUnit (DATA1, DATA2, OUT_add);
    AND_8bit andUnit (DATA1, DATA2, OUT_and);    
    OR_8bit orUnit (DATA1, DATA2, OUT_or);


    // Instantiating a MUX, output of mux is connected to RESULT port of ALU
    MUX_4x1 muxUnit (RESULT, SELECT, OUT_fwd, OUT_add, OUT_and, OUT_or);

    // nor gate to check if the RESULT is 0
    nor NOR_RESULT (ZERO, RESULT[0], RESULT[1], RESULT[2], RESULT[3], RESULT[4], RESULT[5], RESULT[6], RESULT[7]);

    
endmodule
