module crc_module (
  // Inputs
  clk,     
  reset_n, 
  vld,     
  din,     
  // Output
  crc_dout 
);

// Parameters
parameter DATA_WIDTH  = 8                      ; // Data width 
parameter CRC_WIDTH   = 16                     ; // CRC width 
parameter POLYNOMIAL  = 16'b1100000000000010   ; // CRC polynomial 
parameter INIT_VALUE  = 16'h1111               ; // Initial CRC value
parameter REFLECT_IN  = 1'b1                   ; // Input data reflection (0 for non-reflected, 1 for reflected)
parameter REFLECT_OUT = 1'b0                   ; // CRC output reflection (0 for non-reflected, 1 for reflected)

// Inputs
input                        clk               ; // Clock signal
input                        reset_n           ; // Active low asynchronous reset
input                        vld               ; // Data valid indicator
input       [DATA_WIDTH-1:0] din               ; // DATA input - parametrized WIDTH
//Output
output wire [CRC_WIDTH-1:0]  crc_dout          ; // CRC output - parametrized WIDTH

// Internal registers
reg [CRC_WIDTH-1:0]          crc_reg           ; // CRC REGISTER
reg [$clog2(DATA_WIDTH):0]   bit_counter       ; // Counter to indicate CRC calculation logic done

// CRC calculation and polynomial division logic
always @(posedge clk or negedge reset_n) 
begin
  if (~reset_n)
  begin
    // Reset on active-low asynchronous reset
    crc_reg <= INIT_VALUE;
    bit_counter <= '0;
  end
  else begin
    // Shift and XOR logic for each data bit
      if (vld) begin
        for (int i = 0; i < DATA_WIDTH; i = i + 1) 
        begin
          if (REFLECT_IN)
            crc_reg <= crc_reg ^ (din[i] ^ crc_reg[CRC_WIDTH-1]);
          else 
            crc_reg <= crc_reg ^ (din[i] ^ crc_reg[0]);

          if (CRC_WIDTH < DATA_WIDTH) begin
            // Adjust the shift amount if CRC width is less than data width
            crc_reg <= crc_reg >> (DATA_WIDTH - CRC_WIDTH);
          end else begin
            crc_reg <= crc_reg >> 1;
          end

          // Increment bit counter
          bit_counter <= bit_counter + 1;
      end

      // Polynomial division
      if (bit_counter == DATA_WIDTH) 
      begin
        if (crc_reg[CRC_WIDTH-1]) 
          crc_reg <= crc_reg ^ POLYNOMIAL;

        // Reset bit counter to indicate the end of processing
        bit_counter <= 0;
      end
    end
  end
end

// Output data reflection
assign crc_dout = (REFLECT_OUT) ? ~crc_reg : crc_reg;

endmodule
