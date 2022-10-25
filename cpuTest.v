`timescale 1ns/100ps

// Design: Testbench of Integrated CPU of Simple Processor

`include "cpu.v"
`include "MEMORY/data_mem.v" 
`include "MEMORY/dcache.v"
`include "MEMORY/instruction_mem.v"
`include "MEMORY/instr_cache.v"

module cpu_tb;

    // cpu connections
    reg CLK, RESET;

    // cache connections
    wire READ, WRITE;
    wire [7:0] READDATA; 
    wire BUSYWAIT;   
    wire [7:0] ADDRESS;
    wire [7:0] WRITEDATA; 
    
    // memory connections
    wire MEM_BUSYWAIT;
    wire [31:0] MEM_READDATA,MEM_WRITEDATA;
    wire MEM_READ,MEM_WRITE;
    wire [5:0] MEM_ADDRESS;

    // instruction cache connections
    wire INSTR_CACHE_BUSYWAIT;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;

    // instruction memory connections
    wire INSTRMEM_BUSYWAIT;
    wire [127:0] INSTRMEM_READDATA;
    wire INSTRMEM_READ;
    wire [5:0] INSTRMEM_ADDRESS;


    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET, BUSYWAIT, INSTR_CACHE_BUSYWAIT, READ, WRITE, ADDRESS, WRITEDATA, READDATA);

    /*
    -----
    DATA MEMORY
    -----
    */
    data_memory mydatamem (CLK, RESET, MEM_READ, MEM_WRITE, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT);

    /*
    -----
    DATA CACHE
    -----
    */
    dcache mydatacache (BUSYWAIT, READDATA, READ, WRITE, WRITEDATA, ADDRESS, CLK, RESET,
                        MEM_BUSYWAIT, MEM_READDATA, MEM_READ, MEM_WRITE, MEM_WRITEDATA, MEM_ADDRESS);

    /*
    -----
    INSTUCTION CACHE
    -----
    */
    instr_cache myinstructioncache (INSTR_CACHE_BUSYWAIT, INSTRUCTION, PC, CLK, RESET,
                                    INSTRMEM_BUSYWAIT, INSTRMEM_READDATA, INSTRMEM_READ,  INSTRMEM_ADDRESS);

    /*
    -----
    INSTRUCTON MEMORY
    -----
    */
    instruction_memory myinstructionmem (CLK, INSTRMEM_READ, INSTRMEM_ADDRESS, INSTRMEM_READDATA, INSTRMEM_BUSYWAIT);


    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #1 RESET = 1'b1;
        #4 RESET = 1'b0;
        
        // finish simulation after some time
        #1500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule