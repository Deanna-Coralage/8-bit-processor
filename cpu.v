`timescale 1ns/100ps

/*                                              MODULE FOR THE CPU                                 */


// Including verilog files of sub modules
`include "submodules_cpu.v"
`include "ALU/alu.v"
`include "REGISTER/register.v"


module cpu (PC, INSTRUCTION, CLK, RESET, BUSYWAIT, INSTR_CACHE_BUSYWAIT, READ, WRITE, ADDRESS, WRITEDATA, READDATA);


    // Input output port declaration ----
    input [31:0] INSTRUCTION; 
    input CLK, RESET;
    input BUSYWAIT;
    input INSTR_CACHE_BUSYWAIT;
    output [31:0] PC;
    output READ, WRITE;
    output [7:0] ADDRESS, WRITEDATA;
    input [7:0] READDATA;
    // ----------------------------------

    
    // Wires to connect internal modules
    wire [2:0] READREG1, READREG2, WRITEREG;
    wire [7:0] IMMEDIATE;
    wire [7:0] OFFSET;
    wire [31:0] BYTE_OFFSET;
    wire [31:0] PC_next;
    wire [2:0] ALUOP;
    wire WRITEENABLE, SEL_2scomp, SEL_immediate, SEL_regwritedata;
    wire [1:0] SEL_offset;
    wire ZERO;
    wire [7:0] REGOUT1, REGOUT2;
    wire [7:0] RESULT;
    wire [7:0] OUT_2scomp, OUT_2scomp_mux;
    wire [7:0] DATA2;

    wire [7:0] OUT_regwritedata;   

    // Converting the 8 bit offset to a 32 bit adder value
    assign BYTE_OFFSET = { {22{OFFSET[7]}}, OFFSET[7:0], 2'b00};

    // Data memory
    assign WRITEDATA = REGOUT1;
    assign ADDRESS = RESULT;


    // Instantiation of modules
    decorder DECORDER_UNIT (INSTRUCTION, READREG1, READREG2, WRITEREG, IMMEDIATE, OFFSET);
    PC_counter PC_COUNTER_UNIT ( PC_next, PC, SEL_offset, ZERO, BYTE_OFFSET);
    pc PC_UNIT ( PC, CLK, RESET,BUSYWAIT, INSTR_CACHE_BUSYWAIT, PC_next);                        
    control_unit CONTROL_UNIT (BUSYWAIT, INSTRUCTION, ALUOP, SEL_offset, SEL_2scomp, SEL_immediate, SEL_regwritedata, WRITEENABLE, READ, WRITE);
    mux_2x1 MUX_RegWritedata (OUT_regwritedata, READDATA, RESULT, SEL_regwritedata);
    reg_file REGFILE_UNIT (OUT_regwritedata, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET, BUSYWAIT);
    comp_2s comp2s_UNIT (OUT_2scomp, REGOUT2);
    mux_2x1 MUX_2Scomp (OUT_2scomp_mux, OUT_2scomp, REGOUT2, SEL_2scomp);
    mux_2x1 MUX_Immediate (DATA2, IMMEDIATE, OUT_2scomp_mux, SEL_immediate);
    alu ALU_UNIT (REGOUT1, DATA2, RESULT, ZERO, ALUOP);


endmodule