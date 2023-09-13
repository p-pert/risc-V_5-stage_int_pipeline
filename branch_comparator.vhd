-- File       : branch_comparator.vhd

-- I'm using an adder-subtractor set on subtraction, but I could have used a simple subtractor
-- The core of the logic is the following:
-- the adder-subtractor Overflow bit tells me if a 64-bit SIGNED subtraction (or addition) is valid,
-- that is if the 64-bit addsub_result is arithmetically correct. So if addsub_Ovrf = '0' I can use 
-- the addsub_result 64 bits by themselves to check for the branch condition, oterwhise if addsub_Ovrf = '1'
-- the addsub_result is not the correct arithmetic result, but I can make use of the addsub_CarryOut bit 
-- because appending it to the addsub_result I get a 65 bit number that is the correct arithmetic result.

-- In the case of UNSIGNED operands comparison so unsigned subtraction, the 64-bit result is always correct

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.all;

entity branch_comparator is
	port (
    IsBranch         : in std_logic;
    funct3 : in std_logic_vector(2 downto 0);
    sel_fwd_branch_1 : in std_logic; -- selector for internal forwarding mux that controls if input operand is to be taken from register file output or from (forwarded) ALU output
		sel_fwd_branch_2 : in std_logic; -- selector for internal forwarding mux that controls if input operand is to be taken  from register file output or from (forwarded) ALU output
		register_file_output_1 : in std_logic_vector(63 downto 0);
		register_file_output_2 : in std_logic_vector(63 downto 0);
		ALU_output_EX_MEM      : in std_logic_vector(63 downto 0);
    BranchCmp        : out std_logic
	);
end entity branch_comparator;

architecture structural of branch_comparator is

  signal o1, o2 : std_logic_vector(63 downto 0); -- operands
  signal addsub_result : std_logic_vector(63 downto 0); -- adder-subtractor result
  signal addsub_CarryOut, addsub_Ovrf : std_logic;
  signal internal_BranchCmp : std_logic := '1';

begin

  -------------- Forwarding muxes --------------
  mux_fwd_branch_1 : entity work.mux_2_1_64b port map(selection => sel_fwd_branch_1,
                                                      input_0 => register_file_output_1, input_1 => ALU_output_EX_MEM, 
                                                      output_0 => o1);
  mux_fwd_branch_2 : entity work.mux_2_1_64b port map(sel_fwd_branch_2, register_file_output_2, ALU_output_EX_MEM, o2);

  
  
  -------------------- ****************************** -------------------------------------


  compare_proc: process (IsBranch, funct3, addsub_result, addsub_Ovrf, addsub_CarryOut) is
  begin  -- process compare_proc

    internal_BranchCmp <= '1'; -- default value when it's not a branch is '1'
                               -- if the instruction is a branch BranchCmp will
                               -- become either '1' if branch taken or '0' if not taken

    if(IsBranch='1') then

      case (funct3) is
          when "000" => -- BEQ      -- branch if o1=o2
              if(addsub_Ovrf = '0' AND addsub_result = (addsub_result'range => '0')) OR
                (addsub_Ovrf = '1' AND addsub_CarryOut = '0' AND addsub_result = (addsub_result'range => '0')) then
                  internal_BranchCmp <= '1';
              else
                  internal_BranchCmp <= '0';
              end if;

          when "001" => -- BNE      -- branch if o1/=o2
              if(addsub_Ovrf = '0' AND addsub_result = (addsub_result'range => '0')) OR
                (addsub_Ovrf = '1' AND addsub_CarryOut = '0' AND addsub_result = (addsub_result'range => '0')) then
                  internal_BranchCmp <= '0';
              else
                  internal_BranchCmp <= '1';
              end if;

          when "100" => -- BLT      -- branch if o1<o2
            if(addsub_Ovrf = '0' AND addsub_result(63) = '1') OR
              (addsub_Ovrf = '1' AND addsub_CarryOut = '1') then
                  internal_BranchCmp <= '1';
              else
                  internal_BranchCmp <= '0';
              end if;

          when "101" => -- BGE      -- branch if o1>=o2
              if(addsub_Ovrf = '0' AND addsub_result(63) = '1') OR
                (addsub_Ovrf = '1' AND addsub_CarryOut = '1') then
                  internal_BranchCmp <= '0';
              else
                  internal_BranchCmp <= '1';
              end if;

          when "110" => -- BLTU     -- branch if o1<o2 unsigned interpretation
              if(addsub_result(63) = '1') then
                internal_BranchCmp <= '1';
              else
                internal_BranchCmp <= '0';
              end if;

          when "111" => -- BGEU     -- branch if o1>=o2 unsigned interpretation
              if(addsub_result(63) = '1') then
                internal_BranchCmp <= '0';
              else
                internal_BranchCmp <= '1';
              end if;
              
          when others => internal_BranchCmp <= '0';
      
        end case; --funct3
      
    else -- if IsBranch='0' then
      internal_BranchCmp <= '1';
      
    end if; --IsBranch

  end process compare_proc;

  adder_subtractor : entity work.ADDER_SUBTR 
                      generic map (N => 64)
                      port map(addsub => '1', 
                      a => o1, b => o2, 
                      s => addsub_result, overflow => addsub_Ovrf, 
                      c_out => addsub_CarryOut);


  -------------------- ****************************** --------------------------------------
  
  -- Wiring Output --

  BranchCmp <= internal_BranchCmp;

end architecture structural;