-- File       : mux_ID_EX_Flush_TB.vhd


library IEEE;
use ieee.std_logic_1164.all;
use work.all;

entity mux_ID_EX_Flush_TB is
end mux_ID_EX_Flush_TB;

architecture TEST of mux_ID_EX_Flush_TB is 

-- component mux_ID_EX_Flush is
  -- port (
  --   ID_Flush : in std_logic;
  --   ALUOp_1, ALUOp_0, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, IsBranch : in std_logic;
  --   ID_ALUOp_1, ID_ALUOp_0, ID_ALUSrc, ID_MemtoReg, ID_RegWrite, ID_MemRead, ID_MemWrite : out std_logic
  --  );
-- end component mux_ID_EX_Flush;

begin


    
  STIMULUS_GEN: process
    begin

    wait for 100 ns;   

  end process STIMULUS_GEN;


  DUT: entity work.mux_ID_EX_Flush
  port map ( --need to finish writing this
    ID_Flush => ID_Flush,
    ALUOp_1 => , ALUOp_0 => , ALUSrc => , MemtoReg => , RegWrite => , MemRead => , MemWrite => , IsBranch => ,
    ID_ALUOp_1 => ,ID_ALUOp_0 =>  ,ID_ALUSrc => ,ID_MemtoReg =>, ID_RegWrite => , ID_MemRead => , ID_MemWrite => , : out std_logic
  );
  end architecture TEST;

