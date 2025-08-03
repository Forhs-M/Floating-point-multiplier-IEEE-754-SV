module fp_mult (input logic [31:0] a, b,
                input logic [2:0] rnd,
		        output logic [31:0] z, 
                output logic [7:0] status,
                input logic clock,
                input logic reset);

//  Wires before pipeline

logic xor_out;
logic [9:0] adder_out;
logic [23:0] mult_a, mult_b;
logic [47:0] mult_out;
logic [22:0] mantissa;
logic guard;
logic sticky;
logic [9:0] exponent;

// Pipeline registers
logic [2:0] round_reg;
logic [31:0] a_reg, b_reg;
logic [9:0] exponent_reg;
logic [22:0] mantissa_reg;
logic guard_reg;
logic sticky_reg;
logic sign_reg;

// Unused status bits to 0

assign status[7:6] = 2'b0;

// Sign calculation

assign xor_out = a[31] ^ b[31];

// Exponent calculation

assign adder_out = a[30:23] + b[30:23] - 127;

// Mantissa calculation - Hidden 1 if the number is not 0 or Denormal 

assign mult_a = {1'b1, a[22:0]};
assign mult_b = {1'b1, b[22:0]};

assign mult_out = mult_a * mult_b;

// normalise module instanciation

normalize_mult my_norm (.exponent(exponent),
                         .mantissa(mantissa),
                         .guard(guard),
                         .sticky(sticky),
                         .mult_res(mult_out), 
                         .addition(adder_out));


// Pipeline Registers

always_ff @(posedge clock ) begin 
    if(reset == 0) begin
        a_reg <= 32'b0; 
        b_reg <= 32'b0;
        exponent_reg <= 10'b0;
        mantissa_reg <= 23'b0; 
        guard_reg <= 1'b0;
        sticky_reg <= 1'b0;
        round_reg <= 3'b0;
        sign_reg <= 1'b0;
    end
    else begin
        a_reg <= a;
        b_reg <= b;
        exponent_reg <= exponent;
        mantissa_reg <= mantissa;
        guard_reg <= guard;
        sticky_reg <= sticky;
        round_reg <= rnd;
        sign_reg <= xor_out;
    end      
end

// Wires after pipeline

logic [24:0] round_mantissa;
logic [9:0] post_round_exponent;
logic inexact;
logic overflow;
logic underflow;
logic [31:0] z_calc;

// Rounding module instanciation

round_mult my_round (.result(round_mantissa),
                     .inexact(inexact),
                     .post_round_exponent(post_round_exponent),
                     .round(round_reg),
                     .pre_round_exponent(exponent_reg),
                     .mantissa({1'b1, mantissa_reg}),
                     .guard(guard_reg),
                     .sticky(sticky_reg),
                     .sign(sign_reg)); 

// Z_calc 

assign z_calc = {sign_reg, post_round_exponent[7:0], round_mantissa[22:0]};

// Overflow/Underflow bit signals

always_comb begin
    overflow  = (post_round_exponent[9] == 1'b0 && post_round_exponent > 9'd254);
    underflow = (post_round_exponent[9] == 1'b1 || post_round_exponent[8:0] == 9'b0);
end

// Exception Handling module instanciation

exception_mult my_exception(.zero_f(status[0]),
                            .inf_f(status[1]),
                            .nan_f(status[2]),
                            .tiny_f(status[3]),
                            .huge_f(status[4]),
                            .inexact_f(status[5]),
                            .z(z),
                            .a(a_reg),
                            .b(b_reg),
                            .z_calc(z_calc),
                            .inexact(inexact),
                            .overflow(overflow),
                            .underflow(underflow),
                            .round(round_reg)

				);


endmodule