library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity forwarding_unit_branch is
	port (    
		register_rs2_IF_ID : in std_logic_vector(4 downto 0);
		register_rs1_IF_ID : in std_logic_vector(4 downto 0);
		register_rd_EX_MEM : in std_logic_vector(4 downto 0);
    
		EX_MEM_RegWrite : in std_logic;

		sel_fwd_branch_1 : out std_logic;
		sel_fwd_branch_2 : out std_logic
	);
end forwarding_unit_branch;

architecture structural of forwarding_unit_branch is

  signal internal_sel_fwd_branch_1 : std_logic := '0';
  signal internal_sel_fwd_branch_2 : std_logic := '0';

begin

  forward_1 : process(EX_MEM_RegWrite, register_rd_EX_MEM, register_rs1_IF_ID)
  begin

    if      ( (EX_MEM_RegWrite = '1') AND (register_rd_EX_MEM /= "00000") AND 
            (register_rd_EX_MEM = register_rs1_IF_ID) ) then
            internal_sel_fwd_branch_1 <= '1';

    else    
            internal_sel_fwd_branch_1 <= '0';

    end if;

  end process; -- forward_1
  
  forward_2 : process(EX_MEM_RegWrite, register_rd_EX_MEM, register_rs2_IF_ID)
  begin

    if      ( (EX_MEM_RegWrite = '1') AND (register_rd_EX_MEM /= "00000") AND 
            (register_rd_EX_MEM = register_rs2_IF_ID) ) then
            internal_sel_fwd_branch_2 <= '1';

    else    
            internal_sel_fwd_branch_2 <= '0';

    end if;

  end process; -- forward_2
  
  sel_fwd_branch_1 <= internal_sel_fwd_branch_1;
  sel_fwd_branch_2 <= internal_sel_fwd_branch_2;

end architecture structural;
  