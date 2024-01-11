// Predrag Curcic
// Bitsolver
// Description
// Testbench for LFSR

module tb_lfsr;

    reg clk;
    reg reset_n;
    reg ld;
    reg en;

    wire dout;

    // Parameters set
    parameter LFSR_WIDTH= 11;
    parameter LFSR_POLYNOMIAL = 11'b10100000000;
    parameter LFSR_SEED = 11'b11011011011;

    // Instantiate the LFSR module with parameters
    lfsr #(
        .LFSR_WIDTH         (LFSR_WIDTH),
        .LFSR_POLYNOMIAL    (LFSR_POLYNOMIAL),
        .LFSR_SEED          (LFSR_SEED)
    ) i_lfsr (
        .clk                (clk),
        .reset_n            (reset_n),
        .ld                 (ld),
        .en                 (en),
        .dout               (dout)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    
    initial begin
        reset_n = 0;
        ld = 0;
        en = 0;
        seed = 0;
        seed_next = 0;
        // Module is on reset for few cycles
        #20;
        // Reset release 
        reset_n = 1;
        #20;
        // Load seed into LFSR
        @(posedge clk) ld = 1;
        en = 1;
        @(posedge clk);
        ld = 0;
        // Wait for LFSR to generate values
        #150;
        reset_n = 0;
        #20;
        reset_n = 1;
        #20;
        // Load seed into LFSR
        @(posedge clk) ld = 1;
        en = 1;
        @(posedge clk);
        ld = 0;
        #50;
    end

    // Checkers signals 
    reg [LFSR_WIDTH-1:0] seed;
    reg [LFSR_WIDTH-1:0] seed_sync;
    reg seed_next;

    // Checker Section
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) 
        begin
            seed_next <= 1'b0;
            seed      <= '0;
            seed_sync <= '0;
        end 
        else 
        begin
            if (ld == 1 && en == 1) // LOAD SEED
                seed <= LFSR_SEED;
            else if (en == 1) begin // LFSR CALCULATION
                for (int i = 0; i < LFSR_WIDTH; i = i + 1) begin
                    if (LFSR_POLYNOMIAL[i] == 1)
                        seed_next <= seed_next ^ seed[i];
                end
                seed <= {seed[LFSR_WIDTH-2:0], seed_next};
            end
            seed_sync <= seed;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            $display("RESET!");// Initialization at reset
        end else begin
            if (en == 1)begin
                $display("Expected value = %b, Actual value = %b", seed_sync[LFSR_WIDTH-1], dout);
                if (seed_sync[LFSR_WIDTH-1] != dout)
                    $display("Wrong LFSR data output value!!!");
            end
        end
    end

    
    initial begin
        #500;
        $finish;
    end
    
    // Write VCD file
    initial begin
        $dumpfile("waves.vcd");  // Naziv VCD fajla
        $dumpvars(0, lfsr_tb);    // Dump svih promenljivih
        #1000;  // Sačekaj nekoliko taktova pre nego što završi simulacija
        $finish;
    end


endmodule // tb_lfsr