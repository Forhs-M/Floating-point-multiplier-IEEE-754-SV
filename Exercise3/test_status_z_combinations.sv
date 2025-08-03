module test_status_z_combinations (
    input logic clk,
    input logic [7:0] status,
    input logic [31:0] z,
    input logic [31:0] a,
    input logic [31:0] b
);

wire zero_f     = status[0];
wire inf_f      = status[1];
wire nan_f      = status[2];
wire tiny_f     = status[3];
wire huge_f     = status[4];


property pr1;
    @(posedge clk) zero_f |-> (z[30:23] == 8'b00000000);
endproperty
    
property pr2;
    @(posedge clk) inf_f |-> (z[30:23] == 8'b11111111);
endproperty 

property pr3;
    @(posedge clk) nan_f |-> ($past(a[30:23], 3) == 8'h00 && $past(b[30:23], 3) == 8'hFF)  || ($past(a[30:23],3) == 8'hFF && $past(b[30:23], 3) == 8'h00);
endproperty

property pr4;
    @(posedge clk) huge_f |-> (z[30:23] == 8'b11111111) || (z[30:23] == 8'b11111110); 
endproperty


property pr5;
    @(posedge clk) tiny_f |-> (z[30:23] == 8'b00000000) || (z[30:23] == 8'b00000001); 
endproperty


zero_exp_zero: assert property (pr1) else $error($stime,,,"\t\t %m FAIL concurrent 1");
inf_exp_ones: assert property (pr2) else $error($stime,,,"\t\t %m FAIL concurrent 2");
nan:  assert property (pr3) else $error($stime,,,"\t\t %m FAIL concurrent 3");
huge:  assert property (pr2) else $error($stime,,,"\t\t %m FAIL concurrent 4");
tiny: assert property (pr5) else $error($stime,,,"\t\t %m FAIL concurrent 5");


endmodule
