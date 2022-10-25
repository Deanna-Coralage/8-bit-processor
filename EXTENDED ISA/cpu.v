/*                                              MODULE FOR THE CPU                                 */


// Including verilog files of sub modules
`include "submodules_cpu.v"
`include "ALU/alu.v"
`include "REGISTER/register.v"


module cpu (PC, INSTRUCTION, CLK, RESET);


    // Input output port declaration ----
    input [31:0] INSTRUCTION; 
    input CLK, RESET;
    output [31:0] PC;
    // ----------------------------------

    
    // Wires to connect internal modules
    wire [7:0] OPCODE;
    wire [2:0] READREG1, READREG2, WRITEREG;
    wire [7:0] IMMEDIATE;
    wire [7:0] OFFSET;
    wire [31:0] BYTE_OFFSET;
    wire [31:0] PC_next;
    wire [2:0] ALUOP;
    wire WRITEENABLE, SEL_2scomp, SEL_immediate, SEL_shift;
    wire [1:0] SHIFT_sign;
    wire [1:0] SEL_offset;
    wire ZERO;
    wire [7:0] REGOUT1, REGOUT2;
    wire [7:0] RESULT;
    wire [7:0] OUT_2scomp, OUT_2scomp_mux, OUT_immediate_mux;
    wire [7:0] DATA2;
    wire [7:0] SHIFT;

    // Converting the 8 bit offset to a 32 bit adder value
    assign BYTE_OFFSET = { {22{OFFSET[7]}}, OFFSET[7:0], 2'b00};

    // Adding a sign bit for logical right operation
    // For shifts>8 we take a maximum shift of 8 bits
    wire bit3;
    or or1 (bit3, IMMEDIATE[3], IMMEDIATE[4], IMMEDIATE[5], IMMEDIATE[6], IMMEDIATE[7]);
    wire bit2, bit1, bit0;
    and and1 (bit2, ~bit3, IMMEDIATE[2]);
    and and2 (bit1, ~bit3, IMMEDIATE[1]);
    and and3 (bit0, ~bit3, IMMEDIATE[0]);

    assign SHIFT = {SHIFT_sign, 2'b00, bit3, bit2, bit1, bit0};


    // Instantiation of modules
    decorder DECORDER_UNIT (INSTRUCTION, OPCODE, READREG1, READREG2, WRITEREG, IMMEDIATE, OFFSET);
    PC_counter PC_COUNTER_UNIT ( PC_next, PC, SEL_offset, ZERO, BYTE_OFFSET);
    pc PC_UNIT ( PC, CLK, RESET, PC_next);                        
    control_unit CONTROL_UNIT (OPCODE, ALUOP, SEL_offset, SEL_2scomp, SEL_immediate, SEL_shift, SHIFT_sign, WRITEENABLE);

    reg_file REGFILE_UNIT (RESULT, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    comp_2s comp2s_UNIT (OUT_2scomp, REGOUT2);
    mux_2x1 MUX_2Scomp (OUT_2scomp_mux, OUT_2scomp, REGOUT2, SEL_2scomp);
    mux_2x1 MUX_Immediate (OUT_immediate_mux, IMMEDIATE, OUT_2scomp_mux, SEL_immediate);
    mux_2x1 MUX_Shift (DATA2, SHIFT, OUT_immediate_mux, SEL_shift);
    alu ALU_UNIT (REGOUT1, DATA2, RESULT, ZERO, ALUOP);


endmodule