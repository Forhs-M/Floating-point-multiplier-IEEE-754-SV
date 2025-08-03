`timescale 1ns/1ps

`include "multiplication.sv"
`include "test_status_bits.sv"
`include "test_status_z_combinations.sv"

module fp_mult_tb;

logic [31:0] a, b, z;
logic [2:0] round;
logic [7:0] status;
logic reset, clock; 

// multiplication.sv output

logic [31:0] correct;

// String for multiplication.sv / Integer for selection

string round_mode [0:5];
integer k;

// Corner case array

logic [31:0] corner [0:11];

// Errors integer

integer errors;

// Loop integers

integer i, j;


// Instantiation of fp_mult_top

fp_mult_top my_fp_mult_top (.a(a),
                            .b(b),
                            .rnd(round),
			                .z(z),
			                .status(status),
                            .clk(clock),
                            .rst(reset));   

// Assertions Binding

bind fp_mult_top test_status_bits bound_status_check (
        .clk(clk),
        .status(status)
    );

bind fp_mult_top test_status_z_combinations bound_status_z (
    .clk(clk),
    .status(status),
    .z(z),
    .a(a),
    .b(b)
);

// Clock

always #5 clock = ~clock;

initial begin
    // Signal initialization
    clock = 1'b0;
    a = 32'b0;
    b = 32'b0;
    reset = 1'b0;
    round = 3'b0;
    
    #20;

    // Start of circuit
    reset = 1'b1;
    #20;
    reset = 1'b0;
    #10;
    reset = 1'b1;
    
    // Rounding modes

    round_mode[0] = "IEEE_near";    
    round_mode[1] = "IEEE_zero";
    round_mode[2] = "IEEE_pinf"; 
    round_mode[3] = "IEEE_ninf";
    round_mode[4] = "near_up"; 
    round_mode[5] = "away_zero";

    // Initialize errors to 0

    errors = 0;

    // Loop that checks every rounding mode

    for(k=0; k<6; k++) begin
        round = k;
        $display("Rounding mode is : (%s)", round_mode[k]);
        for(i=0; i<60000; i++) begin
            a = $urandom;
            b = $urandom;
            #30;
            correct = multiplication(round_mode[k], a, b);
            if(z !== correct) begin
                $display("Random[%0d] mode %0d FAILED: a=%h b=%h => z=%0b expected=%0b", i, k, a, b, z, correct);  
            errors++ ;
            end
        end
    end

    // Number of errors during round mode check.

    if(errors != 0)
        $display("Round mode check did not pass. Errors encountered: %0d", errors);
    else
        $display("Round mode check pass. No errors encountered");


    // Corner cases

    // Signaling NaNs
    corner[0]  = {1'b1,8'b11111111,22'b1,1'b0};
    corner[1]  = {1'b0,8'b11111111,22'b1,1'b0};
    // Quiet NaNs
    corner[2]  = {1'b1,8'b11111111,1'b1,22'b0};
    corner[3]  = {1'b0,8'b11111111,1'b1,22'b0};
    // Infinities
    corner[4]  = {1'b1,8'b11111111,23'b0};
    corner[5]  = {1'b0,8'b11111111,23'b0};
    // Normals 
    corner[6]  = {1'b1,8'b00000011,23'b00000000000000000000001};
    corner[7]  = {1'b1,8'b00000011,23'b00000000000000000000001};
    // Denormals
    corner[8]  = {1'b1,8'b00000000,23'b00000000000000000000001};
    corner[9]  = {1'b0,8'b00000000,23'b00000000000000000000001};
    // Zeros
    corner[10] = {1'b1,31'b0};
    corner[11] = {1'b0,31'b0};

    
    // Re-initialize errors to 0

    errors = 0;
    
    // Loop that checks every corner case

    for(i=0; i<12; i++) begin
        for(j=0; j<12; j++) begin
        a = corner[i];
        b = corner[j];
        #30;
        correct = multiplication("away_zero", a, b);
        if(z !== correct) begin
            $display("Corner[%0d] x Corner[%0d] FAILED: calculated =%h, correct =%h", i, j, z, correct);
            errors++ ;
        end
        end
    end

    // Number of errors during corner case check.

    if(errors != 0)
        $display("Corner case check did not pass. Errors encountered: %0d", errors);
    else
        $display("Corner case check pass. No errors encountered");
    
    $stop;
end




endmodule

    
