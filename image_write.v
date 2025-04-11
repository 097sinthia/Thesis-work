module image_write
#(parameter      WIDTH 	= 768,							// Image width
			HEIGHT 	= 512,								// Image height
			INFILE  = "output.bmp",	
                        NUM_OF_PIXEL = 8,		  // Output image
			BMP_HEADER_NUM = 54							// Header for bmp image
)
(
    input HCLK,                     // Clock (20ns period)
    input HRESETn,                  // Reset active low
    input hsync,                    // Hsync pulse
    input [7:0] DATA_WRITE_R0,      // Red data for pixel 0
    input [7:0] DATA_WRITE_G0,      // Green data for pixel 0
    input [7:0] DATA_WRITE_B0,      // Blue data for pixel 0
    input [7:0] DATA_WRITE_R1,      // Red data for pixel 1
    input [7:0] DATA_WRITE_G1,      // Green data for pixel 1
    input [7:0] DATA_WRITE_B1,      // Blue data for pixel 1
    input [7:0] DATA_WRITE_R2,      // Red data for pixel 2
    input [7:0] DATA_WRITE_G2,      // Green data for pixel 2
    input [7:0] DATA_WRITE_B2,      // Blue data for pixel 2
    input [7:0] DATA_WRITE_R3,      // Red data for pixel 3
    input [7:0] DATA_WRITE_G3,      // Green data for pixel 3
    input [7:0] DATA_WRITE_B3,      // Blue data for pixel 3
    input [7:0] DATA_WRITE_R4,      // Red data for pixel 4
    input [7:0] DATA_WRITE_G4,      // Green data for pixel 4
    input [7:0] DATA_WRITE_B4,      // Blue data for pixel 4
    input [7:0] DATA_WRITE_R5,      // Red data for pixel 5
    input [7:0] DATA_WRITE_G5,      // Green data for pixel 5
    input [7:0] DATA_WRITE_B5,      // Blue data for pixel 5
    input [7:0] DATA_WRITE_R6,      // Red data for pixel 6
    input [7:0] DATA_WRITE_G6,      // Green data for pixel 6
    input [7:0] DATA_WRITE_B6,      // Blue data for pixel 6
    input [7:0] DATA_WRITE_R7,      // Red data for pixel 7
    input [7:0] DATA_WRITE_G7,      // Green data for pixel 7
    input [7:0] DATA_WRITE_B7,      // Blue data for pixel 7
    input [7:0] DATA_WRITE_R8,      // Red data for pixel 8
    input [7:0] DATA_WRITE_G8,      // Green data for pixel 8
    input [7:0] DATA_WRITE_B8,      // Blue data for pixel 8
    input [7:0] DATA_WRITE_R9,      // Red data for pixel 9
    input [7:0] DATA_WRITE_G9,      // Green data for pixel 9
    input [7:0] DATA_WRITE_B9,      // Blue data for pixel 9
    input [7:0] DATA_WRITE_R10,     // Red data for pixel 10
    input [7:0] DATA_WRITE_G10,     // Green data for pixel 10
    input [7:0] DATA_WRITE_B10,     // Blue data for pixel 10
    input [7:0] DATA_WRITE_R11,     // Red data for pixel 11
    input [7:0] DATA_WRITE_G11,     // Green data for pixel 11
    input [7:0] DATA_WRITE_B11,     // Blue data for pixel 11
    input [7:0] DATA_WRITE_R12,     // Red data for pixel 12
    input [7:0] DATA_WRITE_G12,     // Green data for pixel 12
    input [7:0] DATA_WRITE_B12,     // Blue data for pixel 12
    input [7:0] DATA_WRITE_R13,     // Red data for pixel 13
    input [7:0] DATA_WRITE_G13,     // Green data for pixel 13
    input [7:0] DATA_WRITE_B13,     // Blue data for pixel 13
    input [7:0] DATA_WRITE_R14,     // Red data for pixel 14
    input [7:0] DATA_WRITE_G14,     // Green data for pixel 14
    input [7:0] DATA_WRITE_B14,     // Blue data for pixel 14
    input [7:0] DATA_WRITE_R15,     // Red data for pixel 15
    input [7:0] DATA_WRITE_G15,     // Green data for pixel 15
    input [7:0] DATA_WRITE_B15,     // Blue data for pixel 15
    output reg Write_Done           // Done flag
);	
integer BMP_header [0 : BMP_HEADER_NUM - 1];		// BMP header
reg [7:0] out_BMP  [0 : WIDTH*HEIGHT*3 - 1];		// Temporary memory for image
reg [18:0] data_count;									// Counting data
wire done;													// done flag
// counting variables
integer i;
integer k, l, m,wid;
integer fd; 


//-------Header data for bmp image--------------------------//
// Windows BMP files begin with a 54-byte header: 
initial begin
	BMP_header[ 0] = 66;BMP_header[28] =24;
	BMP_header[ 1] = 77;BMP_header[29] = 0;
	BMP_header[ 2] = 54;BMP_header[30] = 0;
	BMP_header[ 3] =  0;BMP_header[31] = 0;
	BMP_header[ 4] = 18;BMP_header[32] = 0;
	BMP_header[ 5] =  0;BMP_header[33] = 0;
	BMP_header[ 6] =  0;BMP_header[34] = 0;
	BMP_header[ 7] =  0;BMP_header[35] = 0;
	BMP_header[ 8] =  0;BMP_header[36] = 0;
	BMP_header[ 9] =  0;BMP_header[37] = 0;
	BMP_header[10] = 54;BMP_header[38] = 0;
	BMP_header[11] =  0;BMP_header[39] = 0;
	BMP_header[12] =  0;BMP_header[40] = 0;
	BMP_header[13] =  0;BMP_header[41] = 0;
	BMP_header[14] = 40;BMP_header[42] = 0;
	BMP_header[15] =  0;BMP_header[43] = 0;
	BMP_header[16] =  0;BMP_header[44] = 0;
	BMP_header[17] =  0;BMP_header[45] = 0;
	BMP_header[18] =  0;BMP_header[46] = 0;
	BMP_header[19] =  3;BMP_header[47] = 0;
	BMP_header[20] =  0;BMP_header[48] = 0;
	BMP_header[21] =  0;BMP_header[49] = 0;
	BMP_header[22] =  0;BMP_header[50] = 0;
	BMP_header[23] =  2;BMP_header[51] = 0;	
	BMP_header[24] =  0;BMP_header[52] = 0;
	BMP_header[25] =  0;BMP_header[53] = 0;
	BMP_header[26] =  1;
	BMP_header[27] =  0;
end
// row and column counting for temporary memory of image 
/*
if(NUM_OF_PIXEL ==1)begin
 wid = WIDTH/1;

end

else if(NUM_OF_PIXEL ==2)begin
 wid = WIDTH/2;

end

else if(NUM_OF_PIXEL ==4)begin
 wid = WIDTH/4;

end

else if(NUM_OF_PIXEL ==8)begin
 wid = WIDTH/8;

end
else begin
 wid = WIDTH/16;

end
*/

 //for 1 pixel

if(NUM_OF_PIXEL ==1)begin
always@(posedge HCLK, negedge HRESETn) begin
    if(!HRESETn) begin
        l <= 0;
        m <= 0;
    end else begin
        if(hsync) begin
            if(m == WIDTH/1-1) begin
                m <= 0;
                l <= l + 1; // count to obtain row index of the out_BMP temporary memory to save image data
            end else begin
                m <= m + 1; // count to obtain column index of the out_BMP temporary memory to save image data
            end
        end
    end
end
end

//for 2 pixels
else if(NUM_OF_PIXEL ==2)begin
always@(posedge HCLK, negedge HRESETn) begin
    if(!HRESETn) begin
        l <= 0;
        m <= 0;
    end else begin
        if(hsync) begin
            if(m == WIDTH/2-1) begin
                m <= 0;
                l <= l + 1; // count to obtain row index of the out_BMP temporary memory to save image data
            end else begin
                m <= m + 1; // count to obtain column index of the out_BMP temporary memory to save image data
            end
        end
    end
end

end

//for 4 pixels
else if(NUM_OF_PIXEL ==4)begin
always@(posedge HCLK, negedge HRESETn) begin
    if(!HRESETn) begin
        l <= 0;
        m <= 0;
    end else begin
        if(hsync) begin
            if(m == WIDTH/4-1) begin
                m <= 0;
                l <= l + 1; // count to obtain row index of the out_BMP temporary memory to save image data
            end else begin
                m <= m + 1; // count to obtain column index of the out_BMP temporary memory to save image data
            end
        end
    end
end

end

//for 8 pixels

else if(NUM_OF_PIXEL == 8)begin
always@(posedge HCLK, negedge HRESETn) begin
    if(!HRESETn) begin
        l <= 0;
        m <= 0;
    end else begin
        if(hsync) begin
            if(m == WIDTH/8-1) begin
                m <= 0;
                l <= l + 1; // count to obtain row index of the out_BMP temporary memory to save image data
            end else begin
                m <= m + 1; // count to obtain column index of the out_BMP temporary memory to save image data
            end
        end
    end
end

end

//16 pixels
else begin
 always@(posedge HCLK, negedge HRESETn) begin
    if(!HRESETn) begin
        l <= 0;
        m <= 0;
    end else begin
        if(hsync) begin
            if(m == WIDTH/16 -1) begin
                m <= 0;
                l <= l + 1; // count to obtain row index of the out_BMP temporary memory to save image data
            end else begin
                m <= m + 1; // count to obtain column index of the out_BMP temporary memory to save image data
            end
        end
    end
end

end





// Writing RGB888 even and odd data to the temp memory

//for 1 pixel
if(NUM_OF_PIXEL ==1)begin
 always @(posedge HCLK, negedge HRESETn) begin
    if (!HRESETn) begin
        for (k = 0; k < WIDTH * HEIGHT * 3; k = k + 1) begin
            out_BMP[k] <= 0;
        end
    end else begin
        if (hsync) begin
            // Write the current pixel data to the temporary memory
            out_BMP[WIDTH * 3 * (HEIGHT - l - 1) + 3 * m + 2] <= DATA_WRITE_R0; // Red
            out_BMP[WIDTH * 3 * (HEIGHT - l - 1) + 3 * m + 1] <= DATA_WRITE_G0; // Green
            out_BMP[WIDTH * 3 * (HEIGHT - l - 1) + 3 * m] <= DATA_WRITE_B0; // Blue
        end
    end
end

end

//for 2 pixel
else if(NUM_OF_PIXEL ==2)begin
 always@(posedge HCLK, negedge HRESETn) begin
    if(!HRESETn) begin
        for(k=0;k<WIDTH*HEIGHT*3;k=k+1) begin
            out_BMP[k] <= 0;
        end
    end else begin
        if(hsync) begin
            out_BMP[WIDTH*3*(HEIGHT-l-1)+6*m+2] <= DATA_WRITE_R0;
            out_BMP[WIDTH*3*(HEIGHT-l-1)+6*m+1] <= DATA_WRITE_G0;
            out_BMP[WIDTH*3*(HEIGHT-l-1)+6*m  ] <= DATA_WRITE_B0;
            out_BMP[WIDTH*3*(HEIGHT-l-1)+6*m+5] <= DATA_WRITE_R1;
            out_BMP[WIDTH*3*(HEIGHT-l-1)+6*m+4] <= DATA_WRITE_G1;
            out_BMP[WIDTH*3*(HEIGHT-l-1)+6*m+3] <= DATA_WRITE_B1;
        end
    end
end

end



//for 4 pixels
else if(NUM_OF_PIXEL ==4)begin
always @(posedge HCLK, negedge HRESETn) begin
    if (!HRESETn) begin
        for (k = 0; k < WIDTH*HEIGHT*3; k = k + 1) begin
            out_BMP[k] <= 0;
        end
    //end else if (hsync) begin
      end else begin
        if(hsync) begin
        // Store 8 pixels (24 bytes) per cycle
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  0] <= DATA_WRITE_B0;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  1] <= DATA_WRITE_G0;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  2] <= DATA_WRITE_R0;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  3] <= DATA_WRITE_B1;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  4] <= DATA_WRITE_G1;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  5] <= DATA_WRITE_R1;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  6] <= DATA_WRITE_B2;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  7] <= DATA_WRITE_G2;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  8] <= DATA_WRITE_R2;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m +  9] <= DATA_WRITE_B3;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m + 10] <= DATA_WRITE_G3;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 12*m + 11] <= DATA_WRITE_R3;
           end
end

end
 
end


//for 8 pixels
else if(NUM_OF_PIXEL ==8)begin

always @(posedge HCLK, negedge HRESETn) begin
    if (!HRESETn) begin
        for (k = 0; k < WIDTH*HEIGHT*3; k = k + 1) begin
            out_BMP[k] <= 0;
        end
    //end else if (hsync) begin
      end else begin
        if(hsync) begin
        // Store 8 pixels (24 bytes) per cycle
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  0] <= DATA_WRITE_B0;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  1] <= DATA_WRITE_G0;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  2] <= DATA_WRITE_R0;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  3] <= DATA_WRITE_B1;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  4] <= DATA_WRITE_G1;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  5] <= DATA_WRITE_R1;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  6] <= DATA_WRITE_B2;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  7] <= DATA_WRITE_G2;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  8] <= DATA_WRITE_R2;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m +  9] <= DATA_WRITE_B3;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 10] <= DATA_WRITE_G3;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 11] <= DATA_WRITE_R3;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 12] <= DATA_WRITE_B4;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 13] <= DATA_WRITE_G4;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 14] <= DATA_WRITE_R4;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 15] <= DATA_WRITE_B5;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 16] <= DATA_WRITE_G5;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 17] <= DATA_WRITE_R5;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 18] <= DATA_WRITE_B6;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 19] <= DATA_WRITE_G6;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 20] <= DATA_WRITE_R6;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 21] <= DATA_WRITE_B7;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 22] <= DATA_WRITE_G7;
        out_BMP[WIDTH*3*(HEIGHT-l-1) + 24*m + 23] <= DATA_WRITE_R7;
    end
end

end

 
end


//for 16 pixels
else begin
always @(posedge HCLK, negedge HRESETn) begin
    if (!HRESETn) begin
        for (k = 0; k < WIDTH*HEIGHT*3; k = k + 1) begin
            out_BMP[k] <= 0;
        end
    end else begin
        if (hsync) begin
            // Store 16 pixels (48 bytes) per cycle in BGR order
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  0] <= DATA_WRITE_B0;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  1] <= DATA_WRITE_G0;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  2] <= DATA_WRITE_R0;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  3] <= DATA_WRITE_B1;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  4] <= DATA_WRITE_G1;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  5] <= DATA_WRITE_R1;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  6] <= DATA_WRITE_B2;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  7] <= DATA_WRITE_G2;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  8] <= DATA_WRITE_R2;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m +  9] <= DATA_WRITE_B3;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 10] <= DATA_WRITE_G3;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 11] <= DATA_WRITE_R3;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 12] <= DATA_WRITE_B4;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 13] <= DATA_WRITE_G4;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 14] <= DATA_WRITE_R4;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 15] <= DATA_WRITE_B5;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 16] <= DATA_WRITE_G5;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 17] <= DATA_WRITE_R5;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 18] <= DATA_WRITE_B6;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 19] <= DATA_WRITE_G6;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 20] <= DATA_WRITE_R6;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 21] <= DATA_WRITE_B7;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 22] <= DATA_WRITE_G7;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 23] <= DATA_WRITE_R7;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 24] <= DATA_WRITE_B8;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 25] <= DATA_WRITE_G8;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 26] <= DATA_WRITE_R8;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 27] <= DATA_WRITE_B9;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 28] <= DATA_WRITE_G9;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 29] <= DATA_WRITE_R9;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 30] <= DATA_WRITE_B10;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 31] <= DATA_WRITE_G10;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 32] <= DATA_WRITE_R10;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 33] <= DATA_WRITE_B11;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 34] <= DATA_WRITE_G11;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 35] <= DATA_WRITE_R11;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 36] <= DATA_WRITE_B12;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 37] <= DATA_WRITE_G12;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 38] <= DATA_WRITE_R12;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 39] <= DATA_WRITE_B13;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 40] <= DATA_WRITE_G13;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 41] <= DATA_WRITE_R13;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 42] <= DATA_WRITE_B14;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 43] <= DATA_WRITE_G14;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 44] <= DATA_WRITE_R14;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 45] <= DATA_WRITE_B15;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 46] <= DATA_WRITE_G15;
            out_BMP[WIDTH*3*(HEIGHT-l-1) + 48*m + 47] <= DATA_WRITE_R15;
        end
    end
end

 

end


// data counting
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        data_count <= 0;
    end
    else begin
        if(hsync)
		data_count <= data_count + 1; // pixels counting for create done flag
    end
end

//1
if(NUM_OF_PIXEL ==1)begin
 assign done = (data_count == 393215)? 1'b1: 1'b0; 

end
//2
else if(NUM_OF_PIXEL ==2)begin
 assign done = (data_count == 196607)? 1'b1: 1'b0; 

end
//4
else if(NUM_OF_PIXEL ==4)begin
 assign done = (data_count == 98303)? 1'b1: 1'b0; 

end
//8
else if(NUM_OF_PIXEL ==8)begin
 assign done = (data_count == 49151)? 1'b1: 1'b0; 

end
//16
else begin
 assign done = (data_count == 24575)? 1'b1: 1'b0; 

end
//assign done = (data_count == 196607)? 1'b1: 1'b0; // done flag once all pixels were processed
always@(posedge HCLK, negedge HRESETn)
begin
    if(~HRESETn) begin
        Write_Done <= 0;
    end
    else begin
		Write_Done <= done;
    end
end


//--------------Write .bmp file		----------------------//
initial begin
    fd = $fopen(INFILE, "wb+");
end
always@(Write_Done) begin // once the processing was done, bmp image will be created
    if(Write_Done == 1'b1) begin
        for(i=0; i<BMP_HEADER_NUM; i=i+1) begin
            $fwrite(fd, "%c", BMP_header[i][7:0]); // write the header
        end

 if(NUM_OF_PIXEL ==1)begin
 
for(i=0; i<WIDTH*HEIGHT*3; i=i+3) begin
		// write R0B0G0 and R1B1G1 (6 bytes) in a loop
            $fwrite(fd, "%c", out_BMP[i  ][7:0]);
            $fwrite(fd, "%c", out_BMP[i+1][7:0]);
            $fwrite(fd, "%c", out_BMP[i+2][7:0]);
         end
end

else if(NUM_OF_PIXEL ==2)begin
  for(i=0; i<WIDTH*HEIGHT*3; i=i+6) begin
		// write R0B0G0 and R1B1G1 (6 bytes) in a loop
            $fwrite(fd, "%c", out_BMP[i  ][7:0]);
            $fwrite(fd, "%c", out_BMP[i+1][7:0]);
            $fwrite(fd, "%c", out_BMP[i+2][7:0]);
            $fwrite(fd, "%c", out_BMP[i+3][7:0]);
            $fwrite(fd, "%c", out_BMP[i+4][7:0]);
            $fwrite(fd, "%c", out_BMP[i+5][7:0]);
        end

end

else if(NUM_OF_PIXEL ==4)begin
 
 for (i = 0; i < WIDTH*HEIGHT*3; i = i + 12) begin
            $fwrite(fd, "%c", out_BMP[i     ][7:0]); // B0
            $fwrite(fd, "%c", out_BMP[i +  1][7:0]); // G0
            $fwrite(fd, "%c", out_BMP[i +  2][7:0]); // R0
            $fwrite(fd, "%c", out_BMP[i +  3][7:0]); // B1
            $fwrite(fd, "%c", out_BMP[i +  4][7:0]); // G1
            $fwrite(fd, "%c", out_BMP[i +  5][7:0]); // R1
            $fwrite(fd, "%c", out_BMP[i +  6][7:0]); // B2
            $fwrite(fd, "%c", out_BMP[i +  7][7:0]); // G2
            $fwrite(fd, "%c", out_BMP[i +  8][7:0]); // R2
            $fwrite(fd, "%c", out_BMP[i +  9][7:0]); // B3
            $fwrite(fd, "%c", out_BMP[i + 10][7:0]); // G3
            $fwrite(fd, "%c", out_BMP[i + 11][7:0]); // R3
           
        end
end

else if(NUM_OF_PIXEL ==8)begin 

for (i = 0; i < WIDTH*HEIGHT*3; i = i + 24) begin
            $fwrite(fd, "%c", out_BMP[i     ][7:0]); // B0
            $fwrite(fd, "%c", out_BMP[i +  1][7:0]); // G0
            $fwrite(fd, "%c", out_BMP[i +  2][7:0]); // R0
            $fwrite(fd, "%c", out_BMP[i +  3][7:0]); // B1
            $fwrite(fd, "%c", out_BMP[i +  4][7:0]); // G1
            $fwrite(fd, "%c", out_BMP[i +  5][7:0]); // R1
            $fwrite(fd, "%c", out_BMP[i +  6][7:0]); // B2
            $fwrite(fd, "%c", out_BMP[i +  7][7:0]); // G2
            $fwrite(fd, "%c", out_BMP[i +  8][7:0]); // R2
            $fwrite(fd, "%c", out_BMP[i +  9][7:0]); // B3
            $fwrite(fd, "%c", out_BMP[i + 10][7:0]); // G3
            $fwrite(fd, "%c", out_BMP[i + 11][7:0]); // R3
            $fwrite(fd, "%c", out_BMP[i + 12][7:0]); // B4
            $fwrite(fd, "%c", out_BMP[i + 13][7:0]); // G4
            $fwrite(fd, "%c", out_BMP[i + 14][7:0]); // R4
            $fwrite(fd, "%c", out_BMP[i + 15][7:0]); // B5
            $fwrite(fd, "%c", out_BMP[i + 16][7:0]); // G5
            $fwrite(fd, "%c", out_BMP[i + 17][7:0]); // R5
            $fwrite(fd, "%c", out_BMP[i + 18][7:0]); // B6
            $fwrite(fd, "%c", out_BMP[i + 19][7:0]); // G6
            $fwrite(fd, "%c", out_BMP[i + 20][7:0]); // R6
            $fwrite(fd, "%c", out_BMP[i + 21][7:0]); // B7
            $fwrite(fd, "%c", out_BMP[i + 22][7:0]); // G7
            $fwrite(fd, "%c", out_BMP[i + 23][7:0]); // R7
        end
 

end
else begin

 for (i = 0; i < WIDTH*HEIGHT*3; i = i + 48) begin
            $fwrite(fd, "%c", out_BMP[i     ][7:0]); // B0
            $fwrite(fd, "%c", out_BMP[i +  1][7:0]); // G0
            $fwrite(fd, "%c", out_BMP[i +  2][7:0]); // R0
            $fwrite(fd, "%c", out_BMP[i +  3][7:0]); // B1
            $fwrite(fd, "%c", out_BMP[i +  4][7:0]); // G1
            $fwrite(fd, "%c", out_BMP[i +  5][7:0]); // R1
            $fwrite(fd, "%c", out_BMP[i +  6][7:0]); //  B2
            $fwrite(fd, "%c", out_BMP[i +  7][7:0]); // G2
            $fwrite(fd, "%c", out_BMP[i +  8][7:0]); // R2
            $fwrite(fd, "%c", out_BMP[i +  9][7:0]); // B3
            $fwrite(fd, "%c", out_BMP[i + 10][7:0]); // G3
            $fwrite(fd, "%c", out_BMP[i + 11][7:0]); // R3
            $fwrite(fd, "%c", out_BMP[i + 12][7:0]); // B4
            $fwrite(fd, "%c", out_BMP[i + 13][7:0]); // G4
            $fwrite(fd, "%c", out_BMP[i + 14][7:0]); // R4
            $fwrite(fd, "%c", out_BMP[i + 15][7:0]); // B5
            $fwrite(fd, "%c", out_BMP[i + 16][7:0]); // G5
            $fwrite(fd, "%c", out_BMP[i + 17][7:0]); // R5
            $fwrite(fd, "%c", out_BMP[i + 18][7:0]); // B6
            $fwrite(fd, "%c", out_BMP[i + 19][7:0]); // G6
            $fwrite(fd, "%c", out_BMP[i + 20][7:0]); // R6
            $fwrite(fd, "%c", out_BMP[i + 21][7:0]); // B7
            $fwrite(fd, "%c", out_BMP[i + 22][7:0]); // G7
            $fwrite(fd, "%c", out_BMP[i + 23][7:0]); // R7
            $fwrite(fd, "%c", out_BMP[i + 24][7:0]); // B8
            $fwrite(fd, "%c", out_BMP[i + 25][7:0]); // G8
            $fwrite(fd, "%c", out_BMP[i + 26][7:0]); // R8
            $fwrite(fd, "%c", out_BMP[i + 27][7:0]); // B9
            $fwrite(fd, "%c", out_BMP[i + 28][7:0]); // G9
            $fwrite(fd, "%c", out_BMP[i + 29][7:0]); // R9
            $fwrite(fd, "%c", out_BMP[i + 30][7:0]); // B10
            $fwrite(fd, "%c", out_BMP[i + 31][7:0]); // G10
            $fwrite(fd, "%c", out_BMP[i + 32][7:0]); // R10
            $fwrite(fd, "%c", out_BMP[i + 33][7:0]); // B11
            $fwrite(fd, "%c", out_BMP[i + 34][7:0]); // G11
            $fwrite(fd, "%c", out_BMP[i + 35][7:0]); // R11
            $fwrite(fd, "%c", out_BMP[i + 36][7:0]); // B12
            $fwrite(fd, "%c", out_BMP[i + 37][7:0]); // G12
            $fwrite(fd, "%c", out_BMP[i + 38][7:0]); // R12
            $fwrite(fd, "%c", out_BMP[i + 39][7:0]); // B13
            $fwrite(fd, "%c", out_BMP[i + 40][7:0]); // G13
            $fwrite(fd, "%c", out_BMP[i + 41][7:0]); // R13
            $fwrite(fd, "%c", out_BMP[i + 42][7:0]); // B14
            $fwrite(fd, "%c", out_BMP[i + 43][7:0]); // G14
            $fwrite(fd, "%c", out_BMP[i + 44][7:0]); // R14
            $fwrite(fd, "%c", out_BMP[i + 45][7:0]); // B15
            $fwrite(fd, "%c", out_BMP[i + 46][7:0]); // G15
            $fwrite(fd, "%c", out_BMP[i + 47][7:0]); // R15
        end
 

end

     
        
       
    end
end
endmodule
