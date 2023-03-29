`timescale 1ns/1ps 
module costas_loop
#(parameter 
           logic signed [15:0] Kp       = 16'd2909,
           logic signed [15:0] Ki       = 16'd124,
           integer             LOCKNUM  = 32'd16,
           integer             LOCKWIND = 32'd2

)
(
    input  logic               clk_i,
    input  logic               enbl_i,
    input  logic signed [15:0] dataI_i,
    input  logic signed [15:0] dataQ_i,
    output logic signed [15:0] phase_o,
    output logic               locked_o
);

logic signed [31:0] mult_IQ,sum0,sum1;
logic signed [15:0] v_in[2];
logic signed [31:0] er=32'd0;
logic signed [31:0] phase_reg=32'd0;
logic signed [15:0] er_reg[2];
logic signed [15:0] diff_er;
logic               locked;
logic               lock_reg[LOCKNUM];


always_ff@(posedge clk_i) begin: differ_block
    er_reg[0] <=dataI_i;
    er_reg[1] <=er_reg[0];
    diff_er   <=er_reg[1]-er_reg[0];

    if(enbl_i) begin
        if(diff_er>LOCKWIND || diff_er<-LOCKWIND) begin
            locked <= 1'b0;
        end
        else begin
            locked <= 1'b1;
        end
    end
    else begin
        locked <= 1'b0;
    end
end

logic lock_tmp;

always_comb begin:lockand_block
    lock_tmp = lock_reg[0];
    for (int i = 1; i<=LOCKNUM-1; i++) begin
        lock_tmp = lock_tmp & lock_reg[i];
    end
    
end

always_ff@(posedge clk_i) begin: lock_block
    lock_reg[0]<=locked;
    for (int i = 0; i<=LOCKNUM-2; i++) begin
        lock_reg[i+1]<=lock_reg[i];
    end
    
    locked_o<=lock_tmp;
end

always_comb begin
    sum0=(Kp)*(v_in[0]);
    sum1=(Ki-Kp)*(v_in[1]);
end

always_ff@(posedge clk_i) begin
    
    if(enbl_i) begin
        // er          <=(sum0>>>15)+(sum1>>>15)+(er)>>>1;
        //v_in[0]     <=(mult_IQ)>>>15;
        v_in[0]     <=(mult_IQ);
        v_in[1]     <=v_in[0];
        er          <=(sum0)+(sum1)+(er)>>>1;
        phase_reg   <=er+phase_reg;
    end
    else begin
        v_in        <={16'd0,16'd0};
        er          <=32'd0;
        phase_reg   <=16'd0;
    end

    //mult_IQ<=dataI_i*dataQ_i;
    //phase_o=phase_reg;
    
    
    if(dataI_i>0) begin
        mult_IQ <= dataQ_i;
    end
    else begin
        mult_IQ <= -dataQ_i;
    end
    phase_o=phase_reg>>>15;
    
end




endmodule