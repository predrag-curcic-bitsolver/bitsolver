`timescale 1ns/1ps

module tb_crc_module;

  // Inputs
  reg clk;
  reg reset_n;
  reg vld;
  reg [7:0] din;
  
  // Outputs
  wire [15:0] crc_dout;

  // Instantiate the CRC module
  crc_module uut (
    .clk(clk),
    .reset_n(reset_n),
    .vld(vld),
    .din(din),
    .crc_dout(crc_dout)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    // Initialize inputs
    reset_n = 0;
    din = 8'h00;
    vld = 0;
    // Apply reset
    #30 reset_n = 1;

    // Test scenario
    @(posedge clk);
    vld = 1;
    din = 8'h55; // Example input data
    @(posedge clk);
    vld = 0;
    //@(posedge clk) din = 8'hAA; // Another input data
    //@(posedge clk);
    //vld = 0;
    // Add more test cases as needed

    // End simulation
    #100 $finish;
  end

  // CRC Dout checker
  always @(posedge clk) begin
    // Insert your logic to check crc_dout against expected values here
    // For simplicity, we'll just print crc_dout to the console in this example
    if (vld == 1)
      $display("Time %0t: crc_dout = %h", $time, crc_dout);
    else
      $display("Data input is not valid!");
  end

  // Dump waveform
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_crc_module);
    #1000 $finish;
  end

endmodule
