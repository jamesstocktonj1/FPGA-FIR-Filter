module test_fir;

timeunit 1ns;
timeprecision 100ps;

localparam N_BITS = 16;

logic signed [N_BITS-1:0] in;
logic input_ready, ck, rst;
logic signed [N_BITS-1:0] out;
logic output_ready;

int input_frequency = 2500;

fir #(.N_BITS(N_BITS)) CUT (.*);

 // clock generator
//  generates a 1 MHz clock

  
initial
  begin
  ck = '0;
  forever #500ns ck = ~ck;
  end
 
// test waveform generator creates a square wave
initial
  begin
  in = 0;
  forever
    begin
      #(500000000/input_frequency) in = -10000;
      #(500000000/input_frequency) in = 10000;
    end
  end

initial begin
  input_frequency = 1000;
  for(int i=1; i<11; i++)
    #10ms input_frequency = i*1000;
end


// generate sample strobe at sample rate of 40kHz
always
  begin
      #24us input_ready = '1;
      #1us   input_ready = '0;
    end
    
initial
  begin
  rst = '0;
  #10ns rst = '1;
  #10ns rst = '0;
  end
  
  
endmodule
 