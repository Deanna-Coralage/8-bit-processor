/*                                          ALU FUNCTIONS
                                MODULE FOR THE SELECTION(MUX) FUNCTIONAL UNIT                          */



module MUX_8x1 (OUT, SEL, IN_fwd, IN_add, IN_and, IN_or, IN_mult, IN_sl, IN_sr);

    // Input output port declaration
    input [7:0] IN_fwd, IN_add, IN_and, IN_or;         // outputs from functional units
    input [7:0] IN_mult, IN_sl, IN_sr;
    input [2:0] SEL;                                   // SELECT input of register file is connected to this
    output reg [7:0] OUT;                              // to store output of the mux


    always @ (SEL, IN_fwd, IN_add, IN_and, IN_or, IN_mult, IN_sl, IN_sr)
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
        3'b100 :
            OUT = IN_mult;
        3'b101 :
            OUT = IN_sl;
        3'b110 :
            OUT = IN_sr;
        endcase
    end


endmodule