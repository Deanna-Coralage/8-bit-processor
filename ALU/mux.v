`timescale 1ns/100ps

/*                                          ALU FUNCTIONS
                                MODULE FOR THE SELECTION(MUX) FUNCTIONAL UNIT                          */



module MUX_4x1 (OUT, SEL, IN_fwd, IN_add, IN_and, IN_or);

    // Input output port declaration
    input [7:0] IN_fwd, IN_add, IN_and, IN_or;         // outputs from functional units
    input [2:0] SEL;                                   // SELECT input of register file is connected to this
    output reg [7:0] OUT;                              // to store output of the mux


    always @ (SEL, IN_fwd, IN_add, IN_and, IN_or)
    begin
        case (SEL)
        3'b000 : 
            OUT = IN_fwd;
        3'b001 :
            OUT = IN_add;
        3'b010 :
            OUT = IN_and;
        3'b011 :
            OUT = IN_or;
        default:
            OUT = 8'bx;            // for any undefined combination of select, assign x
        endcase
    end


endmodule


