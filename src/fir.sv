// FIR 16 stages; 16 bit samples. Could be parameterised.

module fir #(parameter N_BITS = 24, N_FIR = 16)(input logic signed [N_BITS-1:0] in,
       input logic input_ready, ck, rst ,
       output logic signed [N_BITS-1:0] out,
       output logic output_ready);

localparam ADDRESS_SIZE = $clog2(N_FIR);

typedef logic signed [N_BITS-1:0] sample_array;
sample_array samples [0:N_FIR-1];

// generate coefficients from Octave/Matlab
// disp(sprintf('%d,',round(fir1(15,0.5)*32768)))

//original filter
//const sample_array coefficients [0:N_FIR-1] = '{-81, -134, 318, 645, -1257, -2262, 4522, 14633, 14633, 4522, -2262,-1257, 645, 318, -134, -81};

//8k 32 tap LPF
//const sample_array coefficients [0:N_FIR-1] = '{-38, -46, 64, 96, -143, -209, 296, 409, -555, -745, 998, 1349, -1877, -2786, 4823, 14747, 14747, 4823, -2786, -1877, 1349, 998, -745, -555, 409, 296, -209, -143, 96, 64, -46, -38};

//const sample_array coefficients [0:N_FIR-1] = '{-81, -134, 318, 645, -1257, -2262, 4522, 14633, 14633, 4522, -2262,-1257, 645, 318, -134, -81};
//4k LPF
//const sample_array coefficients [0:15] = '{-89, -193, -313, -66, 1055, 3152, 5590, 7247, 7247, 5590, 3152, 1055, -66, -313, -193, -89};

//2k LPF
//const sample_array coefficients [0:15] = '{143, 281, 671, 1348, 2246, 3205, 4014, 4477, 4477, 4014, 3205, 2246, 1348, 671, 281, 143};

//21k LPF
//const sample_array coefficients [0:15] = '{-53, 115, -312, 739, -1540, 3014, -6206, 20627, 20627, -6206, 3014, -1540, 739, -312, 115, -53};

//21Hz LPF
//const sample_array coefficients [0:15] = '{320, 480, 930, 1594, 2356, 3085, 3654, 3966, 3966, 3654, 3085, 2356, 1594, 930, 480, 320};

//notch filter at 5k
const sample_array coefficients [0:N_FIR-1] = '{-4, 0, 12, 29, 30, 0, -45, 32830, -45, 0, 30, 29, 12, 0, -4,  0};

logic unsigned [ADDRESS_SIZE-1:0] address; //clog2 of 16 is 4

logic signed [(N_BITS+ADDRESS_SIZE)-1:0] sum;

typedef enum logic [1:0] {waiting, loading, processing, saving} state_type;
state_type state, next_state = waiting;
logic load, count, reset_accumulator;


always_ff @(posedge ck)
  if (load)
    begin
    for (int i=N_FIR-1; i >= 1; i--)
      samples[i] <= samples[i-1];
    samples[0] <= in;
    end
  

// accumulator register
always_ff @(posedge ck)
  if (reset_accumulator)
    sum <= '0;
  else
    sum <= sum + samples[address] * coefficients[address];
    
always_ff @(posedge ck)
  if (output_ready)
    out <= sum[(N_BITS+ADDRESS_SIZE) - 1:ADDRESS_SIZE];
    
// address counter
//always_ff @(posedge ck)




// implement a synchronous counter that counts up through all 16 values of address
// when a count signal is true
always_ff @(posedge ck)
    if(reset_accumulator)
        address <= '0;
    else if(count)
        address <= address + 1'b1;

// controller state machine 
always_ff @(posedge ck, posedge rst)
    if(rst)
        state <= waiting;
    else
        state <= next_state;

// implement a state machine to control the FIR
always_comb begin
    reset_accumulator = 1'b0;
    load = 1'b0;
    count = 1'b0;
    output_ready = 1'b0;

    next_state = state;

    case(state)

        waiting: begin
            reset_accumulator = 1'b1;
            if(input_ready)
                next_state = loading;
            else
                next_state = waiting;
        end

        loading: begin
            load = 1'b1;
            next_state = processing;
        end

        processing: begin
            count = 1'b1;
            if(address < (N_FIR-1))
                next_state = processing;
            else
                next_state = saving;
        end

        saving: begin
            output_ready = 1'b1;
            next_state = waiting;
        end

    endcase
end


endmodule

