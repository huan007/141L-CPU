module Mux_2_To_1_Width #(parameter g_WIDTH = 8)
  (input  i_Select,
   input  [g_WIDTH-1:0] i_Data1,
   input  [g_WIDTH-1:0] i_Data2,
   output [g_WIDTH-1:0] o_Data);
   
  assign o_Data = i_Select ? i_Data1 : i_Data2;
   
endmodule // Mux_2_To_1_Width