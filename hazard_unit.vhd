library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity hazard_unit is
	port (
		register_rs2_IF_ID : in std_logic_vector(4 downto 0);
		register_rs1_IF_ID : in std_logic_vector(4 downto 0);
    register_rd_ID_EX  : in std_logic_vector(4 downto 0);
		register_rd_EX_MEM : in std_logic_vector(4 downto 0);
    
		ID_EX_MemRead  : in std_logic;
    EX_MEM_MemRead : in std_logic;
    IsBranch       : in std_logic;
    IsJalr         : in std_logic;
    ID_EX_RegWrite : in std_logic;

		Stall : out std_logic
	);
end hazard_unit;

architecture structural of hazard_unit is

  signal internal_Stall : std_logic := '0';
  
begin

  process(register_rs2_IF_ID, register_rs1_IF_ID, register_rd_ID_EX, register_rd_EX_MEM, ID_EX_MemRead, EX_MEM_MemRead, IsBranch, IsJalr, ID_EX_RegWrite)
  begin

    internal_Stall <= '0';

    if      ( (ID_EX_MemRead = '1') AND (register_rd_ID_EX /= "00000") AND 
              (register_rd_ID_EX = register_rs1_IF_ID OR register_rd_ID_EX = register_rs2_IF_ID) ) then
            
            internal_Stall <= '1'; -- stall to wait for memory writeback 

    elsif   ( (IsBranch = '1') AND (EX_MEM_MemRead = '1') AND (register_rd_EX_MEM /= "00000") AND 
              (register_rd_EX_MEM = register_rs1_IF_ID OR register_rd_EX_MEM = register_rs2_IF_ID) ) then
            
            internal_Stall <= '1'; -- There's a branch in ID stage. Stall to wait for memory writeback, needed by the branch comparison unit
    
    elsif   ( (IsJalr = '1') AND (EX_MEM_MemRead = '1') AND (register_rd_EX_MEM /= "00000") AND 
            (register_rd_EX_MEM = register_rs1_IF_ID) ) then
          
            internal_Stall <= '1'; -- There's a jalr in ID stage. Stall to wait for memory writeback, needed to compute the jump target address
  
    elsif   ( (IsBranch = '1') AND (ID_EX_RegWrite = '1') AND (register_rd_ID_EX /= "00000") AND
              (register_rd_ID_EX = register_rs1_IF_ID OR register_rd_ID_EX = register_rs2_IF_ID) ) then
            
            internal_Stall <= '1'; -- There's a branch in ID stage. Need to stall to allow branch comparison, even
                                   -- if what's needed is an ALU output of the ID/EX instruction and not a data memory output 
    elsif   ( (IsJalr = '1') AND (ID_EX_RegWrite = '1') AND (register_rd_ID_EX /= "00000") AND
              (register_rd_ID_EX = register_rs1_IF_ID) ) then
            
            internal_Stall <= '1'; -- There's a jalr in ID stage. Need to stall to allow jump target address computation, even
                                   -- if what's needed is the ALU output of the ID/EX instruction and not a data memory output 
    else           
            internal_Stall <= '0';

    end if;

  end process;

  Stall <= internal_Stall;

end architecture structural;