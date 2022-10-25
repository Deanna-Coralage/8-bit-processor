/*                              MODULE FOR THE REGISTER FILE                        */



module reg_file (IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);


    // Input output port declaration ------------------------------------------------------------
    input [7:0] IN;                                         // 8-bit wire
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;        // ADDRESS ports are all 3-bit buses
    input WRITE, RESET, CLK;                                // single bit wires
    output [7:0] OUT1, OUT2;                                // 8-bit wires 
    // ------------------------------------------------------------------------------------------


    // Declaring 8 8-bit registers
    reg [7:0] REGISTER[7:0];


    // Reading values from registers is done asynchonously
    assign #2 OUT1 = REGISTER[OUT1ADDRESS];
    assign #2 OUT2 = REGISTER[OUT2ADDRESS];

    integer i;

    // Both writing to register and resetting are done synchronously  at the rising edge of the clock
    // Delay 1 simulation time unit
    always @ (posedge CLK)
    begin

        if ( RESET==1) begin                        // If reset is high all the registers are cleared
            #1 for (i=0; i<8; i=i+1) begin    
                REGISTER[i] = 0;                    
            end
        end
        else if ( WRITE==1 )begin                  // else if write is high input data is written to register
            #1 REGISTER[INADDRESS] = IN;         
        end

    end



    // For testing ----------------------------------------------------------------------------------------------------------------------------------------------------
    initial
    begin
        // monitor change in reg file content and print 
        #5;
        $display("\n\t\t\t=================================================");
        $display("\t\t\t Change of Register Content starting from Time #5");
        $display("\t\t\t=================================================\n");
        $display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
        $display("\t\t--------------------------------------------------------------------");
        $monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",REGISTER[0], REGISTER[1], REGISTER[2], REGISTER[3], REGISTER[4], REGISTER[5], REGISTER[6], REGISTER[7]);
    end
    // ----------------------------------------------------------------------------------------------------------------------------------------------------------------


endmodule