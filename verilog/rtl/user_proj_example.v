// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 2
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // IOs
    input  [37:0] io_in,
    output [37:0] io_out,
    output [37:0] io_oeb,

);
    wire clk;
    wire rst;

    wire [BITS-1:0] count;

    // IO
    assign io_out[BITS+11:12] = count;
    assign io_oeb[BITS+11:12] = 2'b0;

    assign clk = io_in[10];
    assign io_oeb[10] = 1'b1;

    assign rst = io_in[11];
    assign io_oeb[11] = 1'b1;
  
    assign io_out[11:0] = 12'b0;
    assign io_out[37:14] = 24'b0;
  
    assign io_oeb[11:0] = 12'b0;
    assign io_oeb[37:14] = 24'b0;

    counter #(
        .BITS(BITS)
    ) counter(
        .clk(clk),
        .reset(rst),
        .count(count)
    );

endmodule

module counter #(
    parameter BITS = 8
)(
    input clk,
    input reset,
    output reg [BITS-1:0] count
);

    always @(posedge clk) 
    begin
        if (reset) 
            count <= 0;
        else  
            count <= count + 1;
    end

endmodule

`default_nettype wire
