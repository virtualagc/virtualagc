`define NUM_BIT 15
`include "agc_mult/agc_mult_bb.v"

// Classical gate-level half adder
module half_adder ( 
    output logic sum, c_out,
    input  logic x, y
);
    xor (sum, x, y);
    and (c_out, x, y);

endmodule: half_adder

// Classical gate-level full adder
// Composed partially of half adders
module full_adder (
    output logic sum, c_out,
    input  logic x, y, c_in
);
    logic c_out_1, sum_1,
          c_out_2;

    // Generate "half sum" of operands
    half_adder ha_1 (.sum(sum_1),
                     .c_out(c_out_1),
                     .x(x), .y(y));

    // Generate "full sum" ("half sum" + c_in)
    half_adder ha_2 (.sum(sum),
                     .c_out(c_out_2),
                     .x(c_in), .y(sum_1));

    // Generate final carry out
    or (c_out, c_out_1, c_out_2);

endmodule: full_adder

// Classical ripple carry adder
// Composed of full adders
module ripple_carry_adder (
    output logic [`NUM_BIT-1:0] sum,
    output logic c_out,
    input  logic [`NUM_BIT-1:0] x, y,
    input  logic c_in
);
    logic [`NUM_BIT-1:0] c_out_array;

    genvar i;
    generate
        for (i = 0; i < `NUM_BIT; i++) begin: full_adder_array
            if (i == 0) begin
                // Low order adder takes overall c_in
                full_adder (.sum(sum[0]),
                            .c_out(c_out_array[0]),
                            .x(x[0]), .y(y[0]),
                            .c_in(c_in));
            end
            else begin
                // following adders take c_out of prev adder
                full_adder (.sum(sum[i]),
                            .c_out(c_out_array[i]),
                            .x(x[i]), .y(y[i]),
                            .c_in(c_out_array[i-1]));
            end
        end: full_adder_array
    endgenerate

    // High order carry out to c_out
    assign c_out = c_out_array[`NUM_BIT-1];

endmodule: ripple_carry_adder

// Convert from one's complement, to two's complement
// Based around ripple carry adder
module convert_1c_2c 
(# parameter WIDTH_MULT = 1;)
(   
    output logic [(WIDTH_MULT * `NUM_BIT)-1:0] twos_comp,
    input  logic [(WIDTH_MULT * `NUM_BIT)-1:0] ones_comp
);
    // Add 1'b1 to ones_comp if sign of ones_comp is 1'b1
    ripple_carry_adder conv_1_2 (.sum(twos_comp),
                                 .c_out(),
                                 .x(ones_comp), 
                                 .y({{((WIDTH_MULT * `NUM_BIT)-1){1'b0}}, 
                                     ones_comp[(WIDTH_MULT * `NUM_BIT)-1]}),
                                 .c_in(1'b0));

endmodule: convert_1c_2c

// Convert from two's complement, to one's complement
// Based around ripple carry adder
module convert_2c_1c 
(# parameter WIDTH_MULT = 1;)
(
    output logic [(WIDTH_MULT * `NUM_BIT)-1:0] ones_comp,
    output logic underflow_flag,
    input  logic [(WIDTH_MULT * `NUM_BIT)-1:0] twos_comp
);
    // Two's comp int_min cannot be represented in one's comp
    assign underflow_flag = (twos_comp == 
                             {1'b1, {((WIDTH_MULT * `NUM_BIT)-1){1'b0}}});

    // Add -1 to twos_comp if sign of twos_comp is 1'b1
    ripple_carry_adder conv_2_1 (.sum(ones_comp),
                                 .c_out(),
                                 .x(twos_comp),
                                 .y({(WIDTH_MULT * `NUM_BIT){
                                     twos_comp[(WIDTH_MULT * `NUM_BIT)-1]}}),
                                 .c_in(1'b0));

endmodule: convert_2c_1c

//
// CONSTRUCTING THE ALU ADD/SUB UNIT
//

// Ripple carry adder w/ end-around carry
module ones_comp_adder (
    output logic [`NUM_BIT-1:0] sum,
    input  logic [`NUM_BIT-1:0] x, y
);
    logic [`NUM_BIT-1:0] sum_pre;
    logic end_around_carry;

    // Perform the core addition
    ripple_carry_adder add_pre (.sum(sum_pre),
                                .c_out(end_around_carry),
                                .x(x), .y(y),
                                .c_in(1'b0));

    // Perform end-around carry correction
    ripple_carry_adder add_eac (.sum(sum),
                                .c_out(),
                                .x(sum_pre), .y(15'd0),
                                .c_in(end_around_carry));

endmodule: ones_comp_adder

// Adder/subtractor w/ select line
module ones_comp_add_sub (
    output logic [`NUM_BIT-1:0] sum,
    input  logic [`NUM_BIT-1:0] x, y,
    input  logic subtract;
);
    logic [`NUM_BIT-1:0] y_operand;

    // Negate y in case of subtraction
    assign y_operand = (subtract) ? ~y : y;

    // Perform computation
    ones_comp_adder add_sub (.sum(sum),
                             .x(x), .y(y_operand));

endmodule: ones_comp_add_sub

//
// CONSTRUCTING THE ALU MULTIPLIER
//

// Altera 2's complement lmp_mult megafunction
// Convert operands 1c -> 2c
// Convert product 2c -> 1c
module ones_comp_mult (
    output logic [(2 * `NUM_BIT)-1:0] prod,
    output logic underflow_flag,
    input  logic [`NUM_BIT-1:0] x, y
);
    logic [(2 * `NUM_BIT)-1:0] prod_twos_comp;
    logic [`NUM_BIT-1:0] x_twos_comp, y_twos_comp;

    convert_1c_2c #(1) x_2c (.twos_comp(x_twos_comp),
                             .ones_comp(x));

    convert_1c_2c #(1) y_2c (.twos_comp(y_twos_comp).
                             .ones_comp(y));

    agc_mult mult_2c (.result(prod_twos_comp),
                      .dataa(x_twos_comp),
                      .datab(y_twos_comp));

    convert_2c_1c #(2) prod_1c (.ones_comp(prod),
                                .underflow_flag(underflow_flag)
                                .twos_comp(prod_twos_comp));

endmodule: ones_comp_mult

//
// CONSTRUCTING THE ALU DIVIDER
//

// Altera 2's complement LPM_DIVIDE megafunction
// Convert numerator, denominator 1c -> 2c
// Convert quotient, remainder 2c -> 1c
module ones_comp_div (
    output logic ['NUM_BIT-1:0] quot, remain,
    output logic underflow_flag,
    input  logic [(2 * `NUM_BIT)-1:0] numer,
    input  logic [`NUM_BIT-1:0] denom
);
    logic [(2 * `NUM_BIT)-1:0] numer_twos_comp;
    logic [`NUM_BIT-1:0] quot_twos_comp, quot_twos_comp_pre, 
                         remain_twos_comp, denom_twos_comp;
    logic [1:0] underflow_flag_pre;

    convert_1c_2c #(2) numer_2c (.twos_comp(numer_twos_comp),
                                 .ones_comp(numer));

    convert_1c_2c #(1) denom_2c (.twos_comp(denom_twos_comp),
                                 .ones_comp(denom));

    agc_div div_2c (.quotient(quot_twos_comp_pre),
                    .remain(remain_twos_comp),
                    .numer(numer_twos_comp),
                    .denom(denom_twos_comp));

    assign quot_twos_comp = quot_twos_comp_pre[(2 * `NUM_BIT)-1:'NUM_BIT];

    convert_2c_1c #(1) quot_2c (.ones_comp(quot),
                                .underflow_flag(underflow_flag_pre[1]),
                                .twos_comp(quot_twos_comp));

    convert_2c_1c #(1) remain_2c (.ones_comp(remain),
                                  .underflow_flag(underflow_flag_pre[0]),
                                  .twos_comp(remain_twos_comp));

    // 2 possible sources of conversion underflow
    assign underflow_flag = underflow_flag_pre[1] | underflow_flag_pre[0];

endmodule: ones_comp_div





    