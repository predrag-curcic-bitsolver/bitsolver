// Predrag Curcic
// Bitsolver
// Description
// Node for each bit of LFSR 

module lfsr_node (
    // Inputs
    clk,
    reset_n,
    ld,
    en,
    seed,
    d,
    // Output
    q
);

    input clk           ; // Main clock
    input reset_n       ; // Reset, active low
    input ld            ; // Enables seed load 
    input en            ; // Enable 
    input seed          ; // Seed value
    input d             ; // Input data

    output wire q       ; // Output data

    reg d_ff            ; 

    always @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            d_ff <= 1'b0;
        else begin
            if (ld) // Priority over enable
                d_ff <= seed;
            else if (en)
                d_ff <= d;
            else 
                d_ff <= 1'b0;
        end 
    end

    assign q = d_ff;

endmodule // lfsr_node