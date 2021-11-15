module D1 (input logic CLOCK_50, CLOCK2_50, input logic [1:0] KEY,
	       // I2C Audio/Video config interface 
           output logic FPGA_I2C_SCLK, inout wire FPGA_I2C_SDAT, 
           // Audio CODEC
           output logic AUD_XCK, 
		   input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, 
		   output logic AUD_DACDAT);
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];

	/////////////////////////////////
	// This simply connects the reads and the writes together.
	// 
	/////////////////////////////////
	
	wire [23:0] filterLeftOut, filterRightOut;
	wire filterLeftReady, filterRightReady;
	
	
	
	fir fir_left(
		//data in to filter
		.in(readdata_left[23:8]),
		.input_ready(write_ready),
		
		//clk and rst
		.ck(CLOCK_50),
		.rst(reset),
		
		//data out of filter
		.out(filterLeftOut[23:8]),
		.output_ready(filterLeftReady)
		);
		
	fir fir_right(
		//data in to filter
		.in(readdata_right[23:8]),
		.input_ready(write_ready),
		
		//clk and rst
		.ck(CLOCK_50),
		.rst(reset),
		
		//data out of filter
		.out(filterRightOut[23:8]),
		.output_ready(filterRightReady)
		);
		
	assign writedata_left = (KEY[1]) ? filterLeftOut : readdata_left;
	assign writedata_right = (KEY[1]) ? filterRightOut : readdata_right;
	assign read = read_ready;
	assign write = (KEY[1]) ? filterLeftReady : write_ready;
	
	
	
	
	/*
	fir fir_left(
		//data in to filter
		.in(readdata_left[23:8]),
		.input_ready(write_ready),
		
		//clk and rst
		.ck(CLOCK_50),
		.rst(reset),
		
		//data out of filter
		.out(writedata_left[23:8]),
		.output_ready(write)
		);*/
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


