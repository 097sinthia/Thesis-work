`include "parameter.v"    // Include definition file
module image_read
#(
  parameter WIDTH  = 768,    // Image width
            HEIGHT = 512, // Image height
            INFILE = "input1.hex", // image file
            START_UP_DELAY = 100, // Delay during start up time
            HSYNC_DELAY = 160, // Delay between HSYNC pulses    
            VALUE = 70, // value for Brightness operation
            THRESHOLD = 90, // Threshold value for Threshold operation
            SIGN = 0, // Sign value using for brightness operation
                    // SIGN = 0: Brightness subtraction
                    // SIGN = 1: Brightness addition
           NUM_OF_PIXEL =  8  //1 -> for single pixel
                              //2 -> for dual pixel
                              //4 -> for 4 pixel
                              //8 -> for 8 pixel
                              //16 -> for 16 pixel
)
(
    input HCLK,                             // Clock                    
    input HRESETn,                          // Reset (active low)
    output VSYNC,                           // Vertical synchronous pulse
    output reg HSYNC,                       // Horizontal synchronous pulse
    output reg [7:0] DATA_R0,               // 8 bit Red data (pixel 0)
    output reg [7:0] DATA_G0,               // 8 bit Green data (pixel 0)
    output reg [7:0] DATA_B0,               // 8 bit Blue data (pixel 0)
    output reg [7:0] DATA_R1,               // 8 bit Red data (pixel 1)
    output reg [7:0] DATA_G1,               // 8 bit Green data (pixel 1)
    output reg [7:0] DATA_B1,               // 8 bit Blue data (pixel 1)
    output reg [7:0] DATA_R2,               // 8 bit Red data (pixel 2)
    output reg [7:0] DATA_G2,               // 8 bit Green data (pixel 2)
    output reg [7:0] DATA_B2,               // 8 bit Blue data (pixel 2)
    output reg [7:0] DATA_R3,               // 8 bit Red data (pixel 3)
    output reg [7:0] DATA_G3,               // 8 bit Green data (pixel 3)
    output reg [7:0] DATA_B3,               // 8 bit Blue data (pixel 3)
    output reg [7:0] DATA_R4,               // 8 bit Red data (pixel 4)
    output reg [7:0] DATA_G4,               // 8 bit Green data (pixel 4)
    output reg [7:0] DATA_B4,               // 8 bit Blue data (pixel 4)
    output reg [7:0] DATA_R5,               // 8 bit Red data (pixel 5)
    output reg [7:0] DATA_G5,               // 8 bit Green data (pixel 5)
    output reg [7:0] DATA_B5,               // 8 bit Blue data (pixel 5)
    output reg [7:0] DATA_R6,               // 8 bit Red data (pixel 6)
    output reg [7:0] DATA_G6,               // 8 bit Green data (pixel 6)
    output reg [7:0] DATA_B6,               // 8 bit Blue data (pixel 6)
    output reg [7:0] DATA_R7,               // 8 bit Red data (pixel 7)
    output reg [7:0] DATA_G7,               // 8 bit Green data (pixel 7)
    output reg [7:0] DATA_B7,               // 8 bit Blue data (pixel 7)
    output reg [7:0] DATA_R8,               // 8 bit Red data (pixel 8)
    output reg [7:0] DATA_G8,               // 8 bit Green data (pixel 8)
    output reg [7:0] DATA_B8,               // 8 bit Blue data (pixel 8)
    output reg [7:0] DATA_R9,               // 8 bit Red data (pixel 9)
    output reg [7:0] DATA_G9,               // 8 bit Green data (pixel 9)
    output reg [7:0] DATA_B9,               // 8 bit Blue data (pixel 9)
    output reg [7:0] DATA_R10,              // 8 bit Red data (pixel 10)
    output reg [7:0] DATA_G10,              // 8 bit Green data (pixel 10)
    output reg [7:0] DATA_B10,              // 8 bit Blue data (pixel 10)
    output reg [7:0] DATA_R11,              // 8 bit Red data (pixel 11)
    output reg [7:0] DATA_G11,              // 8 bit Green data (pixel 11)
    output reg [7:0] DATA_B11,              // 8 bit Blue data (pixel 11)
    output reg [7:0] DATA_R12,              // 8 bit Red data (pixel 12)
    output reg [7:0] DATA_G12,              // 8 bit Green data (pixel 12)
    output reg [7:0] DATA_B12,              // 8 bit Blue data (pixel 12)
    output reg [7:0] DATA_R13,              // 8 bit Red data (pixel 13)
    output reg [7:0] DATA_G13,              // 8 bit Green data (pixel 13)
    output reg [7:0] DATA_B13,              // 8 bit Blue data (pixel 13)
    output reg [7:0] DATA_R14,              // 8 bit Red data (pixel 14)
    output reg [7:0] DATA_G14,              // 8 bit Green data (pixel 14)
    output reg [7:0] DATA_B14,              // 8 bit Blue data (pixel 14)
    output reg [7:0] DATA_R15,              // 8 bit Red data (pixel 15)
    output reg [7:0] DATA_G15,              // 8 bit Green data (pixel 15)
    output reg [7:0] DATA_B15,              // 8 bit Blue data (pixel 15)
    output            ctrl_done             // Done flag
);

// Parameter and local parameter definitions remain unchanged
parameter sizeOfWidth = 8; // data width
parameter sizeOfLengthReal = 1179648; // image data : 1179648 bytes: 512 * 768 *3 
localparam ST_IDLE = 2'b00, // idle state
           ST_VSYNC = 2'b01, // state for creating vsync 
           ST_HSYNC = 2'b10, // state for creating hsync 
           ST_DATA = 2'b11; // state for data processing 

reg [1:0] cstate, nstate; // current and next state
reg start; // start signal
reg HRESETn_d; // delayed reset signal
reg ctrl_vsync_run; // control signal for vsync counter  
reg [9:0] ctrl_vsync_cnt; // counter for vsync
reg ctrl_hsync_run; // control signal for hsync counter
reg [9:0] ctrl_hsync_cnt; // counter for hsync
reg ctrl_data_run; // control signal for data processing
reg [31:0] in_memory [0:sizeOfLengthReal/4]; // memory to store 32-bit data image
reg [7:0] total_memory [0:sizeOfLengthReal-1]; // memory to store 8-bit data image
integer temp_BMP [0:WIDTH*HEIGHT*3 - 1]; // temporary memory to save image data
integer org_R [0:WIDTH*HEIGHT - 1]; // temporary storage for R component
integer org_G [0:WIDTH*HEIGHT - 1]; // temporary storage for G component
integer org_B [0:WIDTH*HEIGHT - 1]; // temporary storage for B component
integer i, j;
//integer tempR, tempG, tempB; // temporary variables for operations
//integer value; // temporary variable for threshold operation

integer tempR0, tempR1, tempR2, tempR3, tempR4, tempR5, tempR6, tempR7, 
        tempR8, tempR9, tempR10, tempR11, tempR12, tempR13, tempR14, tempR15,
        tempG0, tempG1, tempG2, tempG3, tempG4, tempG5, tempG6, tempG7,
        tempG8, tempG9, tempG10, tempG11, tempG12, tempG13, tempG14, tempG15,
        tempB0, tempB1, tempB2, tempB3, tempB4, tempB5, tempB6, tempB7,
        tempB8, tempB9, tempB10, tempB11, tempB12, tempB13, tempB14, tempB15; // Temporary variables in brightness operation

integer value, value1, value2, value3, value4, value5, value6, value7,
        value8, value9, value10, value11, value12, value13, value14, value15,
        value16, value17, value18, value19, value20, value21, value22, value23,
        value24, value25, value26, value27, value28, value29, value30, value31;
reg [10:0] row; // row index of the image
reg [10:0] col; // column index of the image
reg [19:0] data_count; // data counting for entire pixels of the image



// -------- Reading data from input file ----------//
initial begin
    $readmemh(INFILE, total_memory, 0, sizeOfLengthReal-1); // read file from INFILE
end

// Use intermediate signals RGB to save image data
always @(start) begin
    if (start == 1'b1) begin
        for (i = 0; i < WIDTH * HEIGHT * 3; i = i + 1) begin
            temp_BMP[i] = total_memory[i + 0][7:0]; 
        end
        
        for (i = 0; i < HEIGHT; i = i + 1) begin
            for (j = 0; j < WIDTH; j = j + 1) begin
                org_R[WIDTH * i + j] = temp_BMP[WIDTH * 3 * (HEIGHT - i - 1) + 3 * j + 0]; // save Red component
                org_G[WIDTH * i + j] = temp_BMP[WIDTH * 3 * (HEIGHT - i - 1) + 3 * j + 1]; // save Green component
                 org_B[WIDTH * i + j] = temp_BMP[WIDTH * 3 * (HEIGHT - i - 1) + 3 * j + 2]; // save
               end
        end
    end
end


//-------Begin to read image file once reset was high by creating a starting pulse (start)-------//
always@(posedge HCLK, negedge HRESETn)
begin
    if(!HRESETn) begin
        start <= 0;
		HRESETn_d <= 0;
    end
    else begin											//        		______ 				
        HRESETn_d <= HRESETn;							//       	|		|
		if(HRESETn == 1'b1 && HRESETn_d == 1'b0)		// __0___|	1	|___0____	: starting pulse
			start <= 1'b1;
		else
			start <= 1'b0;
    end
end


//---Finite state machine for reading RGB888 data from memory and creating hsync and vsync pulses ----//
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        cstate <= ST_IDLE;
    end
    else begin
        cstate <= nstate; // update next state 
    end
end


//--------- State Transition --------------//
// IDLE . VSYNC . HSYNC . DATA

//1 pixel
if(NUM_OF_PIXEL == 1)begin

always @(*) begin
	case(cstate)
		ST_IDLE: begin
			if(start)
				nstate = ST_VSYNC;
			else
				nstate = ST_IDLE;
		end			
		ST_VSYNC: begin
			if(ctrl_vsync_cnt == START_UP_DELAY) 
				nstate = ST_HSYNC;
			else
				nstate = ST_VSYNC;
		end
		ST_HSYNC: begin
			if(ctrl_hsync_cnt == HSYNC_DELAY) 
				nstate = ST_DATA;
			else
				nstate = ST_HSYNC;
		end		
		ST_DATA: begin
			if(ctrl_done)
				nstate = ST_IDLE;
			else begin
				if(col == WIDTH - 1 )
					nstate = ST_HSYNC;
				else
					nstate = ST_DATA;
			end
		end
	endcase
end


end

//2 pixels
   
else if(NUM_OF_PIXEL == 2)begin

always @(*) begin
	case(cstate)
		ST_IDLE: begin
			if(start)
				nstate = ST_VSYNC;
			else
				nstate = ST_IDLE;
		end			
		ST_VSYNC: begin
			if(ctrl_vsync_cnt == START_UP_DELAY) 
				nstate = ST_HSYNC;
			else
				nstate = ST_VSYNC;
		end
		ST_HSYNC: begin
			if(ctrl_hsync_cnt == HSYNC_DELAY) 
				nstate = ST_DATA;
			else
				nstate = ST_HSYNC;
		end		
		ST_DATA: begin
			if(ctrl_done)
				nstate = ST_IDLE;
			else begin
				if(col == WIDTH - 2 )
					nstate = ST_HSYNC;
				else
					nstate = ST_DATA;
			end
		end
	endcase
end


end

//4 pixel

else if(NUM_OF_PIXEL == 4)begin

always @(*) begin
	case(cstate)
		ST_IDLE: begin
			if(start)
				nstate = ST_VSYNC;
			else
				nstate = ST_IDLE;
		end			
		ST_VSYNC: begin
			if(ctrl_vsync_cnt == START_UP_DELAY) 
				nstate = ST_HSYNC;
			else
				nstate = ST_VSYNC;
		end
		ST_HSYNC: begin
			if(ctrl_hsync_cnt == HSYNC_DELAY) 
				nstate = ST_DATA;
			else
				nstate = ST_HSYNC;
		end		
		ST_DATA: begin
			if(ctrl_done)
				nstate = ST_IDLE;
			else begin
				if(col == WIDTH - 4 )
					nstate = ST_HSYNC;
				else
					nstate = ST_DATA;
			end
		end
	endcase
end


end

//for 8 pixel
else if(NUM_OF_PIXEL == 8)begin

always @(*) begin
	case(cstate)
		ST_IDLE: begin
			if(start)
				nstate = ST_VSYNC;
			else
				nstate = ST_IDLE;
		end			
		ST_VSYNC: begin
			if(ctrl_vsync_cnt == START_UP_DELAY) 
				nstate = ST_HSYNC;
			else
				nstate = ST_VSYNC;
		end
		ST_HSYNC: begin
			if(ctrl_hsync_cnt == HSYNC_DELAY) 
				nstate = ST_DATA;
			else
				nstate = ST_HSYNC;
		end		
		ST_DATA: begin
			if(ctrl_done)
				nstate = ST_IDLE;
			else begin
				if(col == WIDTH - 8 )
					nstate = ST_HSYNC;
				else
					nstate = ST_DATA;
			end
		end
	endcase
end


end
   
 //for 16
else begin

always @(*) begin
	case(cstate)
		ST_IDLE: begin
			if(start)
				nstate = ST_VSYNC;
			else
				nstate = ST_IDLE;
		end			
		ST_VSYNC: begin
			if(ctrl_vsync_cnt == START_UP_DELAY) 
				nstate = ST_HSYNC;
			else
				nstate = ST_VSYNC;
		end
		ST_HSYNC: begin
			if(ctrl_hsync_cnt == HSYNC_DELAY) 
				nstate = ST_DATA;
			else
				nstate = ST_HSYNC;
		end		
		ST_DATA: begin
			if(ctrl_done)
				nstate = ST_IDLE;
			else begin
				if(col == WIDTH - 16 )
					nstate = ST_HSYNC;
				else
					nstate = ST_DATA;
			end
		end
	endcase
end


end
     


   
// --- counting for time period of vsync, hsync, data processing ----  //
always @(*) begin
	ctrl_vsync_run = 0;
	ctrl_hsync_run = 0;
	ctrl_data_run  = 0;
	case(cstate)
		ST_VSYNC: 	begin ctrl_vsync_run = 1; end 	// trigger counting for vsync
		ST_HSYNC: 	begin ctrl_hsync_run = 1; end	// trigger counting for hsync
		ST_DATA: 	begin ctrl_data_run  = 1; end	// trigger counting for data processing
	endcase
end
// counters for vsync, hsync
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        ctrl_vsync_cnt <= 0;
		ctrl_hsync_cnt <= 0;
    end
    else begin
        if(ctrl_vsync_run)
			ctrl_vsync_cnt <= ctrl_vsync_cnt + 1; // counting for vsync
		else 
			ctrl_vsync_cnt <= 0;
			
        if(ctrl_hsync_run)
			ctrl_hsync_cnt <= ctrl_hsync_cnt + 1;	// counting for hsync		
		else
			ctrl_hsync_cnt <= 0;
    end
end
// counting column and row index  for reading memory 

//for 1 pixel

if(NUM_OF_PIXEL ==1)begin
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        row <= 0;
		col <= 0;
    end
	else begin
		if(ctrl_data_run) begin
			if(col == WIDTH - 1) begin
				row <= row + 1;
			end
			if(col == WIDTH - 1)begin 
				col <= 0;
                              end
			else begin
				col <= col + 1; // reading 1 pixel
                          end
		end
	end
end

end

//for 2 pixels

else if(NUM_OF_PIXEL ==2)begin
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        row <= 0;
		col <= 0;
    end
	else begin
		if(ctrl_data_run) begin
			if(col == WIDTH - 2) begin
				row <= row + 1;
			end
			if(col == WIDTH - 2)begin 
				col <= 0;
                              end
			else begin
				col <= col + 2; // reading 1 pixel
                          end
		end
	end
end

end

//for 4 pixels


else if(NUM_OF_PIXEL ==4)begin
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        row <= 0;
		col <= 0;
    end
	else begin
		if(ctrl_data_run) begin
			if(col == WIDTH - 4) begin
				row <= row + 1;
			end
			if(col == WIDTH - 4)begin 
				col <= 0;
                              end
			else begin
				col <= col + 4; // reading 1 pixel
                          end
		end
	end
end

end

//for 8 pixels

else if(NUM_OF_PIXEL ==8)begin
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        row <= 0;
		col <= 0;
    end
	else begin
		if(ctrl_data_run) begin
			if(col == WIDTH -8 ) begin
				row <= row + 1;
			end
			if(col == WIDTH - 8)begin 
				col <= 0;
                              end
			else begin
				col <= col + 8; // reading 1 pixel
                          end
		end
	end
end

end


else begin
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        row <= 0;
		col <= 0;
    end
	else begin
		if(ctrl_data_run) begin
			if(col == WIDTH - 16) begin
				row <= row + 1;
			end
			if(col == WIDTH - 16)begin 
				col <= 0;
                              end
			else begin
				col <= col + 16; // reading 1 pixel
                          end
		end
	end
end

end

//----------------Data counting---------- ---------//
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        data_count <= 0;
    end
    else begin
        if(ctrl_data_run)
			data_count <= data_count + 1;
    end
end

assign data_count_out = data_count;
//assign VSYNC = ctrl_vsync_run;
//for 1 pixel
if(NUM_OF_PIXEL == 1)begin

assign ctrl_done = (data_count == 393215)? 1'b1: 1'b0; // done flag

end

//for 2 pixel
else if(NUM_OF_PIXEL == 2)begin

assign ctrl_done = (data_count == 196607)? 1'b1: 1'b0; // done flag

end

//for 4 pixel
else if(NUM_OF_PIXEL == 4)begin

assign ctrl_done = (data_count == 98303)? 1'b1: 1'b0; // done flag

end

//for 8 pixel
else if(NUM_OF_PIXEL == 8)begin

assign ctrl_done = (data_count == 49151)? 1'b1: 1'b0; // done flag

end

//for 16 pixels
else begin

assign ctrl_done = (data_count == 24575)? 1'b1: 1'b0; // done flag

end




//-------------  Image processing   ---------------//


//for 1 pixel 
if (NUM_OF_PIXEL==1)begin

always @(*) begin
    HSYNC = 1'b0;
    DATA_R0 = 0;
    DATA_G0 = 0;
    DATA_B0 = 0;                                         
    if (ctrl_data_run) begin
        HSYNC = 1'b1;

        // Brightness Operation
        `ifdef BRIGHTNESS_OPERATION
        if (SIGN == 1) begin
            // Brightness Addition
            tempR0 = org_R[WIDTH * row + col] + VALUE;
            DATA_R0 = (tempR0 > 255) ? 255 : tempR0;

            tempG0 = org_G[WIDTH * row + col] + VALUE;
            DATA_G0 = (tempG0 > 255) ? 255 : tempG0;

            tempB0 = org_B[WIDTH * row + col] + VALUE;
            DATA_B0 = (tempB0 > 255) ? 255 : tempB0;
        end else begin
            // Brightness Subtraction
            tempR0 = org_R[WIDTH * row + col] - VALUE;
            DATA_R0 = (tempR0 < 0) ? 0 : tempR0;

            tempG0 = org_G[WIDTH * row + col] - VALUE;
            DATA_G0 = (tempG0 < 0) ? 0 : tempG0;

            tempB0 = org_B[WIDTH * row + col] - VALUE;
            DATA_B0 = (tempB0 < 0) ? 0 : tempB0;
        end
        `endif

        // Inversion Operation
        `ifdef INVERT_OPERATION
            DATA_R0 = 255 - org_R[WIDTH * row + col];
            DATA_G0 = 255 - org_G[WIDTH * row + col];
            DATA_B0 = 255 - org_B[WIDTH * row + col];
        `endif

        // Black & White Operation
        `ifdef BLACKandWHITE_OPERATION
            value = (org_R[WIDTH * row + col] + org_G[WIDTH * row + col] + org_B[WIDTH * row + col]) / 3;
            DATA_R0 = value;
            DATA_G0 = value;
            DATA_B0 = value;
        `endif

        // Threshold Operation
        `ifdef THRESHOLD_OPERATION
            value = (org_R[WIDTH * row + col] + org_G[WIDTH * row + col] + org_B[WIDTH * row + col]) / 3;
            if (value > THRESHOLD) begin
                DATA_R0 = 255;
                DATA_G0 = 255;
                DATA_B0 = 255;
            end else begin
                DATA_R0 = 0;
                DATA_G0 = 0;
                DATA_B0 = 0;
            end
        `endif
    end
end

end

//for 2 pixel
else if(NUM_OF_PIXEL == 2)begin

always @(*) begin
	
	HSYNC   = 1'b0;
	DATA_R0 = 0;
	DATA_G0 = 0;
	DATA_B0 = 0;                                       
	DATA_R1 = 0;
	DATA_G1 = 0;
	DATA_B1 = 0;                                         
	if(ctrl_data_run) begin
		
		HSYNC   = 1'b1;
		`ifdef BRIGHTNESS_OPERATION	
		/**************************************/		
		/*		BRIGHTNESS ADDITION OPERATION */
		/**************************************/
		if(SIGN == 1) begin
		// R0
		tempR0 = org_R[WIDTH * row + col   ] + VALUE;
		if (tempR0 > 255)
			DATA_R0 = 255;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] + VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] + VALUE;
		if (tempR1 > 255)
			DATA_R1 = 255;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] + VALUE;	
		// G0	
		tempG0 = org_G[WIDTH * row + col   ] + VALUE;
		if (tempG0 > 255)
			DATA_G0 = 255;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] + VALUE;
		tempG1 = org_G[WIDTH * row + col+1   ] + VALUE;
		if (tempG1 > 255)
			DATA_G1 = 255;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] + VALUE;		
		// B
		tempB0 = org_B[WIDTH * row + col   ] + VALUE;
		if (tempB0 > 255)
			DATA_B0 = 255;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] + VALUE;
		tempB1 = org_B[WIDTH * row + col+1   ] + VALUE;
		if (tempB1 > 255)
			DATA_B1 = 255;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] + VALUE;
	end
	else begin
	/**************************************/		
	/*	BRIGHTNESS SUBTRACTION OPERATION */
	/**************************************/
		// R0
		tempR0 = org_R[WIDTH * row + col   ] - VALUE;
		if (tempR0 < 0)
			DATA_R0 = 0;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] - VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] - VALUE;
		if (tempR1 < 0)
			DATA_R1 = 0;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] - VALUE;	
		// G0	
		tempG0 = org_G[WIDTH * row + col   ] - VALUE;
		if (tempG0 < 0)
			DATA_G0 = 0;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] - VALUE;
		tempG1 = org_G[WIDTH * row + col+1   ] - VALUE;
		if (tempG1 < 0)
			DATA_G1 = 0;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] - VALUE;		
		// B
		tempB0 = org_B[WIDTH * row + col   ] - VALUE;
		if (tempB0 < 0)
			DATA_B0 = 0;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] - VALUE;
		tempB1 = org_B[WIDTH * row + col+1   ] - VALUE;
		if (tempB1 < 0)
			DATA_B1 = 0;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] - VALUE;
	 end
		`endif
	
		/**************************************/		
		/*		INVERT_OPERATION  			  */
		/**************************************/
		`ifdef INVERT_OPERATION	
			//value2 = (org_B[WIDTH * row + col  ] + org_R[WIDTH * row + col  ] +org_G[WIDTH * row + col  ])/3;
			DATA_R0=255-org_R[WIDTH * row + col  ] ;
			DATA_G0=255-org_G[WIDTH * row + col  ];
			DATA_B0=255-org_B[WIDTH * row + col  ];
			//value4 = (org_B[WIDTH * row + col+1  ] + org_R[WIDTH * row + col+1  ] +org_G[WIDTH * row + col+1  ])/3;
			DATA_R1=255-org_R[WIDTH * row + col+1  ];
			DATA_G1=255-org_G[WIDTH * row + col+1  ];
			DATA_B1=255-org_B[WIDTH * row + col+1  ];		
		`endif
		
				/**************************************/		
		/*		BLACK & WHITE_OPERATION  			  */
		/**************************************/
		`ifdef BLACKandWHITE_OPERATION	
			value2 = (org_B[WIDTH * row + col  ] + org_R[WIDTH * row + col  ] +org_G[WIDTH * row + col  ])/3;
			DATA_R0=value2;
			DATA_G0=value2;
			DATA_B0=value2;
			value4 = (org_B[WIDTH * row + col+1  ] + org_R[WIDTH * row + col+1  ] +org_G[WIDTH * row + col+1  ])/3;
			DATA_R1=value4;
			DATA_G1=value4;
			DATA_B1=value4;		
		`endif
		
		
		/**************************************/		
		/********THRESHOLD OPERATION  *********/
		/**************************************/
		`ifdef THRESHOLD_OPERATION

		value = (org_R[WIDTH * row + col   ]+org_G[WIDTH * row + col   ]+org_B[WIDTH * row + col   ])/3;
		if(value > THRESHOLD) begin
			DATA_R0=255;
			DATA_G0=255;
			DATA_B0=255;
		end
		else begin
			DATA_R0=0;
			DATA_G0=0;
			DATA_B0=0;
		end
		value1 = (org_R[WIDTH * row + col+1   ]+org_G[WIDTH * row + col+1   ]+org_B[WIDTH * row + col+1   ])/3;
		if(value1 > THRESHOLD) begin
			DATA_R1=255;
			DATA_G1=255;
			DATA_B1=255;
		end
		else begin
			DATA_R1=0;
			DATA_G1=0;
			DATA_B1=0;
		end		
		`endif
		
	end
end


end

//for 4 pixel
else if(NUM_OF_PIXEL == 4)begin

always @(*) begin
	
	HSYNC   = 1'b0;
	DATA_R0 = 0;
	DATA_G0 = 0;
	DATA_B0 = 0;                                       
	DATA_R1 = 0;
	DATA_G1 = 0;
	DATA_B1 = 0;  
        DATA_R2 = 0;
	DATA_G2 = 0;
	DATA_B2 = 0;                                       
	DATA_R3 = 0;
	DATA_G3 = 0;
	DATA_B3 = 0;  
                                              
	if(ctrl_data_run) begin
		
		HSYNC   = 1'b1;
		`ifdef BRIGHTNESS_OPERATION	
		/**************************************/		
		/*		BRIGHTNESS ADDITION OPERATION */
		/**************************************/
		if(SIGN == 1) begin
		

                 //FOR RED
                  // R0
		tempR0 = org_R[WIDTH * row + col   ] + VALUE;
		if (tempR0 > 255)
			DATA_R0 = 255;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] + VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] + VALUE;
		if (tempR1 > 255)
			DATA_R1 = 255;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] + VALUE;	
                // R2
		tempR2 = org_R[WIDTH * row + col+2   ] + VALUE;
		if (tempR2 > 255)
			DATA_R2 = 255;
		else
			DATA_R2 = org_R[WIDTH * row + col +2  ] + VALUE;
		// R3	
		tempR3 = org_R[WIDTH * row + col+3   ] + VALUE;
		if (tempR3 > 255)
			DATA_R3 = 255;
		else
			DATA_R3 = org_R[WIDTH * row + col+3   ] + VALUE;	
              

                


            //FOR GREEN 
                     // G0
		tempG0 = org_G[WIDTH * row + col   ] + VALUE;
		if (tempG0 > 255)
			DATA_G0 = 255;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] + VALUE;
		// G1	
		tempG1 = org_G[WIDTH * row + col+1   ] + VALUE;
		if (tempG1 > 255)
			DATA_G1 = 255;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] + VALUE;	
                // G2
		tempG2 = org_G[WIDTH * row + col+2   ] + VALUE;
		if (tempG2 > 255)
			DATA_G2 = 255;
		else
			DATA_G2 = org_G[WIDTH * row + col +2  ] + VALUE;
		// G3	
		tempG3 = org_G[WIDTH * row + col+3   ] + VALUE;
		if (tempG3 > 255)
			DATA_G3 = 255;
		else
			DATA_G3 = org_G[WIDTH * row + col+3   ] + VALUE;	
              



                   //FOR BLUE


                 // B0
		tempB0 = org_B[WIDTH * row + col   ] + VALUE;
		if (tempB0 > 255)
			DATA_B0 = 255;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] + VALUE;
		// B1	
		tempB1 = org_B[WIDTH * row + col+1   ] + VALUE;
		if (tempB1 > 255)
			DATA_B1 = 255;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] + VALUE;	
                // B2
		tempB2 = org_B[WIDTH * row + col+2   ] + VALUE;
		if (tempB2 > 255)
			DATA_B2 = 255;
		else
			DATA_B2 = org_B[WIDTH * row + col +2  ] + VALUE;
		// B3	
		tempB3 = org_B[WIDTH * row + col+3   ] + VALUE;
		if (tempB3 > 255)
			DATA_B3 = 255;
		else
			DATA_B3 = org_B[WIDTH * row + col+3   ] + VALUE;	
               
		
	end


	else begin
	/**************************************/		
	/*	BRIGHTNESS SUBTRACTION OPERATION */
	/**************************************/

         
                 //FOR RED
                  // R0
		tempR0 = org_R[WIDTH * row + col   ] - VALUE;
		if (tempR0 < 0)
			DATA_R0 = 0;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] - VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] - VALUE;
		if (tempR1 < 0)
			DATA_R1 = 0;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] - VALUE;	
                // R2
		tempR2 = org_R[WIDTH * row + col+2   ] - VALUE;
		if (tempR2 < 0)
			DATA_R2 = 0;
		else
			DATA_R2 = org_R[WIDTH * row + col +2  ] - VALUE;
		// R3	
		tempR3 = org_R[WIDTH * row + col+3   ] - VALUE;
		if (tempR3 < 0)
			DATA_R3 = 0;
		else
			DATA_R3 = org_R[WIDTH * row + col+3   ] - VALUE;	
             
                


            //FOR GREEN 
                     // G0
		tempG0 = org_G[WIDTH * row + col   ] - VALUE;
		if (tempG0 < 0)
			DATA_G0 = 0;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] - VALUE;
		// G1	
		tempG1 = org_G[WIDTH * row + col+1   ] - VALUE;
		if (tempG1 < 0)
			DATA_G1 = 0;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] - VALUE;	
                // G2
		tempG2 = org_G[WIDTH * row + col+2   ] - VALUE;
		if (tempG2 < 0)
			DATA_G2 = 0;
		else
			DATA_G2 = org_G[WIDTH * row + col +2  ] - VALUE;
		// G3	
		tempG3 = org_G[WIDTH * row + col+3   ] - VALUE;
		if (tempG3 < 0)
			DATA_G3 = 0;
		else
			DATA_G3 = org_G[WIDTH * row + col+3   ] - VALUE;	
              



                   //FOR BLUE


                 // B0
		tempB0 = org_B[WIDTH * row + col   ] - VALUE;
		if (tempB0 < 0)
			DATA_B0 = 0;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] - VALUE;
		// B1	
		tempB1 = org_B[WIDTH * row + col+1   ] - VALUE;
		if (tempB1 < 0)
			DATA_B1 = 0;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] - VALUE;	
                // B2
		tempB2 = org_B[WIDTH * row + col+2   ] - VALUE;
		if (tempB2 < 0)
			DATA_B2 = 0;
		else
			DATA_B2 = org_B[WIDTH * row + col +2  ] - VALUE;
		// B3	
		tempB3 = org_B[WIDTH * row + col+3   ] - VALUE;
		if (tempB3 < 0)
			DATA_B3 = 0;
		else
			DATA_B3 = org_B[WIDTH * row + col+3   ] - VALUE;	
              


		
	end



`endif
	
		/**************************************/		
		/*		INVERT_OPERATION  			  */
		/**************************************/
		`ifdef INVERT_OPERATION	
			//value2 = (org_B[WIDTH * row + col  ] + org_R[WIDTH * row + col  ] +org_G[WIDTH * row + col  ])/3;
			DATA_R0=255-org_R[WIDTH * row + col  ] ;
			DATA_G0=255-org_G[WIDTH * row + col  ];
			DATA_B0=255-org_B[WIDTH * row + col  ];
			//value4 = (org_B[WIDTH * row + col+1  ] + org_R[WIDTH * row + col+1  ] +org_G[WIDTH * row + col+1  ])/3;
			DATA_R1=255-org_R[WIDTH * row + col+1  ];
			DATA_G1=255-org_G[WIDTH * row + col+1  ];
			DATA_B1=255-org_B[WIDTH * row + col+1  ];	
                      

                       DATA_R2=255-org_R[WIDTH * row + col+2  ];
			DATA_G2=255-org_G[WIDTH * row + col+2  ];
			DATA_B2=255-org_B[WIDTH * row + col+2  ];	


                        DATA_R3=255-org_R[WIDTH * row + col+3  ];
			DATA_G3=255-org_G[WIDTH * row + col+3  ];
			DATA_B3=255-org_B[WIDTH * row + col+3  ];	


                       


	
		`endif
		
				/**************************************/		
		/*		BLACK & WHITE_OPERATION  			  */
		/**************************************/
		`ifdef BLACKandWHITE_OPERATION	
			value4 = (org_B[WIDTH * row + col  ] + org_R[WIDTH * row + col  ] +org_G[WIDTH * row + col  ])/3;
			DATA_R0=value4;
			DATA_G0=value4;
			DATA_B0=value4;
			value5 = (org_B[WIDTH * row + col+1  ] + org_R[WIDTH * row + col+1  ] +org_G[WIDTH * row + col+1  ])/3;
			DATA_R1=value5;
			DATA_G1=value5;
			DATA_B1=value5;		
                       

                       value6 = (org_B[WIDTH * row + col+2  ] + org_R[WIDTH * row + col+2  ] +org_G[WIDTH * row + col+2  ])/3;
			DATA_R2=value6;
			DATA_G2=value6;
			DATA_B2=value6;
			value7 = (org_B[WIDTH * row + col+3  ] + org_R[WIDTH * row + col+3  ] +org_G[WIDTH * row + col+3  ])/3;
			DATA_R3=value7;
			DATA_G3=value7;
			DATA_B3=value7;		
               

                     	
		`endif
		
		
		/**************************************/		
		/********THRESHOLD OPERATION   *********/
		/**************************************/
		`ifdef THRESHOLD_OPERATION

		value = (org_R[WIDTH * row + col   ]+org_G[WIDTH * row + col   ]+org_B[WIDTH * row + col   ])/3;
		if(value > THRESHOLD) begin
			DATA_R0=255;
			DATA_G0=255;
			DATA_B0=255;
		end
		else begin
			DATA_R0=0;
			DATA_G0=0;
			DATA_B0=0;
		end
		value1 = (org_R[WIDTH * row + col+1   ]+org_G[WIDTH * row + col+1   ]+org_B[WIDTH * row + col+1   ])/3;
		if(value1 > THRESHOLD) begin
			DATA_R1=255;
			DATA_G1=255;
			DATA_B1=255;
		end
		else begin
			DATA_R1=0;
			DATA_G1=0;
			DATA_B1=0;
		end	
                 

                value2 = (org_R[WIDTH * row + col+2   ]+org_G[WIDTH * row + col+2   ]+org_B[WIDTH * row + col+2   ])/3;
		if(value2 > THRESHOLD) begin
			DATA_R2=255;
			DATA_G2=255;
			DATA_B2=255;
		end
		else begin
			DATA_R2=0;
			DATA_G2=0;
			DATA_B2=0;
		end	


                value3 = (org_R[WIDTH * row + col+3   ]+org_G[WIDTH * row + col+3   ]+org_B[WIDTH * row + col+3   ])/3;
		if(value3 > THRESHOLD) begin
			DATA_R3=255;
			DATA_G3=255;
			DATA_B3=255;
		end
		else begin
			DATA_R3=0;
			DATA_G3=0;
			DATA_B3=0;
		end	


		`endif

		
	end
end



end

//for 8 pixel
else if(NUM_OF_PIXEL == 8)begin
always @(*) begin
	
	HSYNC   = 1'b0;
	DATA_R0 = 0;
	DATA_G0 = 0;
	DATA_B0 = 0;                                       
	DATA_R1 = 0;
	DATA_G1 = 0;
	DATA_B1 = 0;  
        DATA_R2 = 0;
	DATA_G2 = 0;
	DATA_B2 = 0;                                       
	DATA_R3 = 0;
	DATA_G3 = 0;
	DATA_B3 = 0;  
        DATA_R4 = 0;
	DATA_G4 = 0;
	DATA_B4 = 0;                                       
	DATA_R5 = 0;
	DATA_G5 = 0;
	DATA_B5 = 0;  
        DATA_R6 = 0;
	DATA_G6 = 0;
	DATA_B6 = 0;                                       
	DATA_R7 = 0;
	DATA_G7 = 0;
	DATA_B7 = 0;                                         
	if(ctrl_data_run) begin
		
		HSYNC   = 1'b1;
		`ifdef BRIGHTNESS_OPERATION	
		/**************************************/		
		/*		BRIGHTNESS ADDITION OPERATION */
		/**************************************/
		if(SIGN == 1) begin
		

                 //FOR RED
                  // R0
		tempR0 = org_R[WIDTH * row + col   ] + VALUE;
		if (tempR0 > 255)
			DATA_R0 = 255;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] + VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] + VALUE;
		if (tempR1 > 255)
			DATA_R1 = 255;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] + VALUE;	
                // R2
		tempR2 = org_R[WIDTH * row + col+2   ] + VALUE;
		if (tempR2 > 255)
			DATA_R2 = 255;
		else
			DATA_R2 = org_R[WIDTH * row + col +2  ] + VALUE;
		// R3	
		tempR3 = org_R[WIDTH * row + col+3   ] + VALUE;
		if (tempR3 > 255)
			DATA_R3 = 255;
		else
			DATA_R3 = org_R[WIDTH * row + col+3   ] + VALUE;	
               // R4
		tempR4 = org_R[WIDTH * row + col+4   ] + VALUE;
		if (tempR4 > 255)
			DATA_R4 = 255;
		else
			DATA_R4 = org_R[WIDTH * row + col+4   ] + VALUE;
		// R5	
		tempR5 = org_R[WIDTH * row + col+5   ] + VALUE;
		if (tempR5 > 255)
			DATA_R5 = 255;
		else
			DATA_R5 = org_R[WIDTH * row + col+5   ] + VALUE;	

                 // R6
		tempR6 = org_R[WIDTH * row + col+6   ] + VALUE;
		if (tempR6 > 255)
			DATA_R6 = 255;
		else
			DATA_R6 = org_R[WIDTH * row + col+6   ] + VALUE;
		// R7	
		tempR7 = org_R[WIDTH * row + col+7   ] + VALUE;
		if (tempR7 > 255)
			DATA_R7 = 255;
		else
			DATA_R7 = org_R[WIDTH * row + col+7   ] + VALUE;	

                


            //FOR GREEN 
                     // G0
		tempG0 = org_G[WIDTH * row + col   ] + VALUE;
		if (tempG0 > 255)
			DATA_G0 = 255;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] + VALUE;
		// G1	
		tempG1 = org_G[WIDTH * row + col+1   ] + VALUE;
		if (tempG1 > 255)
			DATA_G1 = 255;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] + VALUE;	
                // G2
		tempG2 = org_G[WIDTH * row + col+2   ] + VALUE;
		if (tempG2 > 255)
			DATA_G2 = 255;
		else
			DATA_G2 = org_G[WIDTH * row + col +2  ] + VALUE;
		// G3	
		tempG3 = org_G[WIDTH * row + col+3   ] + VALUE;
		if (tempG3 > 255)
			DATA_G3 = 255;
		else
			DATA_G3 = org_G[WIDTH * row + col+3   ] + VALUE;	
               // G4
		tempG4 = org_G[WIDTH * row + col+4   ] + VALUE;
		if (tempG4 > 255)
			DATA_G4 = 255;
		else
			DATA_G4 = org_G[WIDTH * row + col+4   ] + VALUE;
		// G5	
		tempG5 = org_G[WIDTH * row + col+5   ] + VALUE;
		if (tempG5 > 255)
			DATA_G5 = 255;
		else
			DATA_G5 = org_G[WIDTH * row + col+5   ] + VALUE;	

                 // G6
		tempG6 = org_G[WIDTH * row + col+6   ] + VALUE;
		if (tempG6 > 255)
			DATA_G6 = 255;
		else
			DATA_G6 = org_G[WIDTH * row + col+6   ] + VALUE;
		// G7	
		tempG7 = org_G[WIDTH * row + col+7   ] + VALUE;
		if (tempG7 > 255)
			DATA_G7 = 255;
		else
			DATA_G7 = org_G[WIDTH * row + col+7   ] + VALUE;	



                   //FOR BLUE


                 // B0
		tempB0 = org_B[WIDTH * row + col   ] + VALUE;
		if (tempB0 > 255)
			DATA_B0 = 255;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] + VALUE;
		// B1	
		tempB1 = org_B[WIDTH * row + col+1   ] + VALUE;
		if (tempB1 > 255)
			DATA_B1 = 255;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] + VALUE;	
                // B2
		tempB2 = org_B[WIDTH * row + col+2   ] + VALUE;
		if (tempB2 > 255)
			DATA_B2 = 255;
		else
			DATA_B2 = org_B[WIDTH * row + col +2  ] + VALUE;
		// B3	
		tempB3 = org_B[WIDTH * row + col+3   ] + VALUE;
		if (tempB3 > 255)
			DATA_B3 = 255;
		else
			DATA_B3 = org_B[WIDTH * row + col+3   ] + VALUE;	
               // B4
		tempB4 = org_B[WIDTH * row + col+4   ] + VALUE;
		if (tempB4 > 255)
			DATA_B4 = 255;
		else
			DATA_B4 = org_B[WIDTH * row + col+4   ] + VALUE;
		// B5	
		tempB5 = org_B[WIDTH * row + col+5   ] + VALUE;
		if (tempB5 > 255)
			DATA_B5 = 255;
		else
			DATA_B5 = org_B[WIDTH * row + col+5   ] + VALUE;	

                 // B6
		tempB6 = org_B[WIDTH * row + col+6   ] + VALUE;
		if (tempB6 > 255)
			DATA_B6 = 255;
		else
			DATA_B6 = org_B[WIDTH * row + col+6   ] + VALUE;
		// B7	
		tempB7 = org_B[WIDTH * row + col+7   ] + VALUE;
		if (tempB7 > 255)
			DATA_B7 = 255;
		else
			DATA_B7 = org_B[WIDTH * row + col+7   ] + VALUE;	


		
	end


	else begin
	/**************************************/		
	/*	BRIGHTNESS SUBTRACTION OPERATION */
	/**************************************/

         
                 //FOR RED
                  // R0
		tempR0 = org_R[WIDTH * row + col   ] - VALUE;
		if (tempR0 < 0)
			DATA_R0 = 0;
		else
			DATA_R0 = org_R[WIDTH * row + col   ] - VALUE;
		// R1	
		tempR1 = org_R[WIDTH * row + col+1   ] - VALUE;
		if (tempR1 < 0)
			DATA_R1 = 0;
		else
			DATA_R1 = org_R[WIDTH * row + col+1   ] - VALUE;	
                // R2
		tempR2 = org_R[WIDTH * row + col+2   ] - VALUE;
		if (tempR2 < 0)
			DATA_R2 = 0;
		else
			DATA_R2 = org_R[WIDTH * row + col +2  ] - VALUE;
		// R3	
		tempR3 = org_R[WIDTH * row + col+3   ] - VALUE;
		if (tempR3 < 0)
			DATA_R3 = 0;
		else
			DATA_R3 = org_R[WIDTH * row + col+3   ] - VALUE;	
               // R4
		tempR4 = org_R[WIDTH * row + col+4   ] - VALUE;
		if (tempR4 < 0)
			DATA_R4 = 0;
		else
			DATA_R4 = org_R[WIDTH * row + col+4   ] - VALUE;
		// R5	
		tempR5 = org_R[WIDTH * row + col+5   ] - VALUE;
		if (tempR5 < 0)
			DATA_R5 = 0;
		else
			DATA_R5 = org_R[WIDTH * row + col+5   ] - VALUE;	

                 // R6
		tempR6 = org_R[WIDTH * row + col+6   ] - VALUE;
		if (tempR6 < 0)
			DATA_R6 = 0;
		else
			DATA_R6 = org_R[WIDTH * row + col+6   ] - VALUE;
		// R7	
		tempR7 = org_R[WIDTH * row + col+7   ] - VALUE;
		if (tempR7 < 0)
			DATA_R7 = 0;
		else
			DATA_R7 = org_R[WIDTH * row + col+7   ] - VALUE;	

                


            //FOR GREEN 
                     // G0
		tempG0 = org_G[WIDTH * row + col   ] - VALUE;
		if (tempG0 < 0)
			DATA_G0 = 0;
		else
			DATA_G0 = org_G[WIDTH * row + col   ] - VALUE;
		// G1	
		tempG1 = org_G[WIDTH * row + col+1   ] - VALUE;
		if (tempG1 < 0)
			DATA_G1 = 0;
		else
			DATA_G1 = org_G[WIDTH * row + col+1   ] - VALUE;	
                // G2
		tempG2 = org_G[WIDTH * row + col+2   ] - VALUE;
		if (tempG2 < 0)
			DATA_G2 = 0;
		else
			DATA_G2 = org_G[WIDTH * row + col +2  ] - VALUE;
		// G3	
		tempG3 = org_G[WIDTH * row + col+3   ] - VALUE;
		if (tempG3 < 0)
			DATA_G3 = 0;
		else
			DATA_G3 = org_G[WIDTH * row + col+3   ] - VALUE;	
               // G4
		tempG4 = org_G[WIDTH * row + col+4   ] - VALUE;
		if (tempG4 < 0)
			DATA_G4 = 0;
		else
			DATA_G4 = org_G[WIDTH * row + col+4   ] - VALUE;
		// G5	
		tempG5 = org_G[WIDTH * row + col+5   ] - VALUE;
		if (tempG5 < 0)
			DATA_G5 = 0;
		else
			DATA_G5 = org_G[WIDTH * row + col+5   ] - VALUE;	

                 // G6
		tempG6 = org_G[WIDTH * row + col+6   ] - VALUE;
		if (tempG6 < 0)
			DATA_G6 = 0;
		else
			DATA_G6 = org_G[WIDTH * row + col+6   ] - VALUE;
		// G7	
		tempG7 = org_G[WIDTH * row + col+7   ] - VALUE;
		if (tempG7 < 0)
			DATA_G7 = 0;
		else
			DATA_G7 = org_G[WIDTH * row + col+7   ] - VALUE;	



                   //FOR BLUE


                 // B0
		tempB0 = org_B[WIDTH * row + col   ] - VALUE;
		if (tempB0 < 0)
			DATA_B0 = 0;
		else
			DATA_B0 = org_B[WIDTH * row + col   ] - VALUE;
		// B1	
		tempB1 = org_B[WIDTH * row + col+1   ] - VALUE;
		if (tempB1 < 0)
			DATA_B1 = 0;
		else
			DATA_B1 = org_B[WIDTH * row + col+1   ] - VALUE;	
                // B2
		tempB2 = org_B[WIDTH * row + col+2   ] - VALUE;
		if (tempB2 < 0)
			DATA_B2 = 0;
		else
			DATA_B2 = org_B[WIDTH * row + col +2  ] - VALUE;
		// B3	
		tempB3 = org_B[WIDTH * row + col+3   ] - VALUE;
		if (tempB3 < 0)
			DATA_B3 = 0;
		else
			DATA_B3 = org_B[WIDTH * row + col+3   ] - VALUE;	
               // B4
		tempB4 = org_B[WIDTH * row + col+4   ] - VALUE;
		if (tempB4 < 0)
			DATA_B4 = 0;
		else
			DATA_B4 = org_B[WIDTH * row + col+4   ] - VALUE;
		// B5	
		tempB5 = org_B[WIDTH * row + col+5   ] - VALUE;
		if (tempB5 < 0)
			DATA_B5 = 0;
		else
			DATA_B5 = org_B[WIDTH * row + col+5   ] - VALUE;	

                 // B6
		tempB6 = org_B[WIDTH * row + col+6   ] - VALUE;
		if (tempB6 < 0)
			DATA_B6 = 0;
		else
			DATA_B6 = org_B[WIDTH * row + col+6   ] - VALUE;
		// B7	
		tempB7 = org_B[WIDTH * row + col+7   ] - VALUE;
		if (tempB7 < 0)
			DATA_B7 = 0;
		else
			DATA_B7 = org_B[WIDTH * row + col+7   ] - VALUE;	


		
	end



`endif
	
		/**************************************/		
		/*		INVERT_OPERATION  			  */
		/**************************************/
		`ifdef INVERT_OPERATION	
			//value2 = (org_B[WIDTH * row + col  ] + org_R[WIDTH * row + col  ] +org_G[WIDTH * row + col  ])/3;
			DATA_R0=255-org_R[WIDTH * row + col  ] ;
			DATA_G0=255-org_G[WIDTH * row + col  ];
			DATA_B0=255-org_B[WIDTH * row + col  ];
			//value4 = (org_B[WIDTH * row + col+1  ] + org_R[WIDTH * row + col+1  ] +org_G[WIDTH * row + col+1  ])/3;
			DATA_R1=255-org_R[WIDTH * row + col+1  ];
			DATA_G1=255-org_G[WIDTH * row + col+1  ];
			DATA_B1=255-org_B[WIDTH * row + col+1  ];	
                      

                       DATA_R2=255-org_R[WIDTH * row + col+2  ];
			DATA_G2=255-org_G[WIDTH * row + col+2  ];
			DATA_B2=255-org_B[WIDTH * row + col+2  ];	


                        DATA_R3=255-org_R[WIDTH * row + col+3  ];
			DATA_G3=255-org_G[WIDTH * row + col+3  ];
			DATA_B3=255-org_B[WIDTH * row + col+3  ];	


                        DATA_R4=255-org_R[WIDTH * row + col+4  ];
			DATA_G4=255-org_G[WIDTH * row + col+4  ];
			DATA_B4=255-org_B[WIDTH * row + col+4  ];	



                        DATA_R5=255-org_R[WIDTH * row + col+5  ];
			DATA_G5=255-org_G[WIDTH * row + col+5  ];
			DATA_B5=255-org_B[WIDTH * row + col+5  ];	


                        DATA_R6=255-org_R[WIDTH * row + col+6  ];
			DATA_G6=255-org_G[WIDTH * row + col+6  ];
			DATA_B6=255-org_B[WIDTH * row + col+6  ];	


                        DATA_R7=255-org_R[WIDTH * row + col+7  ];
			DATA_G7=255-org_G[WIDTH * row + col+7  ];
			DATA_B7=255-org_B[WIDTH * row + col+7  ];	




	
		`endif
		
				/**************************************/		
		/*		BLACK & WHITE_OPERATION  			  */
		/**************************************/
		`ifdef BLACKandWHITE_OPERATION	
			value8 = (org_B[WIDTH * row + col  ] + org_R[WIDTH * row + col  ] +org_G[WIDTH * row + col  ])/3;
			DATA_R0=value8;
			DATA_G0=value8;
			DATA_B0=value8;
			value9 = (org_B[WIDTH * row + col+1  ] + org_R[WIDTH * row + col+1  ] +org_G[WIDTH * row + col+1  ])/3;
			DATA_R1=value9;
			DATA_G1=value9;
			DATA_B1=value9;		
                       

                       value10 = (org_B[WIDTH * row + col+2  ] + org_R[WIDTH * row + col+2  ] +org_G[WIDTH * row + col+2  ])/3;
			DATA_R2=value10;
			DATA_G2=value10;
			DATA_B2=value10;
			value11 = (org_B[WIDTH * row + col+3  ] + org_R[WIDTH * row + col+3  ] +org_G[WIDTH * row + col+3  ])/3;
			DATA_R3=value11;
			DATA_G3=value11;
			DATA_B3=value11;		
               

                       value12 = (org_B[WIDTH * row + col+4  ] + org_R[WIDTH * row + col+4  ] +org_G[WIDTH * row + col+4 ])/3;
			DATA_R4=value12;
			DATA_G4=value12;
			DATA_B4=value12;
			value13 = (org_B[WIDTH * row + col+5  ] + org_R[WIDTH * row + col+5  ] +org_G[WIDTH * row + col+5  ])/3;
			DATA_R5=value13;
			DATA_G5=value13;
			DATA_B5=value13;		


                       value14 = (org_B[WIDTH * row + col+6  ] + org_R[WIDTH * row + col+6  ] +org_G[WIDTH * row + col +6 ])/3;
			DATA_R6=value14;
			DATA_G6=value14;
			DATA_B6=value14;
			value15 = (org_B[WIDTH * row + col+7  ] + org_R[WIDTH * row + col+7  ] +org_G[WIDTH * row + col+7  ])/3;
			DATA_R7=value15;
			DATA_G7=value15;
			DATA_B7=value15;		
		`endif
		
		
		/**************************************/		
		/********THRESHOLD OPERATION  *********/
		/**************************************/
		`ifdef THRESHOLD_OPERATION

		value = (org_R[WIDTH * row + col   ]+org_G[WIDTH * row + col   ]+org_B[WIDTH * row + col   ])/3;
		if(value > THRESHOLD) begin
			DATA_R0=255;
			DATA_G0=255;
			DATA_B0=255;
		end
		else begin
			DATA_R0=0;
			DATA_G0=0;
			DATA_B0=0;
		end
		value1 = (org_R[WIDTH * row + col+1   ]+org_G[WIDTH * row + col+1   ]+org_B[WIDTH * row + col+1   ])/3;
		if(value1 > THRESHOLD) begin
			DATA_R1=255;
			DATA_G1=255;
			DATA_B1=255;
		end
		else begin
			DATA_R1=0;
			DATA_G1=0;
			DATA_B1=0;
		end	
                 

                value2 = (org_R[WIDTH * row + col+2   ]+org_G[WIDTH * row + col+2   ]+org_B[WIDTH * row + col+2   ])/3;
		if(value2 > THRESHOLD) begin
			DATA_R2=255;
			DATA_G2=255;
			DATA_B2=255;
		end
		else begin
			DATA_R2=0;
			DATA_G2=0;
			DATA_B2=0;
		end	


                value3 = (org_R[WIDTH * row + col+3   ]+org_G[WIDTH * row + col+3   ]+org_B[WIDTH * row + col+3   ])/3;
		if(value3 > THRESHOLD) begin
			DATA_R3=255;
			DATA_G3=255;
			DATA_B3=255;
		end
		else begin
			DATA_R3=0;
			DATA_G3=0;
			DATA_B3=0;
		end	


                value4 = (org_R[WIDTH * row + col+4   ]+org_G[WIDTH * row + col+4   ]+org_B[WIDTH * row + col+4   ])/3;
		if(value4 > THRESHOLD) begin
			DATA_R4=255;
			DATA_G4=255;
			DATA_B4=255;
		end
		else begin
			DATA_R4=0;
			DATA_G4=0;
			DATA_B4=0;
		end	

                 value5 = (org_R[WIDTH * row + col+5   ]+org_G[WIDTH * row + col+5   ]+org_B[WIDTH * row + col+5   ])/3;
		if(value5 > THRESHOLD) begin
			DATA_R5=255;
			DATA_G5=255;
			DATA_B5=255;
		end
		else begin
			DATA_R5=0;
			DATA_G5=0;
			DATA_B5=0;
		end	


                value6 = (org_R[WIDTH * row + col+6   ]+org_G[WIDTH * row + col+6   ]+org_B[WIDTH * row + col+6   ])/3;
		if(value6 > THRESHOLD) begin
			DATA_R6=255;
			DATA_G6=255;
			DATA_B6=255;
		end
		else begin
			DATA_R6=0;
			DATA_G6=0;
			DATA_B6=0;
		end	

               value7 = (org_R[WIDTH * row + col+7   ]+org_G[WIDTH * row + col+7   ]+org_B[WIDTH * row + col+7   ])/3;
		if(value7 > THRESHOLD) begin
			DATA_R7=255;
			DATA_G7=255;
			DATA_B7=255;
		end
		else begin
			DATA_R7=0;
			DATA_G7=0;
			DATA_B7=0;
		end	

		`endif

		
	end
end


end

//for 16 pixel
else begin

always @(*) begin
    HSYNC   = 1'b0;
    DATA_R0  = 0; DATA_G0  = 0; DATA_B0  = 0;
    DATA_R1  = 0; DATA_G1  = 0; DATA_B1  = 0;
    DATA_R2  = 0; DATA_G2  = 0; DATA_B2  = 0;
    DATA_R3  = 0; DATA_G3  = 0; DATA_B3  = 0;
    DATA_R4  = 0; DATA_G4  = 0; DATA_B4  = 0;
    DATA_R5  = 0; DATA_G5  = 0; DATA_B5  = 0;
    DATA_R6  = 0; DATA_G6  = 0; DATA_B6  = 0;
    DATA_R7  = 0; DATA_G7  = 0; DATA_B7  = 0;
    DATA_R8  = 0; DATA_G8  = 0; DATA_B8  = 0;
    DATA_R9  = 0; DATA_G9  = 0; DATA_B9  = 0;
    DATA_R10 = 0; DATA_G10 = 0; DATA_B10 = 0;
    DATA_R11 = 0; DATA_G11 = 0; DATA_B11 = 0;
    DATA_R12 = 0; DATA_G12 = 0; DATA_B12 = 0;
    DATA_R13 = 0; DATA_G13 = 0; DATA_B13 = 0;
    DATA_R14 = 0; DATA_G14 = 0; DATA_B14 = 0;
    DATA_R15 = 0; DATA_G15 = 0; DATA_B15 = 0;
    
    if (ctrl_data_run) begin
        HSYNC = 1'b1;
        `ifdef BRIGHTNESS_OPERATION    
        /**************************************/        
        /*        BRIGHTNESS ADDITION OPERATION */
        /**************************************/
        if (SIGN == 1) begin
            // FOR RED
            tempR0 = org_R[WIDTH * row + col    ] + VALUE;
            if (tempR0 > 255)
               DATA_R0 = 255; 
            else
               DATA_R0 = org_R[WIDTH * row + col    ] + VALUE;
            tempR1 = org_R[WIDTH * row + col+1  ] + VALUE;
            if (tempR1 > 255) DATA_R1 = 255; else DATA_R1 = org_R[WIDTH * row + col+1  ] + VALUE;
            tempR2 = org_R[WIDTH * row + col+2  ] + VALUE;
            if (tempR2 > 255) DATA_R2 = 255; else DATA_R2 = org_R[WIDTH * row + col+2  ] + VALUE;
            tempR3 = org_R[WIDTH * row + col+3  ] + VALUE;
            if (tempR3 > 255) DATA_R3 = 255; else DATA_R3 = org_R[WIDTH * row + col+3  ] + VALUE;
            tempR4 = org_R[WIDTH * row + col+4  ] + VALUE;
            if (tempR4 > 255) DATA_R4 = 255; else DATA_R4 = org_R[WIDTH * row + col+4  ] + VALUE;
            tempR5 = org_R[WIDTH * row + col+5  ] + VALUE;
            if (tempR5 > 255) DATA_R5 = 255; else DATA_R5 = org_R[WIDTH * row + col+5  ] + VALUE;
            tempR6 = org_R[WIDTH * row + col+6  ] + VALUE;
            if (tempR6 > 255) DATA_R6 = 255; else DATA_R6 = org_R[WIDTH * row + col+6  ] + VALUE;
            tempR7 = org_R[WIDTH * row + col+7  ] + VALUE;
            if (tempR7 > 255) DATA_R7 = 255; else DATA_R7 = org_R[WIDTH * row + col+7  ] + VALUE;
            tempR8 = org_R[WIDTH * row + col+8  ] + VALUE;
            if (tempR8 > 255) DATA_R8 = 255; else DATA_R8 = org_R[WIDTH * row + col+8  ] + VALUE;
            tempR9 = org_R[WIDTH * row + col+9  ] + VALUE;
            if (tempR9 > 255) DATA_R9 = 255; else DATA_R9 = org_R[WIDTH * row + col+9  ] + VALUE;
            tempR10 = org_R[WIDTH * row + col+10] + VALUE;
            if (tempR10 > 255) DATA_R10 = 255; else DATA_R10 = org_R[WIDTH * row + col+10] + VALUE;
            tempR11 = org_R[WIDTH * row + col+11] + VALUE;
            if (tempR11 > 255) DATA_R11 = 255; else DATA_R11 = org_R[WIDTH * row + col+11] + VALUE;
            tempR12 = org_R[WIDTH * row + col+12] + VALUE;
            if (tempR12 > 255) DATA_R12 = 255; else DATA_R12 = org_R[WIDTH * row + col+12] + VALUE;
            tempR13 = org_R[WIDTH * row + col+13] + VALUE;
            if (tempR13 > 255) DATA_R13 = 255; else DATA_R13 = org_R[WIDTH * row + col+13] + VALUE;
            tempR14 = org_R[WIDTH * row + col+14] + VALUE;
            if (tempR14 > 255) DATA_R14 = 255; else DATA_R14 = org_R[WIDTH * row + col+14] + VALUE;
            tempR15 = org_R[WIDTH * row + col+15] + VALUE;
            if (tempR15 > 255) DATA_R15 = 255; else DATA_R15 = org_R[WIDTH * row + col+15] + VALUE;

            // FOR GREEN 
            tempG0 = org_G[WIDTH * row + col    ] + VALUE;
            if (tempG0 > 255) DATA_G0 = 255; else DATA_G0 = org_G[WIDTH * row + col    ] + VALUE;
            tempG1 = org_G[WIDTH * row + col+1  ] + VALUE;
            if (tempG1 > 255) DATA_G1 = 255; else DATA_G1 = org_G[WIDTH * row + col+1  ] + VALUE;
            tempG2 = org_G[WIDTH * row + col+2  ] + VALUE;
            if (tempG2 > 255) DATA_G2 = 255; else DATA_G2 = org_G[WIDTH * row + col+2  ] + VALUE;
            tempG3 = org_G[WIDTH * row + col+3  ] + VALUE;
            if (tempG3 > 255) DATA_G3 = 255; else DATA_G3 = org_G[WIDTH * row + col+3  ] + VALUE;
            tempG4 = org_G[WIDTH * row + col+4  ] + VALUE;
            if (tempG4 > 255) DATA_G4 = 255; else DATA_G4 = org_G[WIDTH * row + col+4  ] + VALUE;
            tempG5 = org_G[WIDTH * row + col+5  ] + VALUE;
            if (tempG5 > 255) DATA_G5 = 255; else DATA_G5 = org_G[WIDTH * row + col+5  ] + VALUE;
            tempG6 = org_G[WIDTH * row + col+6  ] + VALUE;
            if (tempG6 > 255) DATA_G6 = 255; else DATA_G6 = org_G[WIDTH * row + col+6  ] + VALUE;
            tempG7 = org_G[WIDTH * row + col+7  ] + VALUE;
            if (tempG7 > 255) DATA_G7 = 255; else DATA_G7 = org_G[WIDTH * row + col+7  ] + VALUE;
            tempG8 = org_G[WIDTH * row + col+8  ] + VALUE;
            if (tempG8 > 255) DATA_G8 = 255; else DATA_G8 = org_G[WIDTH * row + col+8  ] + VALUE;
            tempG9 = org_G[WIDTH * row + col+9  ] + VALUE;
            if (tempG9 > 255) DATA_G9 = 255; else DATA_G9 = org_G[WIDTH * row + col+9  ] + VALUE;
            tempG10 = org_G[WIDTH * row + col+10] + VALUE;
            if (tempG10 > 255) DATA_G10 = 255; else DATA_G10 = org_G[WIDTH * row + col+10] + VALUE;
            tempG11 = org_G[WIDTH * row + col+11] + VALUE;
            if (tempG11 > 255) DATA_G11 = 255; else DATA_G11 = org_G[WIDTH * row + col+11] + VALUE;
            tempG12 = org_G[WIDTH * row + col+12] + VALUE;
            if (tempG12 > 255) DATA_G12 = 255; else DATA_G12 = org_G[WIDTH * row + col+12] + VALUE;
            tempG13 = org_G[WIDTH * row + col+13] + VALUE;
            if (tempG13 > 255) DATA_G13 = 255; else DATA_G13 = org_G[WIDTH * row + col+13] + VALUE;
            tempG14 = org_G[WIDTH * row + col+14] + VALUE;
            if (tempG14 > 255) DATA_G14 = 255; else DATA_G14 = org_G[WIDTH * row + col+14] + VALUE;
            tempG15 = org_G[WIDTH * row + col+15] + VALUE;
            if (tempG15 > 255) DATA_G15 = 255; else DATA_G15 = org_G[WIDTH * row + col+15] + VALUE;

            // FOR BLUE
            tempB0 = org_B[WIDTH * row + col    ] + VALUE;
            if (tempB0 > 255) DATA_B0 = 255; else DATA_B0 = org_B[WIDTH * row + col    ] + VALUE;
            tempB1 = org_B[WIDTH * row + col+1  ] + VALUE;
            if (tempB1 > 255) DATA_B1 = 255; else DATA_B1 = org_B[WIDTH * row + col+1  ] + VALUE;
            tempB2 = org_B[WIDTH * row + col+2  ] + VALUE;
            if (tempB2 > 255) DATA_B2 = 255; else DATA_B2 = org_B[WIDTH * row + col+2  ] + VALUE;
            tempB3 = org_B[WIDTH * row + col+3  ] + VALUE;
            if (tempB3 > 255) DATA_B3 = 255; else DATA_B3 = org_B[WIDTH * row + col+3  ] + VALUE;
            tempB4 = org_B[WIDTH * row + col+4  ] + VALUE;
            if (tempB4 > 255) DATA_B4 = 255; else DATA_B4 = org_B[WIDTH * row + col+4  ] + VALUE;
            tempB5 = org_B[WIDTH * row + col+5  ] + VALUE;
            if (tempB5 > 255) DATA_B5 = 255; else DATA_B5 = org_B[WIDTH * row + col+5  ] + VALUE;
            tempB6 = org_B[WIDTH * row + col+6  ] + VALUE;
            if (tempB6 > 255) DATA_B6 = 255; else DATA_B6 = org_B[WIDTH * row + col+6  ] + VALUE;
            tempB7 = org_B[WIDTH * row + col+7  ] + VALUE;
            if (tempB7 > 255) DATA_B7 = 255; else DATA_B7 = org_B[WIDTH * row + col+7  ] + VALUE;
            tempB8 = org_B[WIDTH * row + col+8  ] + VALUE;
            if (tempB8 > 255) DATA_B8 = 255; else DATA_B8 = org_B[WIDTH * row + col+8  ] + VALUE;
            tempB9 = org_B[WIDTH * row + col+9  ] + VALUE;
            if (tempB9 > 255) DATA_B9 = 255; else DATA_B9 = org_B[WIDTH * row + col+9  ] + VALUE;
            tempB10 = org_B[WIDTH * row + col+10] + VALUE;
            if (tempB10 > 255) DATA_B10 = 255; else DATA_B10 = org_B[WIDTH * row + col+10] + VALUE;
            tempB11 = org_B[WIDTH * row + col+11] + VALUE;
            if (tempB11 > 255) DATA_B11 = 255; else DATA_B11 = org_B[WIDTH * row + col+11] + VALUE;
            tempB12 = org_B[WIDTH * row + col+12] + VALUE;
            if (tempB12 > 255) DATA_B12 = 255; else DATA_B12 = org_B[WIDTH * row + col+12] + VALUE;
            tempB13 = org_B[WIDTH * row + col+13] + VALUE;
            if (tempB13 > 255) DATA_B13 = 255; else DATA_B13 = org_B[WIDTH * row + col+13] + VALUE;
            tempB14 = org_B[WIDTH * row + col+14] + VALUE;
            if (tempB14 > 255) DATA_B14 = 255; else DATA_B14 = org_B[WIDTH * row + col+14] + VALUE;
            tempB15 = org_B[WIDTH * row + col+15] + VALUE;
            if (tempB15 > 255) DATA_B15 = 255; else DATA_B15 = org_B[WIDTH * row + col+15] + VALUE;
        end
        else begin
        /**************************************/        
        /*    BRIGHTNESS SUBTRACTION OPERATION */
        /**************************************/
            // FOR RED
            tempR0 = org_R[WIDTH * row + col    ] - VALUE;
            if (tempR0 < 0) DATA_R0 = 0; else DATA_R0 = org_R[WIDTH * row + col    ] - VALUE;
            tempR1 = org_R[WIDTH * row + col+1  ] - VALUE;
            if (tempR1 < 0) DATA_R1 = 0; else DATA_R1 = org_R[WIDTH * row + col+1  ] - VALUE;
            tempR2 = org_R[WIDTH * row + col+2  ] - VALUE;
            if (tempR2 < 0) DATA_R2 = 0; else DATA_R2 = org_R[WIDTH * row + col+2  ] - VALUE;
            tempR3 = org_R[WIDTH * row + col+3  ] - VALUE;
            if (tempR3 < 0) DATA_R3 = 0; else DATA_R3 = org_R[WIDTH * row + col+3  ] - VALUE;
            tempR4 = org_R[WIDTH * row + col+4  ] - VALUE;
            if (tempR4 < 0) DATA_R4 = 0; else DATA_R4 = org_R[WIDTH * row + col+4  ] - VALUE;
            tempR5 = org_R[WIDTH * row + col+5  ] - VALUE;
            if (tempR5 < 0) DATA_R5 = 0; else DATA_R5 = org_R[WIDTH * row + col+5  ] - VALUE;
            tempR6 = org_R[WIDTH * row + col+6  ] - VALUE;
            if (tempR6 < 0) DATA_R6 = 0; else DATA_R6 = org_R[WIDTH * row + col+6  ] - VALUE;
            tempR7 = org_R[WIDTH * row + col+7  ] - VALUE;
            if (tempR7 < 0) DATA_R7 = 0; else DATA_R7 = org_R[WIDTH * row + col+7  ] - VALUE;
            tempR8 = org_R[WIDTH * row + col+8  ] - VALUE;
            if (tempR8 < 0) DATA_R8 = 0; else DATA_R8 = org_R[WIDTH * row + col+8  ] - VALUE;
            tempR9 = org_R[WIDTH * row + col+9  ] - VALUE;
            if (tempR9 < 0) DATA_R9 = 0; else DATA_R9 = org_R[WIDTH * row + col+9  ] - VALUE;
            tempR10 = org_R[WIDTH * row + col+10] - VALUE;
            if (tempR10 < 0) DATA_R10 = 0; else DATA_R10 = org_R[WIDTH * row + col+10] - VALUE;
            tempR11 = org_R[WIDTH * row + col+11] - VALUE;
            if (tempR11 < 0) DATA_R11 = 0; else DATA_R11 = org_R[WIDTH * row + col+11] - VALUE;
            tempR12 = org_R[WIDTH * row + col+12] - VALUE;
            if (tempR12 < 0) DATA_R12 = 0; else DATA_R12 = org_R[WIDTH * row + col+12] - VALUE;
            tempR13 = org_R[WIDTH * row + col+13] - VALUE;
            if (tempR13 < 0) DATA_R13 = 0; else DATA_R13 = org_R[WIDTH * row + col+13] - VALUE;
            tempR14 = org_R[WIDTH * row + col+14] - VALUE;
            if (tempR14 < 0) DATA_R14 = 0; else DATA_R14 = org_R[WIDTH * row + col+14] - VALUE;
            tempR15 = org_R[WIDTH * row + col+15] - VALUE;
            if (tempR15 < 0) DATA_R15 = 0; else DATA_R15 = org_R[WIDTH * row + col+15] - VALUE;

            // FOR GREEN 
            tempG0 = org_G[WIDTH * row + col    ] - VALUE;
            if (tempG0 < 0) DATA_G0 = 0; else DATA_G0 = org_G[WIDTH * row + col    ] - VALUE;
            tempG1 = org_G[WIDTH * row + col+1  ] - VALUE;
            if (tempG1 < 0) DATA_G1 = 0; else DATA_G1 = org_G[WIDTH * row + col+1  ] - VALUE;
            tempG2 = org_G[WIDTH * row + col+2  ] - VALUE;
            if (tempG2 < 0) DATA_G2 = 0; else DATA_G2 = org_G[WIDTH * row + col+2  ] - VALUE;
            tempG3 = org_G[WIDTH * row + col+3  ] - VALUE;
            if (tempG3 < 0) DATA_G3 = 0; else DATA_G3 = org_G[WIDTH * row + col+3  ] - VALUE;
            tempG4 = org_G[WIDTH * row + col+4  ] - VALUE;
            if (tempG4 < 0) DATA_G4 = 0; else DATA_G4 = org_G[WIDTH * row + col+4  ] - VALUE;
            tempG5 = org_G[WIDTH * row + col+5  ] - VALUE;
            if (tempG5 < 0) DATA_G5 = 0; else DATA_G5 = org_G[WIDTH * row + col+5  ] - VALUE;
            tempG6 = org_G[WIDTH * row + col+6  ] - VALUE;
            if (tempG6 < 0) DATA_G6 = 0; else DATA_G6 = org_G[WIDTH * row + col+6  ] - VALUE;
            tempG7 = org_G[WIDTH * row + col+7  ] - VALUE;
            if (tempG7 < 0) DATA_G7 = 0; else DATA_G7 = org_G[WIDTH * row + col+7  ] - VALUE;
            tempG8 = org_G[WIDTH * row + col+8  ] - VALUE;
            if (tempG8 < 0) DATA_G8 = 0; else DATA_G8 = org_G[WIDTH * row + col+8  ] - VALUE;
            tempG9 = org_G[WIDTH * row + col+9  ] - VALUE;
            if (tempG9 < 0) DATA_G9 = 0; else DATA_G9 = org_G[WIDTH * row + col+9  ] - VALUE;
            tempG10 = org_G[WIDTH * row + col+10] - VALUE;
            if (tempG10 < 0) DATA_G10 = 0; else DATA_G10 = org_G[WIDTH * row + col+10] - VALUE;
            tempG11 = org_G[WIDTH * row + col+11] - VALUE;
            if (tempG11 < 0) DATA_G11 = 0; else DATA_G11 = org_G[WIDTH * row + col+11] - VALUE;
            tempG12 = org_G[WIDTH * row + col+12] - VALUE;
            if (tempG12 < 0) DATA_G12 = 0; else DATA_G12 = org_G[WIDTH * row + col+12] - VALUE;
            tempG13 = org_G[WIDTH * row + col+13] - VALUE;
            if (tempG13 < 0) DATA_G13 = 0; else DATA_G13 = org_G[WIDTH * row + col+13] - VALUE;
            tempG14 = org_G[WIDTH * row + col+14] - VALUE;
            if (tempG14 < 0) DATA_G14 = 0; else DATA_G14 = org_G[WIDTH * row + col+14] - VALUE;
            tempG15 = org_G[WIDTH * row + col+15] - VALUE;
            if (tempG15 < 0) DATA_G15 = 0; else DATA_G15 = org_G[WIDTH * row + col+15] - VALUE;

            // FOR BLUE
            tempB0 = org_B[WIDTH * row + col    ] - VALUE;
            if (tempB0 < 0) DATA_B0 = 0; else DATA_B0 = org_B[WIDTH * row + col    ] - VALUE;
            tempB1 = org_B[WIDTH * row + col+1  ] - VALUE;
            if (tempB1 < 0) DATA_B1 = 0; else DATA_B1 = org_B[WIDTH * row + col+1  ] - VALUE;
            tempB2 = org_B[WIDTH * row + col+2  ] - VALUE;
            if (tempB2 < 0) DATA_B2 = 0; else DATA_B2 = org_B[WIDTH * row + col+2  ] - VALUE;
            tempB3 = org_B[WIDTH * row + col+3  ] - VALUE;
            if (tempB3 < 0) DATA_B3 = 0; else DATA_B3 = org_B[WIDTH * row + col+3  ] - VALUE;
            tempB4 = org_B[WIDTH * row + col+4  ] - VALUE;
            if (tempB4 < 0) DATA_B4 = 0; else DATA_B4 = org_B[WIDTH * row + col+4  ] - VALUE;
            tempB5 = org_B[WIDTH * row + col+5  ] - VALUE;
            if (tempB5 < 0) DATA_B5 = 0; else DATA_B5 = org_B[WIDTH * row + col+5  ] - VALUE;
            tempB6 = org_B[WIDTH * row + col+6  ] - VALUE;
            if (tempB6 < 0) DATA_B6 = 0; else DATA_B6 = org_B[WIDTH * row + col+6  ] - VALUE;
            tempB7 = org_B[WIDTH * row + col+7  ] - VALUE;
            if (tempB7 < 0) DATA_B7 = 0; else DATA_B7 = org_B[WIDTH * row + col+7  ] - VALUE;
            tempB8 = org_B[WIDTH * row + col+8  ] - VALUE;
            if (tempB8 < 0) DATA_B8 = 0; else DATA_B8 = org_B[WIDTH * row + col+8  ] - VALUE;
            tempB9 = org_B[WIDTH * row + col+9  ] - VALUE;
            if (tempB9 < 0) DATA_B9 = 0; else DATA_B9 = org_B[WIDTH * row + col+9  ] - VALUE;
            tempB10 = org_B[WIDTH * row + col+10] - VALUE;
            if (tempB10 < 0) DATA_B10 = 0; else DATA_B10 = org_B[WIDTH * row + col+10] - VALUE;
            tempB11 = org_B[WIDTH * row + col+11] - VALUE;
            if (tempB11 < 0) DATA_B11 = 0; else DATA_B11 = org_B[WIDTH * row + col+11] - VALUE;
            tempB12 = org_B[WIDTH * row + col+12] - VALUE;
            if (tempB12 < 0) DATA_B12 = 0; else DATA_B12 = org_B[WIDTH * row + col+12] - VALUE;
            tempB13 = org_B[WIDTH * row + col+13] - VALUE;
            if (tempB13 < 0) DATA_B13 = 0; else DATA_B13 = org_B[WIDTH * row + col+13] - VALUE;
            tempB14 = org_B[WIDTH * row + col+14] - VALUE;
            if (tempB14 < 0) DATA_B14 = 0; else DATA_B14 = org_B[WIDTH * row + col+14] - VALUE;
            tempB15 = org_B[WIDTH * row + col+15] - VALUE;
            if (tempB15 < 0) DATA_B15 = 0; else DATA_B15 = org_B[WIDTH * row + col+15] - VALUE;
        end
        `endif
    
        /**************************************/        
        /*        INVERT_OPERATION             */
        /**************************************/
        `ifdef INVERT_OPERATION    
            DATA_R0  = 255 - org_R[WIDTH * row + col    ];
            DATA_G0  = 255 - org_G[WIDTH * row + col    ];
            DATA_B0  = 255 - org_B[WIDTH * row + col    ];
            DATA_R1  = 255 - org_R[WIDTH * row + col+1  ];
            DATA_G1  = 255 - org_G[WIDTH * row + col+1  ];
            DATA_B1  = 255 - org_B[WIDTH * row + col+1  ];
            DATA_R2  = 255 - org_R[WIDTH * row + col+2  ];
            DATA_G2  = 255 - org_G[WIDTH * row + col+2  ];
            DATA_B2  = 255 - org_B[WIDTH * row + col+2  ];
            DATA_R3  = 255 - org_R[WIDTH * row + col+3  ];
            DATA_G3  = 255 - org_G[WIDTH * row + col+3  ];
            DATA_B3  = 255 - org_B[WIDTH * row + col+3  ];
            DATA_R4  = 255 - org_R[WIDTH * row + col+4  ];
            DATA_G4  = 255 - org_G[WIDTH * row + col+4  ];
            DATA_B4  = 255 - org_B[WIDTH * row + col+4  ];
            DATA_R5  = 255 - org_R[WIDTH * row + col+5  ];
            DATA_G5  = 255 - org_G[WIDTH * row + col+5  ];
            DATA_B5  = 255 - org_B[WIDTH * row + col+5  ];
            DATA_R6  = 255 - org_R[WIDTH * row + col+6  ];
            DATA_G6  = 255 - org_G[WIDTH * row + col+6  ];
            DATA_B6  = 255 - org_B[WIDTH * row + col+6  ];
            DATA_R7  = 255 - org_R[WIDTH * row + col+7  ];
            DATA_G7  = 255 - org_G[WIDTH * row + col+7  ];
            DATA_B7  = 255 - org_B[WIDTH * row + col+7  ];
            DATA_R8  = 255 - org_R[WIDTH * row + col+8  ];
            DATA_G8  = 255 - org_G[WIDTH * row + col+8  ];
            DATA_B8  = 255 - org_B[WIDTH * row + col+8  ];
            DATA_R9  = 255 - org_R[WIDTH * row + col+9  ];
            DATA_G9  = 255 - org_G[WIDTH * row + col+9  ];
            DATA_B9  = 255 - org_B[WIDTH * row + col+9  ];
            DATA_R10 = 255 - org_R[WIDTH * row + col+10];
            DATA_G10 = 255 - org_G[WIDTH * row + col+10];
            DATA_B10 = 255 - org_B[WIDTH * row + col+10];
            DATA_R11 = 255 - org_R[WIDTH * row + col+11];
            DATA_G11 = 255 - org_G[WIDTH * row + col+11];
            DATA_B11 = 255 - org_B[WIDTH * row + col+11];
            DATA_R12 = 255 - org_R[WIDTH * row + col+12];
            DATA_G12 = 255 - org_G[WIDTH * row + col+12];
            DATA_B12 = 255 - org_B[WIDTH * row + col+12];
            DATA_R13 = 255 - org_R[WIDTH * row + col+13];
            DATA_G13 = 255 - org_G[WIDTH * row + col+13];
            DATA_B13 = 255 - org_B[WIDTH * row + col+13];
            DATA_R14 = 255 - org_R[WIDTH * row + col+14];
            DATA_G14 = 255 - org_G[WIDTH * row + col+14];
            DATA_B14 = 255 - org_B[WIDTH * row + col+14];
            DATA_R15 = 255 - org_R[WIDTH * row + col+15];
            DATA_G15 = 255 - org_G[WIDTH * row + col+15];
            DATA_B15 = 255 - org_B[WIDTH * row + col+15];
        `endif
        
        /**************************************/        
        /*        BLACK & WHITE_OPERATION      */
        /**************************************/
        `ifdef BLACKandWHITE_OPERATION    
            value8  = (org_B[WIDTH * row + col    ] + org_R[WIDTH * row + col    ] + org_G[WIDTH * row + col    ])/3;
            DATA_R0 = value8; DATA_G0 = value8; DATA_B0 = value8;
            value9  = (org_B[WIDTH * row + col+1  ] + org_R[WIDTH * row + col+1  ] + org_G[WIDTH * row + col+1  ])/3;
            DATA_R1 = value9; DATA_G1 = value9; DATA_B1 = value9;
            value10 = (org_B[WIDTH * row + col+2  ] + org_R[WIDTH * row + col+2  ] + org_G[WIDTH * row + col+2  ])/3;
            DATA_R2 = value10; DATA_G2 = value10; DATA_B2 = value10;
            value11 = (org_B[WIDTH * row + col+3  ] + org_R[WIDTH * row + col+3  ] + org_G[WIDTH * row + col+3  ])/3;
            DATA_R3 = value11; DATA_G3 = value11; DATA_B3 = value11; // Fixed from R4, G4, B4
            value12 = (org_B[WIDTH * row + col+4  ] + org_R[WIDTH * row + col+4  ] + org_G[WIDTH * row + col+4  ])/3;
            DATA_R4 = value12; DATA_G4 = value12; DATA_B4 = value12; // Fixed from R5, G5, B5
            value13 = (org_B[WIDTH * row + col+5  ] + org_R[WIDTH * row + col+5  ] + org_G[WIDTH * row + col+5  ])/3;
            DATA_R5 = value13; DATA_G5 = value13; DATA_B5 = value13; // Fixed from R6, G6, B6
            value14 = (org_B[WIDTH * row + col+6  ] + org_R[WIDTH * row + col+6  ] + org_G[WIDTH * row + col+6  ])/3;
            DATA_R6 = value14; DATA_G6 = value14; DATA_B6 = value14; // Fixed from R7, G7, B7
            value15 = (org_B[WIDTH * row + col+7  ] + org_R[WIDTH * row + col+7  ] + org_G[WIDTH * row + col+7  ])/3;
            DATA_R7 = value15; DATA_G7 = value15; DATA_B7 = value15; // Fixed from duplicate R7, G7, B7
            value16 = (org_B[WIDTH * row + col+8  ] + org_R[WIDTH * row + col+8  ] + org_G[WIDTH * row + col+8  ])/3;
            DATA_R8 = value16; DATA_G8 = value16; DATA_B8 = value16;
            value17 = (org_B[WIDTH * row + col+9  ] + org_R[WIDTH * row + col+9  ] + org_G[WIDTH * row + col+9  ])/3;
            DATA_R9 = value17; DATA_G9 = value17; DATA_B9 = value17;
            value18 = (org_B[WIDTH * row + col+10 ] + org_R[WIDTH * row + col+10 ] + org_G[WIDTH * row + col+10 ])/3;
            DATA_R10 = value18; DATA_G10 = value18; DATA_B10 = value18;
            value19 = (org_B[WIDTH * row + col+11 ] + org_R[WIDTH * row + col+11 ] + org_G[WIDTH * row + col+11 ])/3;
            DATA_R11 = value19; DATA_G11 = value19; DATA_B11 = value19;
            value20 = (org_B[WIDTH * row + col+12 ] + org_R[WIDTH * row + col+12 ] + org_G[WIDTH * row + col+12 ])/3;
            DATA_R12 = value20; DATA_G12 = value20; DATA_B12 = value20;
            value21 = (org_B[WIDTH * row + col+13 ] + org_R[WIDTH * row + col+13 ] + org_G[WIDTH * row + col+13 ])/3;
            DATA_R13 = value21; DATA_G13 = value21; DATA_B13 = value21;
            value22 = (org_B[WIDTH * row + col+14 ] + org_R[WIDTH * row + col+14 ] + org_G[WIDTH * row + col+14 ])/3;
            DATA_R14 = value22; DATA_G14 = value22; DATA_B14 = value22;
            value23 = (org_B[WIDTH * row + col+15 ] + org_R[WIDTH * row + col+15 ] + org_G[WIDTH * row + col+15 ])/3;
            DATA_R15 = value23; DATA_G15 = value23; DATA_B15 = value23;
        `endif
        
        /**************************************/        
        /********THRESHOLD OPERATION  *********/
        /**************************************/
        `ifdef THRESHOLD_OPERATION
            value = (org_R[WIDTH * row + col    ] + org_G[WIDTH * row + col    ] + org_B[WIDTH * row + col    ])/3;
            if (value > THRESHOLD) begin DATA_R0 = 255; DATA_G0 = 255; DATA_B0 = 255; end else begin DATA_R0 = 0; DATA_G0 = 0; DATA_B0 = 0; end
            value1 = (org_R[WIDTH * row + col+1 ] + org_G[WIDTH * row + col+1 ] + org_B[WIDTH * row + col+1 ])/3;
            if (value1 > THRESHOLD) begin DATA_R1 = 255; DATA_G1 = 255; DATA_B1 = 255; end else begin DATA_R1 = 0; DATA_G1 = 0; DATA_B1 = 0; end
            value2 = (org_R[WIDTH * row + col+2 ] + org_G[WIDTH * row + col+2 ] + org_B[WIDTH * row + col+2 ])/3;
            if (value2 > THRESHOLD) begin DATA_R2 = 255; DATA_G2 = 255; DATA_B2 = 255; end else begin DATA_R2 = 0; DATA_G2 = 0; DATA_B2 = 0; end
            value3 = (org_R[WIDTH * row + col+3 ] + org_G[WIDTH * row + col+3 ] + org_B[WIDTH * row + col+3 ])/3;
            if (value3 > THRESHOLD) begin DATA_R3 = 255; DATA_G3 = 255; DATA_B3 = 255; end else begin DATA_R3 = 0; DATA_G3 = 0; DATA_B3 = 0; end
            value4 = (org_R[WIDTH * row + col+4 ] + org_G[WIDTH * row + col+4 ] + org_B[WIDTH * row + col+4 ])/3;
            if (value4 > THRESHOLD) begin DATA_R4 = 255; DATA_G4 = 255; DATA_B4 = 255; end else begin DATA_R4 = 0; DATA_G4 = 0; DATA_B4 = 0; end
            value5 = (org_R[WIDTH * row + col+5 ] + org_G[WIDTH * row + col+5 ] + org_B[WIDTH * row + col+5 ])/3;
            if (value5 > THRESHOLD) begin DATA_R5 = 255; DATA_G5 = 255; DATA_B5 = 255; end else begin DATA_R5 = 0; DATA_G5 = 0; DATA_B5 = 0; end
            value6 = (org_R[WIDTH * row + col+6 ] + org_G[WIDTH * row + col+6 ] + org_B[WIDTH * row + col+6 ])/3;
            if (value6 > THRESHOLD) begin DATA_R6 = 255; DATA_G6 = 255; DATA_B6 = 255; end else begin DATA_R6 = 0; DATA_G6 = 0; DATA_B6 = 0; end
            value7 = (org_R[WIDTH * row + col+7 ] + org_G[WIDTH * row + col+7 ] + org_B[WIDTH * row + col+7 ])/3;
            if (value7 > THRESHOLD) begin DATA_R7 = 255; DATA_G7 = 255; DATA_B7 = 255; end else begin DATA_R7 = 0; DATA_G7 = 0; DATA_B7 = 0; end
            value8 = (org_R[WIDTH * row + col+8 ] + org_G[WIDTH * row + col+8 ] + org_B[WIDTH * row + col+8 ])/3;
            if (value8 > THRESHOLD) begin DATA_R8 = 255; DATA_G8 = 255; DATA_B8 = 255; end else begin DATA_R8 = 0; DATA_G8 = 0; DATA_B8 = 0; end
            value9 = (org_R[WIDTH * row + col+9 ] + org_G[WIDTH * row + col+9 ] + org_B[WIDTH * row + col+9 ])/3;
            if (value9 > THRESHOLD) begin DATA_R9 = 255; DATA_G9 = 255; DATA_B9 = 255; end else begin DATA_R9 = 0; DATA_G9 = 0; DATA_B9 = 0; end
            value10 = (org_R[WIDTH * row + col+10] + org_G[WIDTH * row + col+10] + org_B[WIDTH * row + col+10])/3;
            if (value10 > THRESHOLD) begin DATA_R10 = 255; DATA_G10 = 255; DATA_B10 = 255; end else begin DATA_R10 = 0; DATA_G10 = 0; DATA_B10 = 0; end
            value11 = (org_R[WIDTH * row + col+11] + org_G[WIDTH * row + col+11] + org_B[WIDTH * row + col+11])/3;
            if (value11 > THRESHOLD) begin DATA_R11 = 255; DATA_G11 = 255; DATA_B11 = 255; end else begin DATA_R11 = 0; DATA_G11 = 0; DATA_B11 = 0; end
            value12 = (org_R[WIDTH * row + col+12] + org_G[WIDTH * row + col+12] + org_B[WIDTH * row + col+12])/3;
            if (value12 > THRESHOLD) begin DATA_R12 = 255; DATA_G12 = 255; DATA_B12 = 255; end else begin DATA_R12 = 0; DATA_G12 = 0; DATA_B12 = 0; end
            value13 = (org_R[WIDTH * row + col+13] + org_G[WIDTH * row + col+13] + org_B[WIDTH * row + col+13])/3;
            if (value13 > THRESHOLD) begin DATA_R13 = 255; DATA_G13 = 255; DATA_B13 = 255; end else begin DATA_R13 = 0; DATA_G13 = 0; DATA_B13 = 0; end
            value14 = (org_R[WIDTH * row + col+14] + org_G[WIDTH * row + col+14] + org_B[WIDTH * row + col+14])/3;
            if (value14 > THRESHOLD) begin DATA_R14 = 255; DATA_G14 = 255; DATA_B14 = 255; end else begin DATA_R14 = 0; DATA_G14 = 0; DATA_B14 = 0; end
            value15 = (org_R[WIDTH * row + col+15] + org_G[WIDTH * row + col+15] + org_B[WIDTH * row + col+15])/3;
            if (value15 > THRESHOLD) begin DATA_R15 = 255; DATA_G15 = 255; DATA_B15 = 255; end else begin DATA_R15 = 0; DATA_G15 = 0; DATA_B15 = 0; end
        `endif
    end
end




end


endmodule


