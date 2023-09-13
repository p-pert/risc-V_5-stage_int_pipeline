library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_address_unit is
	port (
		PC : in std_logic_vector(63 downto 0); 
    immediate : in std_logic_vector(63 downto 0);
		branch_address : out std_logic_vector(63 downto 0)
	);
end branch_address_unit;

architecture behavioral of branch_address_unit is
  -- signal internal_branch_address : std_logic_vector(63 downto 0);
  -- signal internal_shifted_imm : std_logic_vector(63 downto 0);
  -- begin
  --   branch_address_unit_proc : process(PC, immediate, internal_shifted_imm) is 
  --     variable imm_unsigned   : unsigned(63 downto 0);
  --   begin
  --     imm_unsigned := unsigned(immediate);
  --     internal_shifted_imm <= std_logic_vector(shift_left(imm_unsigned, 1));

  --     internal_branch_address <= std_logic_vector(signed(PC) + signed(internal_shifted_imm));
  --   end process;
  --   branch_address <= internal_branch_address;
  signal shifted_imm : std_logic_vector(63 downto 0) := (others => '0');
  begin
  shifted_imm <= immediate(62 downto 0) & '0';  -- shift left logical 1-bit

  adder_sub_br_adr_unit : entity work.ADDER_SUBTR generic map(N => 64) port map(addsub => '0', a => PC, b => shifted_imm, 
                                                        s => branch_address, overflow => open, c_out => open);
  end architecture behavioral;