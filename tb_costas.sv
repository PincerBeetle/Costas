`timescale 1ns/1ps 
module tb_costas
#(
    real        clk_period=10,
    logic[31:0] phase_nco=32'h26666666,
    string      file_name="lpf_fir.txt"
);

localparam           pi = 22.0/7.0;
logic                clk_main=1'b0;
real                 freq_0=15.00e6;
real                 phase=0.0;
real                 I_data=0.0;
real                 Q_data=0.0;
integer              count=0;
logic        [15:0]  TestSin,data_out;
logic signed [15:0]  I_odata,Q_odata;
logic                enbl=1'b0,enbl_r0=1'b0;

typedef enum logic [2:0] {S0, S1, S2, S3, S4} statetype;
statetype state=S0;

initial begin
    freq_0=15.00e6;
    phase=0.0;
    $display(" ############# start phase shift test ############# ");
    $display("signal freq =  %f; phase =  %f;", freq_0, phase);
    #(2000*clk_period);
    wait(locked);
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    phase=pi/3; 
    $display("phase jump =  %f", phase);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    phase=-pi/2; 
    $display("phase jump =  %f", phase);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    phase=0.0; 
    $display("phase jump =  %f", phase);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    $display(" ############# finish phase test ############# ");
    $display(" ############# start freq shift test ############# ");
    freq_0=freq_0+1e3; 
    $display("freq jump =  %f", 1e3);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    freq_0=freq_0+10e3; 
    $display("freq jump =  %f", 10e3);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    freq_0=freq_0-30e3; 
    $display("freq jump =  %f", -30e3);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    freq_0=freq_0+19e3; 
    $display("freq jump =  %f", 19e3);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    freq_0=freq_0+50e3; 
    $display("freq jump =  %f", 50e3);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    freq_0=freq_0+50e3; 
    $display("freq jump =  %f", 50e3);
    #(4000*clk_period); 
    I_data=I_odata/32768.0;
    Q_data=Q_odata/32768.0;
    if(locked) begin
        $display("Costas locked!");
        $display("Idata =  %f; Qdata =  %f;", I_data, Q_data);
    end
    else begin
        $display("Costas don't locked!");
        $display("Test failed!");
        $finish;
    end
    $finish;
end

always #(clk_period/2*1ns) clk_main=~clk_main;

costas_prj
#(
    .file_name(file_name)
)
DUT
(
    .clk_main(clk_main), 
    .enable(enbl),
    .phase_nco(phase_nco),
    .indata(TestSin),
    .I_odata(I_odata),
    .Q_odata(Q_odata),
    .locked(locked)
);

always_ff@(posedge clk_main) begin
    count<=count+1;
    enbl<=enbl_r0;
    enbl_r0<=1'b1;
end

assign TestSin=30000.0*($sin((2.0*pi)*(freq_0*(count*(clk_period*1e-9)+phase))));

endmodule 