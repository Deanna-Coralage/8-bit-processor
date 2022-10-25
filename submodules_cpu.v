`timescale 1ns/100ps

/*                                      SUB MODULES OF THE CPU                             */  



// *********************************** MODULE FOR THE CONTROL UNIT *************************************
module control_unit (BUSYWAIT, INSTRUCTION, ALUOP, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, WRITEENABLE, READ, WRITE);


// Input output port declaration --------------
input BUSYWAIT;
input [31:0] INSTRUCTION;
output reg [2:0] ALUOP;
output reg WRITEENABLE;
output reg SEL_2scomp, SEL_immediate, SEL_regwritedata;               // selection inputs for the muxes
output reg [1:0] SEL_offset;
output reg READ, WRITE;
// --------------------------------------------


/* Generating control signals, Delay : 1s 
    OP-CODE DEFINITIONS
    ***********************
    op_loadi = "0000_0000"  
    op_mov   = "0000_0001"  
    op_add   = "0000_0010" 
    op_sub   = "0000_0011"  
    op_and   = "0000_0100"  
    op_or    = "0000_0101"  
    op_j     = "0000_0110"  
    op_beq   = "0000_0111"
    op_bne   = "0000_1101"
    op_lwd   = "0000_1110"
    op_lwi   = "0000_1111"
    op_swd   = "0001_0000"
    op_swi   = "0001_0001"
    ***********************

    ALUOP DEFINITIONS
    ***********************
    fwd = "000"  => loadi/mov/j
    add = "001"  => add/sub/beq/bne
    and = "010"
    or  = "011"
    ***********************

    SEL_offset DEFINITIONS
    ***********************
    ALU operation = "00"
    jump          = "01"
    beq           = "10"
    bne           = "11"   
    ***********************
*/

//reg WRITEENABLEin;

always @ (INSTRUCTION)
begin
    #1 case ( INSTRUCTION[31:24] )
    8'b0000_0000 :            
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b000_1_00_0_1_0_0_0;
    8'b0000_0001 : 
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b000_1_00_0_0_0_0_0;
    8'b0000_0010 :               
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b001_1_00_0_0_0_0_0;
    8'b0000_0011 :
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b001_1_00_1_0_0_0_0;
    8'b0000_0100 :               
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b010_1_00_0_0_0_0_0;
    8'b0000_0101 :                
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b011_1_00_0_0_0_0_0;
    8'b0000_0110 :
        {WRITEENABLE, SEL_offset, READ, WRITE}                                   				   = 5'b0_01_0_0;
    8'b0000_0111 :
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b001_0_10_1_0_0_0_0; 
    8'b0000_1101 :
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b001_0_11_1_0_0_0_0;
    8'b0000_1110 :
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b000_1_00_0_0_1_1_0;
    8'b0000_1111 :
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b000_1_00_0_1_1_1_0;
    8'b0001_0000 :
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b000_0_00_0_0_0_0_1;
    8'b0001_0001 :
        {ALUOP, WRITEENABLE, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, READ, WRITE} = 11'b000_0_00_0_1_0_0_1;
    endcase
end

always @ ( negedge BUSYWAIT ) begin
    READ = 1'b0;
    WRITE = 1'b0;
end


endmodule
// *****************************************************************************************************



// ********************************** MODULE FOR DECORDER **********************************************
module decorder (INSTRUCTION, READREG1, READREG2, WRITEREG, IMMEDIATE, OFFSET);


// Input output port declaration -----------
input [31:0] INSTRUCTION;                                    
output [2:0] READREG1, READREG2, WRITEREG;
output [7:0] IMMEDIATE;
output [7:0] OFFSET;   
// -----------------------------------------


assign READREG1  = INSTRUCTION[15:8];
assign READREG2  = INSTRUCTION[7:0];
assign IMMEDIATE = INSTRUCTION[7:0];
assign WRITEREG  = INSTRUCTION[23:16];
assign OFFSET    = INSTRUCTION[23:16];


endmodule
// ******************************************************************************************************



// ********************************** MODULE FOR THE PC  COUNTER UNIT ***********************************
module PC_counter ( PC_next, PC, SEL_offset, ZERO, BYTE_OFFSET);


    // Input output port declaration-----
    input [31:0] PC;
    input [1:0] SEL_offset;
    input ZERO;
    input [31:0] BYTE_OFFSET;
    output reg [31:0] PC_next;
    // ----------------------------------


    // Dedicated adder to increment PC by 4
    wire [31:0] pcAdder;
    assign #1 pcAdder = PC+4;

    // Branch or jump target adder
    wire [31:0] targetAdder;
    assign #2 targetAdder = pcAdder + BYTE_OFFSET;


    // mux ------------------------
    reg SEL_pc;
    always @ ( SEL_offset, ZERO)
    begin
        case ( SEL_offset )
        2'b00 :
            SEL_pc = 1'b0;
        2'b01 :
            SEL_pc = 1'b1;
        2'b10 :
            SEL_pc = ZERO;
        2'b11 :
            SEL_pc = ~ZERO;
        endcase
    end
    // ----------------------------

    // mux ------------------------
    always @ ( pcAdder, targetAdder, SEL_pc)
    begin
        case ( SEL_pc )
        1'b1 :
            PC_next = targetAdder;
        1'b0 :
            PC_next = pcAdder;
        endcase
    end
    // -----------------------------


endmodule
// ******************************************************************************************************



// ********************************** MODULE FOR THE PC UNIT ******************************************** 
module pc ( PC, CLK, RESET, BUSYWAIT, INSTR_CACHE_BUSYWAIT, PC_next);

    // Input output port declaration---
    input CLK, RESET;
    input [31:0] PC_next;
    output reg [31:0] PC;
    input BUSYWAIT;
    input INSTR_CACHE_BUSYWAIT;
    // --------------------------------


    // pc is synchronized to rising edge of the clock
    always @ ( posedge CLK ) begin   
        if (RESET) begin
            #1 PC = 0;       
        end 
        else if (~BUSYWAIT && ~INSTR_CACHE_BUSYWAIT) begin   
            #1 PC = PC_next; 
        end
    end


endmodule
// ******************************************************************************************************



// ******************* MODULE FOR THE 2X1 MUX ************************
module mux_2x1 (OUT, IN1, IN0, SEL);

    // Input output port declaration---
    output reg [7:0] OUT;
    input [7:0] IN1, IN0;
    input SEL;
    // --------------------------------

    always @ (IN1, IN0, SEL) 
    begin
        case (SEL)
        1'b1 :
            OUT = IN1;
        1'b0 :
            OUT = IN0;
        endcase
    end


endmodule
// *******************************************************************



// **************** MODULE TO GET THE 2S COMPLEMENT ******************
module comp_2s (OUT, IN);

    
    // Input output port declaration----
    input [7:0] IN;
    output [7:0] OUT;
    // ---------------------------------

    assign #1 OUT = ~IN + 1;


endmodule
// *******************************************************************