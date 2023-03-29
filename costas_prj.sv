`timescale 1ns/1ps 
module costas_prj
#(parameter 
                        file_name="lpf_fir.txt"
)
(
    input  logic         clk_main,
    input  logic         enable,
    input  logic[31:0]   phase_nco,       
    input  logic[15:0]   indata,
    output logic[15:0]   I_odata,
    output logic[15:0]   Q_odata,
    output logic         locked
);

logic[15:0] data_I,data_Q;
logic[31:0] i_signal=32'd0,q_signal=32'd0;
logic[15:0] i_fdata=16'd0,q_fdata=16'd0;
logic[15:0] sin_data,cos_data;
logic[15:0] phase_mod_i;
logic       i_valid,q_valid,c_valid;

assign c_valid=i_valid&q_valid;

costas_loop costas_mod
(
    .clk_i(clk_main),
    .enbl_i(c_valid),
    .dataI_i(data_I),
    .dataQ_i(data_Q),
    .phase_o(phase_mod_i),
    .locked_o(locked)
);

NCO nco_mod
(
    .clk_i(clk_main),
    .enbl_i(enable),
    .phi_inc_i(phase_nco),
    .phase_mod_i(phase_mod_i),
    .fsin_o(sin_data),
    .fcos_o(cos_data),
    .valid_o(nco_valid)
);

always_comb begin
    I_odata=data_I;
    Q_odata=data_Q;
end

always_ff@(posedge clk_main) begin
       i_signal<=signed'(cos_data)*signed'(indata);
       q_signal<=signed'(sin_data)*signed'(indata);
end

always_comb begin : infilt_data
    if(nco_valid==1'b1) begin
        i_fdata=signed'(i_signal)>>>15;
        q_fdata=signed'(q_signal)>>>15;
    end
    else begin 
        i_fdata<=16'd0;
        i_fdata<=16'd0;
    end 
end

fir_7dsp48
#(
    .INDATA_WIDTH(16),
    .OUTDATA_WIDTH(16),
    .TRUNCATION(16),
    .FILT_DEPTH(128),
    .CoefsFile(file_name)
)
i_lpf
(
    .clk_main(clk_main),
    .indata_vld(nco_valid),
    .data_in(i_fdata),
    .data_out(data_I),
    .outdata_vld(i_valid)
);

fir_7dsp48
#(
    .INDATA_WIDTH(16),
    .OUTDATA_WIDTH(16),
    .TRUNCATION(16),
    .FILT_DEPTH(128),
    .CoefsFile(file_name)
)
q_lpf
(
    .clk_main(clk_main),
    .indata_vld(nco_valid),
    .data_in(q_fdata),
    .data_out(data_Q),
    .outdata_vld(q_valid)
);


endmodule