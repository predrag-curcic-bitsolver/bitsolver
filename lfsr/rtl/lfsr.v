// Predrag Curcic
// Bitsolver
// Description 
// -> Linear Feedback Shift Register with POLYNOMIAL, WIDTH and SEED parameters
// -> with nodes instantiated

module lfsr (
    // Inputs
    clk,
    reset_n,
    ld,
    en,
    // Outputs 
    dout
);
    // width of LFSR
    parameter LFSR_WIDTH = 11;
    // primitive polynomial for feedback
    parameter [LFSR_WIDTH-1:0] LFSR_POLYNOMIAL = 11'b10000000010;
    // starting seed 
    parameter [LFSR_WIDTH-1:0] LFSR_SEED = 11'b11011011011;

    // States for the state machine
    localparam IDLE = 2'b00;
    localparam LFSR_LOAD = 2'b01;
    localparam LFSR_OPERATION = 2'b10;

    input clk           ; // Clock
    input reset_n       ; // Active low reset
    input ld            ; // Load seed indicator
    input en            ; // Enables functionality of LFSR

    output wire dout    ; // LFSR data out

    reg [LFSR_WIDTH-1:0] d_ff; 
    reg [1:0] state;  // State variable for the state machine
    reg feedback;     // Feedback value  

    // Feedback calculation based on parametrized polynomial
    always @(posedge clk or negedge reset_n) 
    begin
        if (!reset_n)
            feedback <= 1'b0;
        else
            if (en == 1 && state == LFSR_OPERATION)
                for (int i = 0; i < LFSR_WIDTH; i = i + 1) 
                    if (LFSR_POLYNOMIAL[i] == 1'b1)
                        feedback <= (feedback ^ d_ff[i]);
    end

    // State machine logic
    always @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            state <= IDLE;
        else
            case (state)
                IDLE:
                    if (ld && en)
                        state <= LFSR_LOAD;

                LFSR_LOAD:
                    state <= LFSR_OPERATION;

                LFSR_OPERATION: begin
                    if (en && !ld)
                        state <= LFSR_OPERATION;
                    else if (ld && en)
                        state <= LFSR_LOAD;
                    else
                        state <= IDLE;
                end

                default: state <= IDLE;
            endcase
    end

    // 0 node instance
    lfsr_node i_lfsr_node (
              .clk     ( clk            )
            , .reset_n ( reset_n        )
            , .d       ( feedback       )
            , .ld      ( (state == LFSR_LOAD) ? 1'b1 : 1'b0 )
            , .en      ( en             )
            , .seed    ( LFSR_SEED[0]   )
            , .q       ( d_ff[0]        )
    );

    // Instancing LFSR_WIDTH - 1 nodes
    genvar i;

    generate
        for (i = 1; i < LFSR_WIDTH; i = i + 1)
        begin : gen_lfsr_node_inst
            lfsr_node i_lfsr_node (
                      .clk     ( clk            )   
                    , .reset_n ( reset_n        )
                    , .d       ( d_ff[i-1]      )
                    , .ld      ( (state == LFSR_LOAD) ? 1'b1 : 1'b0             )
                    , .en      ( en             )
                    , .seed    ( LFSR_SEED[i]   )
                    , .q       ( d_ff[i]        )
            );
        end : gen_lfsr_node_inst
    endgenerate

    assign dout = d_ff[LFSR_WIDTH-1];

endmodule // lfsr
