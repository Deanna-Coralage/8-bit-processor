
/*                                          ALU FUNCTIONAL UNITS MODULES                                    */



// ********************** FORWARD FUNCTIONAL UNIT *************************
module FORWARD_8bit (IN, OUT);

    // Input output port declaration
    input [7:0] IN;
    output [7:0] OUT;
                  
    assign #1  OUT = IN;           // delay 1 simulation time unit    

endmodule
// ************************************************************************



// ************************ ADDER FUNCTIONAL UNIT *************************
module ADDER_8bit (IN1, IN2, OUT);    

    // Input output port declaration
    input [7:0] IN1, IN2;
    output [7:0] OUT;

    assign #2 OUT = IN1 + IN2;            // delay 2 simulation time units

endmodule
// ************************************************************************



// *************************** AND FUNCTIONAL UNIT ************************
module AND_8bit (IN1, IN2, OUT);

    // Input output port declaration 
    input [7:0] IN1, IN2;
    output [7:0] OUT;

    assign #1 OUT = IN1 & IN2;        // delay 1 simulation time unit

endmodule
// ************************************************************************



// ************************* OR FUNCTIONAL UNIT ***************************
module OR_8bit (IN1, IN2, OUT);

    // Input output port declaration 
    input [7:0] IN1, IN2;
    output [7:0] OUT;
       
    assign #1 OUT = IN1 | IN2;        // delay 1 simulation time unit

endmodule
// ************************************************************************



// ************************* MULT FUNCTIONAL UNIT *************************
module MULTIPLIER_8bit (IN1, IN2, OUT);    

    // Input output port declaration
    input [7:0] IN1, IN2;
    output [7:0] OUT;

    // Temp wires
    wire [7:0] w0, w1, w2, w3, w4, w5, w6, w7;

    and8x1 m0 (w0,              IN1, IN2[0]);
    and8x1 m1 (w1, {IN1[6:0], 1'b0}, IN2[1]);
    and8x1 m2 (w2, {IN1[5:0], 2'b0}, IN2[2]);
    and8x1 m3 (w3, {IN1[4:0], 3'b0}, IN2[3]);
    and8x1 m4 (w4, {IN1[3:0], 4'b0}, IN2[4]);
    and8x1 m5 (w5, {IN1[2:0], 5'b0}, IN2[5]);
    and8x1 m6 (w6, {IN1[1:0], 6'b0}, IN2[6]);
    and8x1 m7 (w7, {IN1[0]  , 7'b0}, IN2[7]);

    assign #3 OUT = w0 + w1 + w2 + w3 + w4 + w5 + w6 + w7;    

endmodule
// ************************************************************************



// ************************ LEFT SHIFT FUNCTIONAL UNIT ********************
module SHIFT_LEFT_8bit (IN, SHIFT, OUT);

  // Input output port declaration
  input [7:0] IN, SHIFT;
  output [7:0] OUT;
  
  // Internal wires
  wire [7:0] out1, out2, out3, out4;

  /* SIGN BIT CONVENTION -----------------
    SHIFT[7:6]=00 => logical left shift
    SHIFT[7:6]=01 => arithmetic left shift
    SHIFT[7:6]=10 => rotate right
  */

  // SHIFT[0] => (0,1)
  wire lsb0;
  muxLSB lsb0_mux(lsb0, IN[7], IN[0], 1'b0, SHIFT[7:6]);
  mux m1_0 (out1[0],  lsb0, IN[0], SHIFT[0]);
  mux m1_1 (out1[1], IN[0], IN[1], SHIFT[0]);
  mux m1_2 (out1[2], IN[1], IN[2], SHIFT[0]);
  mux m1_3 (out1[3], IN[2], IN[3], SHIFT[0]);
  mux m1_4 (out1[4], IN[3], IN[4], SHIFT[0]);
  mux m1_5 (out1[5], IN[4], IN[5], SHIFT[0]);
  mux m1_6 (out1[6], IN[5], IN[6], SHIFT[0]);
  mux m1_7 (out1[7], IN[6], IN[7], SHIFT[0]);

  // SHIFT[1] => (2,3)
  wire lsb1_0, lsb1_1;
  muxLSB lsb1_0_mux(lsb1_0, out1[6], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb1_1_mux(lsb1_1, out1[7], IN[0], 1'b0, SHIFT[7:6]);
  mux m2_0 (out2[0],  lsb1_0, out1[0], SHIFT[1]);
  mux m2_1 (out2[1],  lsb1_1, out1[1], SHIFT[1]);
  mux m2_2 (out2[2], out1[0], out1[2], SHIFT[1]);
  mux m2_3 (out2[3], out1[1], out1[3], SHIFT[1]);
  mux m2_4 (out2[4], out1[2], out1[4], SHIFT[1]);
  mux m2_5 (out2[5], out1[3], out1[5], SHIFT[1]);
  mux m2_6 (out2[6], out1[4], out1[6], SHIFT[1]);
  mux m2_7 (out2[7], out1[5], out1[7], SHIFT[1]);

  // SHIFT[2] => (4,5,6,7)
  wire lsb2_3, lsb2_2, lsb2_1, lsb2_0;
  muxLSB lsb2_0_mux(lsb2_0, out2[4], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb2_1_mux(lsb2_1, out2[5], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb2_2_mux(lsb2_2, out2[6], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb2_3_mux(lsb2_3, out2[7], IN[0], 1'b0, SHIFT[7:6]);
  mux m3_0 (out3[0],  lsb2_0, out2[0], SHIFT[2]);
  mux m3_1 (out3[1],  lsb2_1, out2[1], SHIFT[2]);
  mux m3_2 (out3[2],  lsb2_2, out2[2], SHIFT[2]);
  mux m3_3 (out3[3],  lsb2_3, out2[3], SHIFT[2]);
  mux m3_4 (out3[4], out2[0], out2[4], SHIFT[2]);
  mux m3_5 (out3[5], out2[1], out2[5], SHIFT[2]);
  mux m3_6 (out3[6], out2[2], out2[6], SHIFT[2]);
  mux m3_7 (out3[7], out2[3], out2[7], SHIFT[2]);

  // SHIFT[3] => (8)
  wire lsb3_7, lsb3_6, lsb3_5, lsb3_4, lsb3_3, lsb3_2, lsb3_1, lsb3_0;
  muxLSB lsb3_0_mux(lsb3_0, out3[0], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb3_1_mux(lsb3_1, out3[1], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb3_2_mux(lsb3_2, out3[2], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb3_3_mux(lsb3_3, out3[3], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb3_4_mux(lsb3_4, out3[4], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb3_5_mux(lsb3_5, out3[5], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb3_6_mux(lsb3_6, out3[6], IN[0], 1'b0, SHIFT[7:6]);
  muxLSB lsb3_7_mux(lsb3_7, out3[7], IN[0], 1'b0, SHIFT[7:6]);
  mux m4_0 (out4[0], lsb3_0, out3[0], SHIFT[3]);
  mux m4_1 (out4[1], lsb3_1, out3[1], SHIFT[3]);
  mux m4_2 (out4[2], lsb3_2, out3[2], SHIFT[3]);
  mux m4_3 (out4[3], lsb3_3, out3[3], SHIFT[3]);
  mux m4_4 (out4[4], lsb3_4, out3[4], SHIFT[3]);
  mux m4_5 (out4[5], lsb3_5, out3[5], SHIFT[3]);
  mux m4_6 (out4[6], lsb3_6, out3[6], SHIFT[3]);
  mux m4_7 (out4[7], lsb3_7, out3[7], SHIFT[3]);

  assign #3 OUT = out4;


endmodule
// ************************************************************************



// *********************** RIGHT SHIFT FUNCTINAL UNIT *********************
module SHIFT_RIGHT_8bit (IN, SHIFT, OUT);

  // Input output port declaration
  input [7:0] IN, SHIFT;
  output [7:0] OUT;

  /* SIGN BIT CONVENTION ---------------
    SHIFT[7]=0 => logical right shift
    SHIFT[7]=1 => arithmetic right shift
  */

  // Internal wires
  wire [7:0] out1, out2, out3, out4;

  // MSB
  wire msb;
  mux msb_mux(msb, IN[7], 1'b0, SHIFT[7]);

  // SHIFT[0] => (0,1)
  mux m1_0 (out1[0], IN[1], IN[0], SHIFT[0]);
  mux m1_1 (out1[1], IN[2], IN[1], SHIFT[0]);
  mux m1_2 (out1[2], IN[3], IN[2], SHIFT[0]);
  mux m1_3 (out1[3], IN[4], IN[3], SHIFT[0]);
  mux m1_4 (out1[4], IN[5], IN[4], SHIFT[0]);
  mux m1_5 (out1[5], IN[6], IN[5], SHIFT[0]);
  mux m1_6 (out1[6], IN[7], IN[6], SHIFT[0]);
  mux m1_7 (out1[7],   msb, IN[7], SHIFT[0]);

  // SHIFT[1] => (2,3)
  mux m2_0 (out2[0], out1[2], out1[0], SHIFT[1]);
  mux m2_1 (out2[1], out1[3], out1[1], SHIFT[1]);
  mux m2_2 (out2[2], out1[4], out1[2], SHIFT[1]);
  mux m2_3 (out2[3], out1[5], out1[3], SHIFT[1]);
  mux m2_4 (out2[4], out1[6], out1[4], SHIFT[1]);
  mux m2_5 (out2[5], out1[7], out1[5], SHIFT[1]);
  mux m2_6 (out2[6],     msb, out1[6], SHIFT[1]);
  mux m2_7 (out2[7],     msb, out1[7], SHIFT[1]);

  // SHIFT[2] => (4,5,6,7)
  mux m3_0 (out3[0], out2[4], out2[0], SHIFT[2]);
  mux m3_1 (out3[1], out2[5], out2[1], SHIFT[2]);
  mux m3_2 (out3[2], out2[6], out2[2], SHIFT[2]);
  mux m3_3 (out3[3], out2[7], out2[3], SHIFT[2]);
  mux m3_4 (out3[4],     msb, out2[4], SHIFT[2]);
  mux m3_5 (out3[5],     msb, out2[5], SHIFT[2]);
  mux m3_6 (out3[6],     msb, out2[6], SHIFT[2]);
  mux m3_7 (out3[7],     msb, out2[7], SHIFT[2]);

  // SHIFT[3] => (8)
  mux m4_0 (out4[0], msb, out3[0], SHIFT[3]);
  mux m4_1 (out4[1], msb, out3[1], SHIFT[3]);
  mux m4_2 (out4[2], msb, out3[2], SHIFT[3]);
  mux m4_3 (out4[3], msb, out3[3], SHIFT[3]);
  mux m4_4 (out4[4], msb, out3[4], SHIFT[3]);
  mux m4_5 (out4[5], msb, out3[5], SHIFT[3]);
  mux m4_6 (out4[6], msb, out3[6], SHIFT[3]);
  mux m4_7 (out4[7], msb, out3[7], SHIFT[3]);

  assign #3 OUT = out4;


endmodule
// ************************************************************************




// *************************** mux ****************************************
module mux (OUT, IN1, IN0, SEL);

  // Input output port declaration
  input IN1, IN0;
  input SEL;
  output reg OUT;

  always @ (IN1, IN0, SEL) 
  begin

    case (SEL)
      1'b0:
        OUT = IN0;
      1'b1:
        OUT = IN1;
    endcase

  end

endmodule
// ************************************************************************


// *************************** muxLSB *************************************
module muxLSB (OUT, IN2, IN1, IN0, SEL);

  // Input output port declaration
  input IN2, IN1, IN0;
  input [1:0] SEL;
  output  reg OUT;

  always @ (IN2, IN1, IN0, SEL) 
  begin

    case (SEL)
      2'b00:
        OUT = IN0;
      2'b01:
        OUT = IN1;
      2'b10:
        OUT = IN2;
    endcase

  end

endmodule
// ************************************************************************


// ******************************* and8x1 *********************************
module and8x1 (OUT, IN, BIT);

  // Input output port declaration
  input [7:0] IN;
  input BIT;
  output [7:0] OUT;

  and and0(OUT[0], IN[0], BIT);
  and and1(OUT[1], IN[1], BIT);
  and and2(OUT[2], IN[2], BIT);
  and and3(OUT[3], IN[3], BIT);
  and and4(OUT[4], IN[4], BIT);
  and and5(OUT[5], IN[5], BIT);
  and and6(OUT[6], IN[6], BIT);
  and and7(OUT[7], IN[7], BIT);

endmodule
// ************************************************************************