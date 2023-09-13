library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity forwarding_unit_ALU is
	port (    
		register_rs1_ID_EX : in std_logic_vector(4 downto 0);
		register_rs2_ID_EX : in std_logic_vector(4 downto 0);
		register_rd_EX_MEM : in std_logic_vector(4 downto 0);
		register_rd_MEM_WB : in std_logic_vector(4 downto 0);
    
		EX_MEM_RegWrite : in std_logic;
		MEM_WB_RegWrite : in std_logic;

		sel_fwd_1 : out std_logic_vector(1 downto 0); -- selector for the forwarding mux 1
		sel_fwd_2 : out std_logic_vector(1 downto 0)  -- selector for the forwarding mux 2
	);
end forwarding_unit_ALU;

architecture structural of forwarding_unit_ALU is

  signal internal_sel_fwd_1 : std_logic_vector(1 downto 0) := "00";
  signal internal_sel_fwd_2 : std_logic_vector(1 downto 0) := "00";

begin

  forward_1 : process(EX_MEM_RegWrite, register_rd_EX_MEM, register_rs1_ID_EX, MEM_WB_RegWrite, register_rd_MEM_WB)
  begin

    if      ( (EX_MEM_RegWrite = '1') AND (register_rd_EX_MEM /= "00000") AND 
            (register_rd_EX_MEM = register_rs1_ID_EX) ) then
            internal_sel_fwd_1 <= "10";

    elsif ( (MEM_WB_RegWrite = '1') AND (register_rd_MEM_WB /= "00000") AND 
            (register_rd_MEM_WB = register_rs1_ID_EX) ) then
            internal_sel_fwd_1 <= "01";

    else    
            internal_sel_fwd_1 <= "00";

    end if;

  end process; -- forward_1
  
  forward_2 : process(EX_MEM_RegWrite, register_rd_EX_MEM, register_rs2_ID_EX, MEM_WB_RegWrite, register_rd_MEM_WB)
  begin

    if      ( (EX_MEM_RegWrite = '1') AND (register_rd_EX_MEM /= "00000") AND 
            (register_rd_EX_MEM = register_rs2_ID_EX) ) then
            internal_sel_fwd_2 <= "10";

    elsif ( (MEM_WB_RegWrite = '1') AND (register_rd_MEM_WB /= "00000") AND 
            (register_rd_MEM_WB = register_rs2_ID_EX) ) then
            internal_sel_fwd_2 <= "01";

    else    
            internal_sel_fwd_2 <= "00";

    end if;

  end process; -- forward_2
  
  sel_fwd_1 <= internal_sel_fwd_1;
  sel_fwd_2 <= internal_sel_fwd_2;

end architecture structural;
  