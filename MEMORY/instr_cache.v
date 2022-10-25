`timescale 1ns/100ps
/*
Module	: 8x128-bit instruction cache memory (16-Byte blocks)
*/


module instr_cache (busywait, instruction, pc, clock, reset,
                    instrmem_busywait, instrmem_readdata, instrmem_read,  instrmem_address);


    // Input output port declaration ---
    output reg busywait;
    output reg [31:0] instruction;
    input [31:0] pc;
    input clock, reset;
    input instrmem_busywait;
    input [127:0] instrmem_readdata;
    output reg instrmem_read;
    output reg [5:0] instrmem_address;
    // ---------------------------------

    
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */


    // Splitting pc address into tag, index and offset
    wire [2:0] tag, index;
    wire [1:0] offset;
    assign tag = pc[9:7];
    assign index = pc[6:4];
    assign offset = pc[3:2];


    // Tag comparison and validation combinational logic
    wire hit;
    assign #0.9 hit =  (valid && (tag==cache_tag)) ? 1 : 0; 


    /*
    CACHE STORAGE
    */
    reg [127:0] CACHE_STORAGE[7:0];                // 8 blocks.  1 block=>16 bytes
    reg [3:0] CACHE_TAG_VALID[7:0];                // To store tags, valid bits corresponding to each block


    // Extracting instruction block and valid bit based on index, combinational logic
    wire [127:0] instr_block;
    wire [2:0] cache_tag;
    wire valid;

    assign #1 valid            = CACHE_TAG_VALID[index][0];
    assign #1 cache_tag        = CACHE_TAG_VALID[index][2:1];
    assign #1 instr_block      = CACHE_STORAGE[index];
  

    // Selecting the requested instruction word from the block using a mux
    reg [31:0] instr_word;
    always @ (offset, instr_block) begin

        #1 case (offset)
            2'b00:
                instr_word = instr_block[31:0];
            2'b01:
                instr_word = instr_block[63:32];
            2'b10:
                instr_word = instr_block[95:64];
            2'b11:
                instr_word = instr_block[127:96];
        endcase

    end


    /*
    HIT STATUS
    */

    // READ HIT => send instr_word to cpu asynchronuously 
    always @ (*) begin
        if (hit)
            instruction = instr_word;
    end

    
    // Writing instruction block to cache at posedge of clock
    reg cache_block_write;
    always @ (posedge clock) begin
        if (cache_block_write) 
            #1 {CACHE_STORAGE[index], CACHE_TAG_VALID[index][3:1], CACHE_TAG_VALID[index][0], cache_block_write}
            =  {instrmem_readdata, tag, 1'b1, 1'b0};
        
    end


    /* Cache Controller FSM Start */

    parameter IDLE = 1'b0, INSTR_MEM_READ = 1'b1;
    reg state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (!hit) 
                    next_state = INSTR_MEM_READ;    
                else 
                    next_state = IDLE;
            
            INSTR_MEM_READ:
                if (!instrmem_busywait) begin
                    next_state = IDLE;
                    cache_block_write = 1;  
                end else
                    next_state = INSTR_MEM_READ;   

        endcase
    end

    // combinational output logic
    always @ (*)
    begin
        case(state)
            IDLE:
            begin
                instrmem_read = (!hit) ? 1 : 0;
                instrmem_address = {tag, index};
                busywait = (!hit) ? 1 : 0;       // enable busywait if miss detected  
            end
         
            INSTR_MEM_READ: 
            begin
                instrmem_read = 1;
                instrmem_address = {tag, index};
                busywait = 1;
                cache_block_write = 0;
            end
            
        endcase
    end

    // sequential logic for state transitioning 
    integer i;
    always @(posedge clock, reset)
    begin
        if(reset) begin
            state = IDLE;
            #1 for (i =0; i<8; ++i) begin
                CACHE_STORAGE[i] = 128'bx;
                CACHE_TAG_VALID[i] = 4'bxxx_0;
            end
        end else
            state = next_state;
    end

    /* Cache Controller FSM End */


endmodule