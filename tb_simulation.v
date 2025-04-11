
`timescale 1ns/1ps
`include "parameter.v"         //Include definition file

module tb_simulation;


parameter NUM_OF_PIXEL =8; 
//integer start_time;
//integer end_time; 


if(NUM_OF_PIXEL ==1)begin
    reg HCLK, HRESETn;
    wire vsync, hsync;
    wire [7:0] data_R0, data_G0, data_B0;
    wire ctrl_done;                         // Done flag from image_read
    wire write_done;                        // Done flag from image_write
    integer start_time;
    integer end_time; 

//inatantiate

 image_read 
    #(.INFILE(`INPUTFILENAME))
    u_image_read
    ( 
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .VSYNC(vsync),
        .HSYNC(hsync),
        .DATA_R0(data_R0), 
        .DATA_G0(data_G0),
        .DATA_B0(data_B0),
   // .data_count_out(data_count_tb),
       // .NUM_OF_PIXEL(NUM_OF_PIXEL),
        .ctrl_done(ctrl_done)
    ); 

    // Instantiate image_write module
    image_write 
    #(.INFILE(`OUTPUTFILENAME))
    u_image_write
    (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .hsync(hsync),
        //.NUM_OF_PIXEL(NUM_OF_PIXEL),
        .DATA_WRITE_R0(data_R0), 
        .DATA_WRITE_G0(data_G0),
        .DATA_WRITE_B0(data_B0),
        .Write_Done(write_done)
    );	


 // Clock Generation (20ns period, 50 MHz) 
    initial begin
        HCLK = 0;
        forever #10 HCLK = ~HCLK; // Matches your 20ns clock period
    end

    // Reset Generation
    initial begin
        HRESETn = 0;
        #25 HRESETn = 1; // Reset low for 25ns, then high
    end

    // Timing Measurement
    initial begin
        start_time = 0;
        end_time = 0;
        wait(HRESETn == 1);
        #10; // Allow system to stabilize
        start_time = $time; // Capture start time
        wait(ctrl_done == 1);
        end_time = $time; // Capture end time
        $display("Execution time: %d ns", end_time - start_time);
        // $stop; // Commented out as in your original code
    end

end

else if(NUM_OF_PIXEL ==2)begin
 
 reg HCLK, HRESETn;
    wire vsync, hsync;
    wire [7:0] data_R0, data_G0, data_B0;
    wire [7:0] data_R1, data_G1, data_B1;   // Pixel 1
    wire ctrl_done;                         // Done flag from image_read
    wire write_done;                        // Done flag from image_write
    integer start_time;
    integer end_time; 


//instantiate 
 image_read 
#(.INFILE(`INPUTFILENAME))
	u_image_read
( 
    .HCLK	                (HCLK),
    .HRESETn	            (HRESETn),
    .VSYNC	                (vsync),
    .HSYNC	                (hsync),
// .NUM_OF_PIXEL(NUM_OF_PIXEL),
    .DATA_R0	            (data_R0),
    .DATA_G0	            (data_G0),
    .DATA_B0	            (data_B0),
    .DATA_R1	            (data_R1),
    .DATA_G1	            (data_G1),
    .DATA_B1	            (data_B1),
	.ctrl_done				(ctrl_done)
); 

image_write 
#(.INFILE(`OUTPUTFILENAME))
	u_image_write
(
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.hsync(hsync),
 //.NUM_OF_PIXEL(NUM_OF_PIXEL),
   .DATA_WRITE_R0(data_R0),
   .DATA_WRITE_G0(data_G0),
   .DATA_WRITE_B0(data_B0),
   .DATA_WRITE_R1(data_R1),
   .DATA_WRITE_G1(data_G1),
   .DATA_WRITE_B1(data_B1),
	.Write_Done(write_done)
);  

 // Clock Generation (20ns period, 50 MHz) 
    initial begin
        HCLK = 0;
        forever #10 HCLK = ~HCLK; // Matches your 20ns clock period
    end

    // Reset Generation
    initial begin
        HRESETn = 0;
        #25 HRESETn = 1; // Reset low for 25ns, then high
    end

    // Timing Measurement
    initial begin
        start_time = 0;
        end_time = 0;
        wait(HRESETn == 1);
        #10; // Allow system to stabilize
        start_time = $time; // Capture start time
        wait(ctrl_done == 1);
        end_time = $time; // Capture end time
        $display("Execution time: %d ns", end_time - start_time);
        // $stop; // Commented out as in your original code
    end  

end

else if(NUM_OF_PIXEL ==4)begin
  reg HCLK, HRESETn;
    wire vsync, hsync;
    wire [7:0] data_R0, data_G0, data_B0;
    wire [7:0] data_R1, data_G1, data_B1;   // Pixel 1
    wire [7:0] data_R2, data_G2, data_B2;   // Pixel 2
    wire [7:0] data_R3, data_G3, data_B3;   // Pixel 3

    wire ctrl_done;                         // Done flag from image_read
    wire write_done;                        // Done flag from image_write
    integer start_time;
    integer end_time; 

//inatantiate 
image_read 
    #(.INFILE(`INPUTFILENAME))
    u_image_read (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .VSYNC(vsync),
        .HSYNC(hsync),
 //.NUM_OF_PIXEL(NUM_OF_PIXEL),
        .DATA_R0(data_R0),
        .DATA_G0(data_G0),
        .DATA_B0(data_B0),
        .DATA_R1(data_R1),
        .DATA_G1(data_G1),
        .DATA_B1(data_B1),
        .DATA_R2(data_R2),
        .DATA_G2(data_G2),
        .DATA_B2(data_B2),
        .DATA_R3(data_R3),
        .DATA_G3(data_G3),
        .DATA_B3(data_B3),
        .ctrl_done(ctrl_done)
    );

    //  Instantiate image_write (manual 8-pixel version)
    image_write 
    #(.INFILE(`OUTPUTFILENAME))
    u_image_write (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .hsync(hsync),
 //.NUM_OF_PIXEL(NUM_OF_PIXEL),
        .DATA_WRITE_R0(data_R0),
        .DATA_WRITE_G0(data_G0),
        .DATA_WRITE_B0(data_B0),
        .DATA_WRITE_R1(data_R1),
        .DATA_WRITE_G1(data_G1),
        .DATA_WRITE_B1(data_B1),
        .DATA_WRITE_R2(data_R2),
        .DATA_WRITE_G2(data_G2),
        .DATA_WRITE_B2(data_B2),
        .DATA_WRITE_R3(data_R3),
        .DATA_WRITE_G3(data_G3),
        .DATA_WRITE_B3(data_B3),
        .Write_Done(write_done)
    );

 // Clock Generation (20ns period, 50 MHz) 
    initial begin
        HCLK = 0;
        forever #10 HCLK = ~HCLK; // Matches your 20ns clock period
    end

    // Reset Generation
    initial begin
        HRESETn = 0;
        #25 HRESETn = 1; // Reset low for 25ns, then high
    end

    // Timing Measurement
    initial begin
        start_time = 0;
        end_time = 0;
        wait(HRESETn == 1);
        #10; // Allow system to stabilize
        start_time = $time; // Capture start time
        wait(ctrl_done == 1);
        end_time = $time; // Capture end time
        $display("Execution time: %d ns", end_time - start_time);
        // $stop; // Commented out as in your original code
    end
end

else if(NUM_OF_PIXEL ==8)begin

 reg HCLK, HRESETn;
    wire vsync, hsync;
    wire [7:0] data_R0, data_G0, data_B0;
    wire [7:0] data_R1, data_G1, data_B1;   // Pixel 1
    wire [7:0] data_R2, data_G2, data_B2;   // Pixel 2
    wire [7:0] data_R3, data_G3, data_B3;   // Pixel 3
    wire [7:0] data_R4, data_G4, data_B4;   // Pixel 4
    wire [7:0] data_R5, data_G5, data_B5;   // Pixel 5
    wire [7:0] data_R6, data_G6, data_B6;   // Pixel 6
    wire [7:0] data_R7, data_G7, data_B7;   // Pixel 7
    wire ctrl_done;                         // Done flag from image_read
    wire write_done;                        // Done flag from image_write
    integer start_time;
    integer end_time; 

 image_read 
    #(.INFILE(`INPUTFILENAME))
    u_image_read (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .VSYNC(vsync),
        .HSYNC(hsync),
 //.NUM_OF_PIXEL(NUM_OF_PIXEL),
        .DATA_R0(data_R0),
        .DATA_G0(data_G0),
        .DATA_B0(data_B0),
        .DATA_R1(data_R1),
        .DATA_G1(data_G1),
        .DATA_B1(data_B1),
        .DATA_R2(data_R2),
        .DATA_G2(data_G2),
        .DATA_B2(data_B2),
        .DATA_R3(data_R3),
        .DATA_G3(data_G3),
        .DATA_B3(data_B3),
        .DATA_R4(data_R4),
        .DATA_G4(data_G4),
        .DATA_B4(data_B4),
        .DATA_R5(data_R5),
        .DATA_G5(data_G5),
        .DATA_B5(data_B5),
        .DATA_R6(data_R6),
        .DATA_G6(data_G6),
        .DATA_B6(data_B6),
        .DATA_R7(data_R7),
        .DATA_G7(data_G7),
        .DATA_B7(data_B7),
        .ctrl_done(ctrl_done)
    );

    // Instantiate image_write (manual 8-pixel version)
    image_write 
    #(.INFILE(`OUTPUTFILENAME))
    u_image_write (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .hsync(hsync),
 //.NUM_OF_PIXEL(NUM_OF_PIXEL),
        .DATA_WRITE_R0(data_R0),
        .DATA_WRITE_G0(data_G0),
        .DATA_WRITE_B0(data_B0),
        .DATA_WRITE_R1(data_R1),
        .DATA_WRITE_G1(data_G1),
        .DATA_WRITE_B1(data_B1),
        .DATA_WRITE_R2(data_R2),
        .DATA_WRITE_G2(data_G2),
        .DATA_WRITE_B2(data_B2),
        .DATA_WRITE_R3(data_R3),
        .DATA_WRITE_G3(data_G3),
        .DATA_WRITE_B3(data_B3),
        .DATA_WRITE_R4(data_R4),
        .DATA_WRITE_G4(data_G4),
        .DATA_WRITE_B4(data_B4),
        .DATA_WRITE_R5(data_R5),
        .DATA_WRITE_G5(data_G5),
        .DATA_WRITE_B5(data_B5),
        .DATA_WRITE_R6(data_R6),
        .DATA_WRITE_G6(data_G6),
        .DATA_WRITE_B6(data_B6),
        .DATA_WRITE_R7(data_R7),
        .DATA_WRITE_G7(data_G7),
        .DATA_WRITE_B7(data_B7),
        .Write_Done(write_done)
    );


 // Clock Generation (20ns period, 50 MHz) 
    initial begin
        HCLK = 0;
        forever #10 HCLK = ~HCLK; // Matches your 20ns clock period
    end

    // Reset Generation
    initial begin
        HRESETn = 0;
        #25 HRESETn = 1; // Reset low for 25ns, then high
    end

    // Timing Measurement
    initial begin
        start_time = 0;
        end_time = 0;
        wait(HRESETn == 1);
        #10; // Allow system to stabilize
        start_time = $time; // Capture start time
        wait(ctrl_done == 1);
        end_time = $time; // Capture end time
        $display("Execution time: %d ns", end_time - start_time);
        // $stop; // Commented out as in your original code
    end
end
else begin
  reg HCLK, HRESETn;
    wire vsync, hsync;
    wire [7:0] data_R0, data_G0, data_B0;   // Pixel 0
    wire [7:0] data_R1, data_G1, data_B1;   // Pixel 1
    wire [7:0] data_R2, data_G2, data_B2;   // Pixel 2
    wire [7:0] data_R3, data_G3, data_B3;   // Pixel 3
    wire [7:0] data_R4, data_G4, data_B4;   // Pixel 4
    wire [7:0] data_R5, data_G5, data_B5;   // Pixel 5
    wire [7:0] data_R6, data_G6, data_B6;   // Pixel 6
    wire [7:0] data_R7, data_G7, data_B7;   // Pixel 7
    wire [7:0] data_R8, data_G8, data_B8;   // Pixel 8
    wire [7:0] data_R9, data_G9, data_B9;   // Pixel 9
    wire [7:0] data_R10, data_G10, data_B10; // Pixel 10
    wire [7:0] data_R11, data_G11, data_B11; // Pixel 11
    wire [7:0] data_R12, data_G12, data_B12; // Pixel 12
    wire [7:0] data_R13, data_G13, data_B13; // Pixel 13
    wire [7:0] data_R14, data_G14, data_B14; // Pixel 14
    wire [7:0] data_R15, data_G15, data_B15; // Pixel 15
    wire ctrl_done;                         // Done flag from image_read
    wire write_done;                        // Done flag from image_write
    integer start_time;
    integer end_time; 


//inatantiate
image_read 
    #(.INFILE(`INPUTFILENAME))
    u_image_read (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .VSYNC(vsync),
        .HSYNC(hsync),
 //.NUM_OF_PIXEL(NUM_OF_PIXEL),
        .DATA_R0(data_R0),
        .DATA_G0(data_G0),
        .DATA_B0(data_B0),
        .DATA_R1(data_R1),
        .DATA_G1(data_G1),
        .DATA_B1(data_B1),
        .DATA_R2(data_R2),
        .DATA_G2(data_G2),
        .DATA_B2(data_B2),
        .DATA_R3(data_R3),
        .DATA_G3(data_G3),
        .DATA_B3(data_B3),
        .DATA_R4(data_R4),
        .DATA_G4(data_G4),
        .DATA_B4(data_B4),
        .DATA_R5(data_R5),
        .DATA_G5(data_G5),
        .DATA_B5(data_B5),
        .DATA_R6(data_R6),
        .DATA_G6(data_G6),
        .DATA_B6(data_B6),
        .DATA_R7(data_R7),
        .DATA_G7(data_G7),
        .DATA_B7(data_B7),
        .DATA_R8(data_R8),
        .DATA_G8(data_G8),
        .DATA_B8(data_B8),
        .DATA_R9(data_R9),
        .DATA_G9(data_G9),
        .DATA_B9(data_B9),
        .DATA_R10(data_R10),
        .DATA_G10(data_G10),
        .DATA_B10(data_B10),
        .DATA_R11(data_R11),
        .DATA_G11(data_G11),
        .DATA_B11(data_B11),
        .DATA_R12(data_R12),
        .DATA_G12(data_G12),
        .DATA_B12(data_B12),
        .DATA_R13(data_R13),
        .DATA_G13(data_G13),
        .DATA_B13(data_B13),
        .DATA_R14(data_R14),
        .DATA_G14(data_G14),
        .DATA_B14(data_B14),
        .DATA_R15(data_R15),
        .DATA_G15(data_G15),
        .DATA_B15(data_B15),
        .ctrl_done(ctrl_done)
    );

    // Instantiate image_write (16-pixel version)
    image_write 
    #(.INFILE(`OUTPUTFILENAME))
    u_image_write (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .hsync(hsync),
 //.NUM_OF_PIXEL(NUM_OF_PIXEL),
        .DATA_WRITE_R0(data_R0),
        .DATA_WRITE_G0(data_G0),
        .DATA_WRITE_B0(data_B0),
        .DATA_WRITE_R1(data_R1),
        .DATA_WRITE_G1(data_G1),
        .DATA_WRITE_B1(data_B1),
        .DATA_WRITE_R2(data_R2),
        .DATA_WRITE_G2(data_G2),
        .DATA_WRITE_B2(data_B2),
        .DATA_WRITE_R3(data_R3),
        .DATA_WRITE_G3(data_G3),
        .DATA_WRITE_B3(data_B3),
        .DATA_WRITE_R4(data_R4),
        .DATA_WRITE_G4(data_G4),
        .DATA_WRITE_B4(data_B4),
        .DATA_WRITE_R5(data_R5),
        .DATA_WRITE_G5(data_G5),
        .DATA_WRITE_B5(data_B5),
        .DATA_WRITE_R6(data_R6),
        .DATA_WRITE_G6(data_G6),
        .DATA_WRITE_B6(data_B6),
        .DATA_WRITE_R7(data_R7),
        .DATA_WRITE_G7(data_G7),
        .DATA_WRITE_B7(data_B7),
        .DATA_WRITE_R8(data_R8),
        .DATA_WRITE_G8(data_G8),
        .DATA_WRITE_B8(data_B8),
        .DATA_WRITE_R9(data_R9),
        .DATA_WRITE_G9(data_G9),
        .DATA_WRITE_B9(data_B9),
        .DATA_WRITE_R10(data_R10),
        .DATA_WRITE_G10(data_G10),
        .DATA_WRITE_B10(data_B10),
        .DATA_WRITE_R11(data_R11),
        .DATA_WRITE_G11(data_G11),
        .DATA_WRITE_B11(data_B11),
        .DATA_WRITE_R12(data_R12),
        .DATA_WRITE_G12(data_G12),
        .DATA_WRITE_B12(data_B12),
        .DATA_WRITE_R13(data_R13),
        .DATA_WRITE_G13(data_G13),
        .DATA_WRITE_B13(data_B13),
        .DATA_WRITE_R14(data_R14),
        .DATA_WRITE_G14(data_G14),
        .DATA_WRITE_B14(data_B14),
        .DATA_WRITE_R15(data_R15),
        .DATA_WRITE_G15(data_G15),
        .DATA_WRITE_B15(data_B15),
        .Write_Done(write_done)
    );


 // Clock Generation (20ns period, 50 MHz) 
    initial begin
        HCLK = 0;
        forever #10 HCLK = ~HCLK; // Matches your 20ns clock period
    end

    // Reset Generation
    initial begin
        HRESETn = 0;
        #25 HRESETn = 1; // Reset low for 25ns, then high
    end

    // Timing Measurement
    initial begin
        start_time = 0;
        end_time = 0;
        wait(HRESETn == 1);
        #10; // Allow system to stabilize
        start_time = $time; // Capture start time
        wait(ctrl_done == 1);
        end_time = $time; // Capture end time
        $display("Execution time: %d ns", end_time - start_time);
        // $stop; // Commented out as in your original code
    end

end
                     



endmodule