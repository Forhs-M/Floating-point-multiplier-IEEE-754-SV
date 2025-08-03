module exception_mult (output logic zero_f,                       
                       output logic inf_f,
                       output logic nan_f,
                       output logic tiny_f,
                       output logic huge_f,
                       output logic inexact_f,
                       output logic [31:0] z,    
                       input logic [31:0] a,
                       input logic [31:0] b, 
                       input logic [31:0] z_calc,
                       input logic inexact,
                       input logic overflow,
                       input logic underflow,
                       input logic [2:0] round);

typedef enum {ZERO, INF, NORM, MIN_NORM, MAX_NORM} interp_t;

logic sign;

assign sign = z_calc[31];


interp_t a_interp, b_interp;

function interp_t num_interp(input logic [31:0] num_interp_inp);
    if(num_interp_inp[30:23] == 8'b11111111)
        return INF;
    else if(num_interp_inp[30:23] == 8'b00000000)     
        return ZERO;
    else
        return NORM;
endfunction

function logic [30:0] z_num(input interp_t z_num_inp);
    case (z_num_inp)
        ZERO:
            return 31'b0000000000000000000000000000000;
        INF:
            return 31'b1111111100000000000000000000000;
        MAX_NORM:
            return 31'b1111111011111111111111111111111;
        MIN_NORM:
            return 31'b0000000100000000000000000000000;
        default:
            return 31'b0000000000000000000000000000000;
    endcase
endfunction

always_comb begin
    zero_f = 1'b0;                      
    inf_f = 1'b0;
    nan_f = 1'b0;
    tiny_f = 1'b0;
    huge_f = 1'b0;
    inexact_f = 1'b0;
    a_interp = num_interp(a);
    b_interp = num_interp(b);

    if (a_interp == ZERO) begin
        if(b_interp == ZERO)    begin
            z = {sign, 31'b0000000000000000000000000000000};
            zero_f = 1'b1;
        end
        else if(b_interp == NORM) begin
            z = {sign, 31'b0000000000000000000000000000000};
            zero_f = 1'b1;
        end
        else if(b_interp == INF) begin
            z = {1'b0, 31'b1111111100000000000000000000000};
            inf_f = 1'b1;
            nan_f = 1'b1;
        end
    end
    else if(a_interp == INF) begin
        if(b_interp == INF) begin
            z = {sign, 31'b1111111100000000000000000000000};
            inf_f = 1'b1;
        end
        else if(b_interp == NORM) begin
            z = {sign, 31'b1111111100000000000000000000000};
            inf_f = 1'b1;
        end
        else if(b_interp == ZERO) begin
            z = {1'b0, 31'b1111111100000000000000000000000};
            inf_f = 1'b1;
            nan_f = 1'b1;
        end
    end
    else if(a_interp == NORM)begin
        if(b_interp == ZERO) begin
            z = {sign, 31'b0000000000000000000000000000000};
            zero_f = 1'b1;
        end
        else if (b_interp == INF) begin
            z = {sign, 31'b1111111100000000000000000000000};
            inf_f = 1'b1;
        end
        else if(b_interp == NORM) begin
               if(underflow == 1'b1) begin
                case(round)
                    3'b000 :begin 
                                z = {sign , 8'b00000000, 23'b00000000000000000000000};
                                zero_f = 1'b1;
                            end
                    3'b001 :begin
                                z = {sign , 8'b00000000, 23'b00000000000000000000000};
                                zero_f = 1'b1;
                            end
                    3'b010 :begin
                                if(sign == 1'b0) 
                                    z = {sign , 8'b00000001, 23'b00000000000000000000000};
                                else begin
                                    z = {sign , 8'b00000000, 23'b00000000000000000000000};  
                                    zero_f = 1'b1;
                                end
                            end
                    3'b011 :begin
                                if(sign == 1'b0) begin
                                    z = {sign , 8'b00000000, 23'b00000000000000000000000};
                                    zero_f = 1'b1;
                                end
                                else 
                                    z = {sign , 8'b00000001, 23'b00000000000000000000000};  
                            end
                    3'b100 : begin
                                z = {sign , 8'b00000000, 23'b00000000000000000000000};
                                zero_f = 1'b1;
                            end
                    3'b101 :
                        z = {sign , 8'b00000001, 23'b00000000000000000000000};                                   
                    default : begin 
                                z = {sign , 8'b00000000, 23'b00000000000000000000000};
                                zero_f = 1'b1;
                            end
                endcase
                inexact_f = inexact;
                tiny_f = 1'b1;            
            end
            else if (overflow == 1'b1) begin
                case(round)
                    3'b000 : begin 
                                z = {sign , 8'b11111111, 23'b00000000000000000000000};
                                inf_f = 1'b1;
                            end
                    3'b001 :
                        z = {sign , 8'b11111110, 23'b11111111111111111111111};
                    3'b010 :begin
                                if(sign == 1'b0) begin 
                                                    z = {sign, 8'b11111111, 23'b0};
                                                    inf_f = 1'b1;
                                                end
                                else 
                                    z = {sign , 8'b11111110, 23'b11111111111111111111111};  
                            end
                    3'b011 :begin
                                if(sign == 1'b0) 
                                    z = {sign, 8'b11111110, 23'b11111111111111111111111};
                                else begin
                                    z = {sign , 8'b11111111, 23'b00000000000000000000000};  
                                    inf_f = 1'b1;
                                end
                            end
                    3'b100 : begin
                                z = {sign, 8'b11111111, 23'b00000000000000000000000};
                                inf_f = 1'b1;
                            end
                    3'b101 : begin
                                z = {sign , 8'b11111111, 23'b00000000000000000000000};                             
                                inf_f = 1'b1;
                            end
                    default : begin
                                z = {sign , 8'b11111111, 23'b00000000000000000000000};
                                inf_f = 1'b1;
                            end
                endcase
                inexact_f = inexact;
                huge_f = 1'b1;
            end
            else begin
                z = z_calc;
                inexact_f = inexact;
            end
        end
    end
end

endmodule