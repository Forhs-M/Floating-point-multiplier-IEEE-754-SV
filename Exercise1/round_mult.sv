typedef enum logic [2:0] {IEEE_near, 
                          IEEE_zero,
                          IEEE_pinf, 
                          IEEE_ninf, 
                          near_up, 
                          away_zero} round_set;

module round_mult (output logic [24:0] result,
                     output logic inexact,
                     output logic [9:0] post_round_exponent,
                     input logic [2:0] round,
                     input logic [9:0] pre_round_exponent,
                     input logic [23:0] mantissa,
                     input logic guard,
                     input logic sticky,
                     input logic sign);

logic [24:0] pre_round_mantissa;
round_set round_enum;

always_comb begin
    case (round)
      3'b000: round_enum = IEEE_near;
      3'b001: round_enum = IEEE_zero;
      3'b010: round_enum = IEEE_pinf;
      3'b011: round_enum = IEEE_ninf;
      3'b100: round_enum = near_up;
      3'b101: round_enum = away_zero;
      default: round_enum = IEEE_near; 
    endcase
  end
    
always_comb begin
    inexact = guard | sticky;
end

always_comb begin
    if (inexact == 1'b1) begin
        case (round_enum)
            IEEE_near:  begin
                            if(guard == 1'b1 && (sticky||mantissa[0]))
                                pre_round_mantissa = {1'b0, mantissa} + 1'b1;
                            else
                                pre_round_mantissa = {1'b0, mantissa};
                        end
            IEEE_zero:  begin
                                pre_round_mantissa = {1'b0, mantissa};
                        end
            IEEE_pinf:  begin
                            if(sign == 1)
                                pre_round_mantissa = {1'b0, mantissa};
                            else
                                pre_round_mantissa = {1'b0, mantissa} + 1'b1;
                        end
            IEEE_ninf:  begin
                            if(sign == 0)
                                pre_round_mantissa = {1'b0, mantissa};
                            else
                                pre_round_mantissa = {1'b0, mantissa} + 1'b1;
                        end
            near_up:    begin
                            if(guard == 1'b1)
                                pre_round_mantissa = {1'b0, mantissa} + 1'b1;
                            else
                                pre_round_mantissa = {1'b0, mantissa}; 
                        end
            away_zero:  begin
                                pre_round_mantissa = {1'b0, mantissa} + 1'b1;
                        end
            default:    begin
                            if(guard == 1'b1 && (sticky||mantissa[0]))
                                pre_round_mantissa = {1'b0, mantissa} + 1'b1;
                            else
                                pre_round_mantissa = {1'b0, mantissa};
                        end
        endcase
    end
    else
        pre_round_mantissa = {1'b0, mantissa};    
end

always_comb begin
    if (pre_round_mantissa[24] == 1) begin
        result = {1'b1, pre_round_mantissa[24:1]};
        post_round_exponent =  pre_round_exponent + 1;
    end
    else begin
        result = pre_round_mantissa;
        post_round_exponent = pre_round_exponent;
    end
end

endmodule
