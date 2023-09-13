-- exception_unit.vhd
-- Arithmetic exception unit.
-- Contains a register storing the exception possibily happening 
-- in the ALU, that is possible overflow in the adder-subtractor
-- or division by zero. All it does at this point is send out a warning
-- for simulation purposes. The register isn't used elsewhere
-- and the exception unit has no output. 

-- Because the register is loaded and the warnings are sent on clock edge
-- the warnings refer to what happened in the ALU in the previous
-- clock cycle, not the current.
-- This was done to be able to send the warnings at simulation a single time only,
-- the exc_type input could be sent directly to somewhere else without 
-- going in a register if it was needed concurrently.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.common.all;

entity exception_unit is
  port(
    clock, clear : in std_logic;
    exc_type : in exc_type_t
);
end entity exception_unit;

architecture behavioural of exception_unit is
  --signal exc_type_reg  : exc_type_t; -- Can't visualize this in gtkwave so I'm using a vector
  --signal proc_exc_type : exc_type_t;
  signal exc_type_reg : std_logic_vector(2 downto 0); -- 3 bits for 7 possible exception types
  signal proc_exc_type : std_logic_vector(2 downto 0);

  begin

    process(clock, clear)
    begin
      if (clear = '1') then
        --proc_exc_type <= EXC_NONE;
        proc_exc_type <= "000";
      elsif falling_edge(clock) then
        --proc_exc_type <= exc_type;
        if    exc_type = EXC_NONE  then
          proc_exc_type <= "000";
        elsif exc_type = ADD_OVF   then
          proc_exc_type <= "001";
          report "WARNING! A signed 64-bit addition in the ALU has overflown and produced an arithmetically invalid result!" severity warning;
        elsif exc_type = ADDW_OVF  then
          proc_exc_type <= "010";
          report "WARNING! A signed 32-bit addition in the ALU has overflown and produced an arithmetically invalid result!" severity warning;
        elsif exc_type = SUB_OVF   then
          proc_exc_type <= "011";
          report "WARNING! A signed 64-bit subtraction in the ALU has overflown and produced an arithmetically invalid result!" severity warning;
        elsif exc_type = SUBW_OVF  then
          proc_exc_type <= "100";
          report "WARNING! A signed 32-bit subtraction in the ALU has overflown and produced an arithmetically invalid result!" severity warning;
        elsif exc_type = DIV_BY_0  then
          proc_exc_type <= "101";
          report "WARNING! Dividing by zero in a DIV, DIVU, REM or REMU instruction! Setting result to xFFFFFFFFFFFFFFFF and remainder equal to the dividend ..." severity WARNING;
        elsif exc_type = DIVW_BY_0 then
          proc_exc_type <= "110";
          report "WARNING! Dividing by zero in a DIVW, DIVUW, REMW or REMUW instruction! Setting result to xFFFFFFFF and remainder equal to the dividend ..." severity WARNING;
        end if;    
              
      end if;
    end process;

    exc_type_reg <= proc_exc_type;


end behavioural;