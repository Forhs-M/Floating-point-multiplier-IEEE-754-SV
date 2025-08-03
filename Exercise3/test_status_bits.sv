module test_status_bits (
    input logic clk,
    input logic [7:0] status 
);

logic zero_f     = status[0];
logic inf_f      = status[1];
logic nan_f      = status[2];
logic tiny_f     = status[3];
logic huge_f     = status[4];
logic inexact_f  = status[5]; 

always_comb begin 
    if (zero_f == 1'b1) begin
        assert (inf_f == 1'b0) 
        else 
            $error($stime,,,"\t\t %m FAIL immediate 1");
    end 
    
    if (zero_f == 1'b1) begin
        assert (nan_f == 1'b0)
        else
            $error($stime,,,"\t\t %m FAIL immediate 2");
    end 

    if (zero_f == 1'b1) begin
        assert (huge_f == 1'b0)
        else
            $error($stime,,,"\t\t %m FAIL immediate 3");
    end

    if (inf_f == 1'b1) begin
        assert (tiny_f == 1'b0)
        else
            $error($stime,,,"\t\t %m FAIL immediate 4");
    end

    if (nan_f == 1'b1) begin
        assert (tiny_f == 1'b0)
        else
            $error($stime,,,"\t\t %m FAIL immediate 5");
    end

    if (nan_f == 1'b1) begin
        assert (huge_f == 1'b0)
        else
            $error($stime,,,"\t\t %m FAIL immediate 6");
    end

    if (nan_f == 1'b1) begin
        assert (inexact_f == 1'b0)
        else
            $error($stime,,,"\t\t %m FAIL immediate 7");
    end
    
    if (tiny_f == 1'b1) begin
        assert (huge_f == 1'b0)
        else
            $error($stime,,,"\t\t %m FAIL immediate 8");
    end

end

endmodule
