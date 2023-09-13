 -- File       : mux_EX_MEM_Flush.vhd

 library ieee;
 use ieee.std_logic_1164.all;

 entity mux_EX_MEM_Flush is
   port (
    EX_MEM_Flush : in std_logic;
    ID_EX_MemtoReg, ID_EX_RegWrite, ID_EX_MemRead, ID_EX_MemWrite : in std_logic;
    EX_MemtoReg, EX_RegWrite, EX_MemRead, EX_MemWrite : out std_logic
   );
 end mux_EX_MEM_Flush; 
   
 architecture behavioral of mux_EX_MEM_Flush is
  signal internal_Flush : std_logic;
 begin

  internal_Flush <= NOT EX_MEM_Flush;

  EX_MemtoReg <= (ID_EX_MemtoReg AND internal_flush);
  EX_RegWrite <= (ID_EX_RegWrite AND internal_flush);
  EX_MemRead  <= (ID_EX_MemRead  AND internal_flush);
  EX_MemWrite <= (ID_EX_MemWrite AND internal_flush);
 
 end behavioral; 
 