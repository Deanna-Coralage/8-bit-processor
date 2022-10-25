// Design: Testbench of Integrated CPU of Simple Processor

`include "cpu.v" 

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
    reg [7:0] instr_mem [1023:0];
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    assign #2 INSTRUCTION[7:0]   = instr_mem[PC];
    assign #2 INSTRUCTION[15:8]  = instr_mem[PC+1];
    assign #2 INSTRUCTION[23:16] = instr_mem[PC+2];
    assign #2 INSTRUCTION[31:24] = instr_mem[PC+3];
    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        /* Assembly code ------------------------
        loadi 0 0xA5 => 1010_0101 => 165
        loadi 1 0x04
        loadi 2 0x03
        sll 3 0 0x04 => 0101_0000 => 80
        sla 4 0 0x02 => 1001_0111 => 151
        srl 5 0 0x03 => 0001_0100 => 20
        sra 6 0 0x01 => 1101_0010 => 210
        ror 7 0 0x05 => 1011_0100 => 180
        mult 1 1 2
        bne 0xFE 1 5
        sla 1 0 0xFF
        ror 7 0 0x09
        ---------------------------------------*/

        /* METHOD 1: manually loading instructions to instr_mem
        {instr_mem[10'd0], instr_mem[10'd1], instr_mem[10'd2], instr_mem[10'd3]}     = 32'b00001000_00000000_00000100_00000000;
        {instr_mem[10'd4], instr_mem[10'd5], instr_mem[10'd6], instr_mem[10'd7]}     = 32'b00000100_00000000_00000010_00000000;
        {instr_mem[10'd8], instr_mem[10'd9], instr_mem[10'd10], instr_mem[10'd11]}   = 32'b00000001_00000000_00000011_00000000;
        {instr_mem[10'd12], instr_mem[10'd13], instr_mem[10'd14], instr_mem[10'd15]} = 32'b00000010_00000011_00000010_00000010;
        {instr_mem[10'd16], instr_mem[10'd17], instr_mem[10'd18], instr_mem[10'd19]} = 32'b00000010_00000100_11111110_00001101;
        {instr_mem[10'd20], instr_mem[10'd21], instr_mem[10'd22], instr_mem[10'd23]} = 32'b00000001_00000000_00000001_00000000;
        {instr_mem[10'd24], instr_mem[10'd25], instr_mem[10'd26], instr_mem[10'd27]} = 32'b00000001_00000010_00000010_00000010;
        {instr_mem[10'd28], instr_mem[10'd29], instr_mem[10'd30], instr_mem[10'd31]} = 32'b00000010_00000000_00000111_00000011;
        {instr_mem[10'd32], instr_mem[10'd33], instr_mem[10'd34], instr_mem[10'd35]} = 32'b00000111_00000000_00000000_00000001;
        */

        // METHOD 2: loading instr_mem content from instr_mem.mem file
        $readmemb("instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

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
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule