 -- File       : mux_ID_EX_Flush.vhd

 library ieee;
 use ieee.std_logic_1164.all;
 
 entity mux_ID_EX_Flush is
   port (
    ID_EX_Flush : in std_logic;
    ALUOp_1, ALUOp_0, ALUSrc1_1, ALUSrc1_0, ALUSrc2_1, ALUSrc2_0, MemtoReg, RegWrite, MemRead, MemWrite : in std_logic;
    ID_ALUOp_1, ID_ALUOp_0, ID_ALUSrc1_1, ID_ALUSrc1_0, ID_ALUSrc2_1, ID_ALUSrc2_0, ID_MemtoReg, ID_RegWrite, ID_MemRead, ID_MemWrite : out std_logic
   );
 end mux_ID_EX_Flush; 
   
 architecture behavioral of mux_ID_EX_Flush is
  signal internal_Flush : std_logic;
 begin

  internal_Flush <= NOT ID_EX_Flush;

  ID_ALUOp_1    <= ( ALUOp_1 AND internal_Flush );
  ID_ALUOp_0    <= ( ALUOp_0 AND internal_Flush );
  ID_ALUSrc1_1  <= ( ALUSrc1_1 AND internal_Flush );
  ID_ALUSrc1_0  <= ( ALUSrc1_0 AND internal_Flush );
  ID_ALUSrc2_1  <= ( ALUSrc2_1 AND internal_Flush );
  ID_ALUSrc2_0  <= ( ALUSrc2_0 AND internal_Flush );
  ID_MemtoReg   <= ( MemtoReg AND internal_Flush );
  ID_RegWrite   <= ( RegWrite AND internal_Flush );
  ID_MemRead    <= ( MemRead AND internal_Flush );
  ID_MemWrite   <= ( MemWrite AND internal_Flush );
 
 end behavioral; 
 