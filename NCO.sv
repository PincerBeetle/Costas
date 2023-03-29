`timescale 1ns/1ps 
module NCO
#(
    filename="ncodata.txt"
)
(
    input  logic        clk_i,
    input  logic        enbl_i,
    input  logic[31:0]  phi_inc_i,
    input  logic[15:0]  phase_mod_i,
    output logic[15:0]  fsin_o,
    output logic[15:0]  fcos_o,
    output logic        valid_o  
);

logic [15:0] addr_rom;
logic [31:0] phase_cntr;
logic [15:0] data_rom [65536];
logic [15:0] addr_phase;
logic enbl_r0,enbl_r1;

initial begin
    $readmemb(filename,data_rom); 
end


always_ff @( posedge clk_i ) begin : incr_block
    if(enbl_i) begin
        phase_cntr<=phase_cntr+phi_inc_i;
    end
    else begin
        phase_cntr<=32'd0;
    end
    enbl_r0<=enbl_i;
end

assign addr_rom=(phase_cntr>>>16);

//always_comb begin
//    addr_rom   = (phase_cntr>>>16);
//    addr_phase = addr_rom+phase_mod_i;
//end

always_ff @( posedge clk_i ) begin : addr_data_block
    addr_phase  <=addr_rom+signed'(phase_mod_i)+16'd32768;
    fsin_o      <=data_rom[addr_phase+16'd16384];
    fcos_o      <=data_rom[addr_phase];
    enbl_r1     <=enbl_r0;
    valid_o     <=enbl_r1;
end

endmodule

