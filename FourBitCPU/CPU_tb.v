/*
 
  CPU_tb.v
  
  Tests FourBitCPU.v
  
 */

`include "defines.v"

module CPU_tb;

reg clk_cpu;
reg reset;
reg [7:0] inst;
reg [3:0] io_in;
wire [3:0] pc;
wire [3:0] io_out;

// CPU
CPU CPU0(
  .clk_cpu(clk_cpu),
  .reset(reset),
  .inst(inst),
  .io_in(io_in),
  .pc(pc),
  .io_out(io_out)
);

// clock
initial begin
    clk_cpu = 0;
    forever #`HCYCL clk_cpu = !clk_cpu;
end

// test
initial begin
  
  // init regs
  reset = 0;
  
  // reset
  test_reset_button();
  
  // test instructions
  test_instructions();
  
end

// test reset
task test_reset_button;
begin
  reset = 1;
  repeat(5) @(posedge clk_cpu);
  reset = 0;
end
endtask

// test instructions
parameter LENGTH = 33;
parameter LSB_EXP_IO_OUT = 0;
parameter MSB_EXP_IO_OUT = LSB_EXP_IO_OUT + 3;
parameter LSB_EXP_REG_B = MSB_EXP_IO_OUT + 1;
parameter MSB_EXP_REG_B = LSB_EXP_REG_B + 3;
parameter LSB_EXP_REG_A = MSB_EXP_REG_B + 1;
parameter MSB_EXP_REG_A = LSB_EXP_REG_A + 3;
parameter LSB_EXP_PC = MSB_EXP_REG_A + 1;
parameter MSB_EXP_PC = LSB_EXP_PC + 3;
parameter LSB_IO_IN = MSB_EXP_PC + 1;
parameter MSB_IO_IN = LSB_IO_IN + 3;
parameter LSB_INST = MSB_IO_IN + 1;
parameter MSB_INST = LSB_INST + 7;
parameter WIDTH = MSB_INST + 1; 
reg [WIDTH - 1:0] test_rom[0:LENGTH - 1];
reg [WIDTH - 1:0] rom;
reg [3:0] exp_pc;
reg [3:0] exp_reg_a;
reg [3:0] exp_reg_b;
reg [3:0] exp_io_out;
integer i;

task test_instructions;
begin
  $readmemh("inst_tests.txt", test_rom);
  for (i = 0; i < LENGTH; i = i + 1) begin
    @(posedge clk_cpu) begin
      rom = test_rom[i];
      inst = rom[MSB_INST:LSB_INST];
      io_in = rom[MSB_IO_IN:LSB_IO_IN];
      exp_pc = rom[MSB_EXP_PC:LSB_EXP_PC];
      exp_reg_a = rom[MSB_EXP_REG_A:LSB_EXP_REG_A];
      exp_reg_b = rom[MSB_EXP_REG_B:LSB_EXP_REG_B];
      exp_io_out = rom[MSB_EXP_IO_OUT:LSB_EXP_IO_OUT];
//      $display("line: %d, inst: %h, pc: %h, reg_a: %h, reg_b: %h", i, inst, exp_pc, exp_reg_a, exp_reg_b);
      #`STROB;
      if (pc != exp_pc)
        $display("Unexpected PC on line: %d, pc: %h, exp_pc: %h", i, pc, exp_pc);
      if (CPU0.register_file_a.dat_out !== exp_reg_a)
        $display("Unexpected reg_a on line: %d, reg_a: %h, exp_reg_a: %h", i, CPU0.register_file_a.dat_out, exp_reg_a);
      if (CPU0.register_file_b.dat_out !== exp_reg_b)
        $display("Unexpected reg_b on line: %d, reg_b: %h, exp_reg_b: %h", i, CPU0.register_file_b.dat_out, exp_reg_b);
      if (io_out !== exp_io_out)
        $display("Unexpected io_out on line: %d, io_out: %h, exp_io_out: %h", i, io_out, exp_io_out);
    end
  end
  $display("instruction test ended.");
end
endtask

endmodule