`timescale 1ns/1ns

module  pwm_gen(
  input   wire        rst,
  input   wire        clk,
  input   wire        run_ctrl,
  input   wire        pwm_oen,
  input   wire        pwm_mod,    //0: FM   1:PWM
  input   wire  [7:0] pwm_width,
  output  wire        pwm_out
);
//--------------------
reg   [7:0] count;
wire        count_ovf;
reg   [7:0] pwm_width_r;
reg         pwm_out_r;
reg         pwm_oen_r;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    count       <=8'h0;
    pwm_width_r <=8'h33;
  end
  else if(run_ctrl)
  begin
    pwm_width_r<=pwm_width;
    if(pwm_oen_r)
      count     <=8'h0;
    else if(pwm_mod)
    begin
      if(count_ovf)   count <=8'h0;
      else            count <=count+1'b1;
    end
    else
    begin
      if(count==pwm_width_r)  count<=8'h0;
      else                    count<=count+1'b1;
    end
  end
end

assign  count_ovf = & count;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    pwm_out_r<=1'b1;
  else if(run_ctrl)
  begin
    if(pwm_oen_r)
      pwm_out_r<=1'b1;
    else if(pwm_mod)    //PWM
    begin
      if(count_ovf)
        pwm_out_r<=1'b1;
      else if(count==pwm_width_r)
        pwm_out_r<=1'b0;
    end
    else    //FM
    begin
      if(count==pwm_width_r)
        pwm_out_r<=~pwm_out_r;
    end
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    pwm_oen_r <=  1'b1;
  else if(pwm_oen_r)
  begin
    if(~pwm_oen) pwm_oen_r <=  1'b0;
  end
  else if(pwm_oen)
  begin
    if(pwm_mod)
    begin
      if(count_ovf) pwm_oen_r <=  1'b1;
    end
    else
    begin
      if(count==pwm_width_r)  pwm_oen_r <=  1'b1;
    end
  end
end

assign  pwm_out=pwm_out_r;

endmodule
