`timescale 1ns/100ps
/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

module dcache (busywait, readdata, read, write, writedata, address, clock, reset,
               mem_busywait, mem_readdata, mem_read, mem_write, mem_writedata, mem_address);


    // Input output port declaration ---
    output reg busywait;
    output reg [7:0] readdata;
    input read, write;
    input [7:0] writedata, address;
    input clock, reset;
    input mem_busywait;
    input [31:0] mem_readdata;
    output reg mem_read, mem_write;
    output reg [31:0] mem_writedata;
    output reg [5:0] mem_address;
    // ---------------------------------

    
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */


    // Detecting read and write access to cache
    reg read_access, write_access;
    always @ (read, write, writedata, address) begin
        if (read || write) begin
            read_access = (read && !write)? 1 : 0;
            write_access = (!read && write)? 1 : 0;
        end
    end
    

    // Splitting address into tag, index and offset
    wire [2:0] tag, index;
    wire [1:0] offset;
    assign tag = address[7:5];
    assign index = address[4:2];
    assign offset = address[1:0];


    // Tag comparison and validation combinational logic
    reg hit;
    always @ (*) begin
        #0.9 if (valid && (tag==cache_tag) )
            hit = 1;
        else
            hit = 0;
    end 


    /*
    CACHE STORAGE
    */
    reg [31:0] CACHE_STORAGE[7:0];                // 8 blocks.  1 block=>4 bytes
    reg [4:0] CACHE_TAG_DIRTY_VALID[7:0];         // To store tags, dirty, valid bits corresponding to each blocks


    // Extracting data block, dirty and valid bits based on index, combinational logic
    wire [31:0] data_block;
    wire [2:0] cache_tag;
    wire dirty, valid;

    assign #1 valid      = CACHE_TAG_DIRTY_VALID[index][0];
    assign #1 dirty      = CACHE_TAG_DIRTY_VALID[index][1];
    assign #1 cache_tag  = CACHE_TAG_DIRTY_VALID[index][4:2];
    assign #1 data_block = CACHE_STORAGE[index];
  

    // Selecting the requested data word from the block using a mux
    reg [7:0] data_word;
    always @ (offset, data_block) begin

        #1 case (offset)
            2'b00:
                data_word = data_block[7:0];
            2'b01:
                data_word = data_block[15:8];
            2'b10:
                data_word = data_block[23:16];
            2'b11:
                data_word = data_block[31:24];
        endcase

    end


    /*
    HIT STATUS
    */

    // READ HIT => send data_word to cpu 
    always @ (posedge clock) begin
        if (read_access && hit) begin
            readdata = data_word;  
            read_access = 0;            // reading from cache completed 
        end
    end

    // WRITE HIT => write to cache at clk edge using a demux
    //reg write_success;
    always @ (posedge clock) begin
        if (write_access && hit) begin          
           
            // Demux to store data to cache
            #1 case (offset)
                2'b00:
                    CACHE_STORAGE[index][7:0]   = writedata;
                2'b01:
                    CACHE_STORAGE[index][15:8]  = writedata;
                2'b10:
                    CACHE_STORAGE[index][23:16] = writedata;
                2'b11:
                    CACHE_STORAGE[index][31:24] = writedata;
            endcase

            CACHE_TAG_DIRTY_VALID[index][1] = 1'b1;     // block is dirty after write to cache
            write_access = 0;                           // write to cache is completed
        end
        
    end

    
    // Writing data block to cache at posedge of clock
    reg cache_block_write;
    always @ (posedge clock) begin
        if (cache_block_write) 
            #1 {CACHE_STORAGE[index], CACHE_TAG_DIRTY_VALID[index][4:2], CACHE_TAG_DIRTY_VALID[index][0], cache_block_write}
            =  {mem_readdata, tag, 1'b1, 1'b0};
        
    end

    // De assert dirty bit after memory write
    reg update_dirty;
    always @ (posedge clock) begin
        if (update_dirty)
            #1 {CACHE_TAG_DIRTY_VALID[index][1], update_dirty} = 2'b00;
    end


    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read|| write) && !dirty && !hit) 
                    next_state = MEM_READ;
                else if ((read|| write) && dirty && !hit) 
                    next_state = MEM_WRITE;   
                else 
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait) begin
                    next_state = IDLE;
                    cache_block_write = 1;  
                end else
                    next_state = MEM_READ;   

            MEM_WRITE:
                if (!mem_busywait) begin
                    next_state = MEM_READ;
                    update_dirty = 1;
                end else
                    next_state = MEM_WRITE;

        endcase
    end

    // combinational output logic
    always @ (*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'bx;
                mem_writedata = 32'bx;
                busywait = ((read || write) && !hit) ? 1 : 0;       // enable busywait if miss detected  
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'bx;
                busywait = 1;
                cache_block_write = 0;
            end

            MEM_WRITE:
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tag, index};
                mem_writedata = data_block;
                busywait = 1;
                cache_block_write = 0;
                update_dirty = 0;
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
                CACHE_STORAGE[i] = 32'bx;
                CACHE_TAG_DIRTY_VALID[i] = 5'bxxx_0_0;
            end
        end else
            state = next_state;
    end

    /* Cache Controller FSM End */


endmodule


