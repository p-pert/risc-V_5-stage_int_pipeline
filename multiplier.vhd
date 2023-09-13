-- File       : multiplier.vhd

-- Booth's algorithm implementation:
-- One clock cycle for initializing with SC at 0, putting multiplicand in BR, multiplier in QR and setting
-- AC to 0 and the extra bit of QR, Qn+1 to 0. Afterwards:
-- 1.) The two bits of the multiplier in Qn and Qn+1 are inspected. If the two bits are equal to "10", it
-- means that the first 1 in a string has been encountered. This requires subtraction of the multiplicand
-- from the partial product in AC. If the 2 bits are equal to "01", it means that the first 0 in a string of
-- 0's has been encountered. This requires the addition of the multiplicand to the partial product in AC.
-- When the two bits are equal, the partial product does not change. An overflow cannot occur because
-- the addition and subtraction of the multiplicand follow each other.
-- 2.) The next step is to shift right the partial product and the multiplier (including Qn+1). This is an
-- arithmetic shift right (ashr) operation which shifts AC and QR to the right and leaves the sign bit in
-- AC unchanged.
-- 3.) The sequence counter is incremented and the loop is repeated 64 times for a Double, 32 for a Word
-- division.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.all;


entity Booth_multiplier is
	port (
  clock : in std_logic;
  clear : in std_logic;
  A : in std_logic_vector(63 downto 0 );
  B : in std_logic_vector(63 downto 0 );
  IsM : in std_logic;
  DorW : in std_logic;
  result : out std_logic_vector(127 downto 0);
  BUSY : out std_logic
  );
end entity Booth_multiplier;


architecture booths_algorithm of Booth_multiplier is

  signal counter_in, counter_out : std_logic_vector(6 downto 0)           := (others => '0');
  signal BR_in, BR_out : std_logic_vector(63 downto 0)                    := (others => '0');
  signal QR_in, QR_out : std_logic_vector(64 downto 0)                    := (others => '0');
  signal AC_in, AC_out : std_logic_vector(63 downto 0) := (others => '0');
  signal add_OR_sub : std_logic                                           := '0';
  signal addsub_out : std_logic_vector(63 downto 0)                       := (others => '0');
  signal load : std_logic                                                 := '0';
  signal proc_counter_in : std_logic_vector(6 downto 0)                   := (others => '0');
  signal proc_BR_in : std_logic_vector(63 downto 0)                        := (others => '0');
  signal proc_QR_in : std_logic_vector(64 downto 0)                        := (others => '0');
  signal proc_AC_in : std_logic_vector(63 downto 0)             := (others => '0');
  signal proc_add_OR_sub : std_logic                                      := '0';
  signal proc_BUSY : std_logic                                     := '0';
  signal proc_load : std_logic                                            := '0';

  signal counter_add1 : std_logic_vector(6 downto 0)                      := (others => '0');
  
  begin

      process(A, B, counter_out, AC_out, QR_out, DorW, IsM, counter_add1, addsub_out)
        
      begin
        proc_load <= '0';       

        if(IsM = '1') then  
          if(counter_out = "0000000")  then -- initialize
            
            proc_load <= '1';                                      -- storing in QR and BR registers

            if(DorW = '1') then  -- Operation on word
              proc_BR_in <= (X"00000000" & A(31 downto 0));        -- store value of A in QR.             
              proc_QR_in <= (X"00000000" & B(31 downto 0) & '0');  -- store value of B in QR. QR_n+1 is set to '0'
              proc_AC_in <= (others => '0');                       -- initialize accumulator with zeros
            else -- Operation on double
              proc_BR_in <= A;
              proc_QR_in <= B & '0';
              proc_AC_in <= (others => '0');
            end if;
            proc_BUSY <= '1';                                      -- signal the mul/div is running from now on. Will stall pipeline
            proc_counter_in <= "0000001";                          -- add one to counter
            proc_add_OR_sub <= '-';
          
          elsif(DorW = '1' AND counter_out(5) = '1' AND counter_out(0) = '1') then -- Operation on words, counter_out = 33. Finished a multiplication           
            proc_load <= '0';               -- nothing to load in QR and BR registers
            proc_BR_in <= (others => '-');
            proc_QR_in <= (others => '-');
            proc_AC_in <= (others => '-');
            proc_BUSY <= '0';               -- signal the operation is done
            proc_counter_in <= "0000000";   -- reset counter
            proc_add_OR_sub <= '-';

          elsif(counter_out(6) = '1' AND counter_out(0) = '1') then -- Operation on doubles, counter_out = 65. Finished a multiplication         
            proc_load <= '0';               -- nothing to load in QR and BR registers
            proc_BR_in <= (others => '-');
            proc_QR_in <= (others => '-');
            proc_AC_in <= (others => '-');
            proc_BUSY <= '0';               -- signal the operation is done
            proc_counter_in <= "0000000";   -- reset counter
            proc_add_OR_sub <= '-';
          
          else

          --------------------- Booth's algorithm logic -----------------------------------

            proc_BUSY <= '1';
            proc_load <= '0';         -- nothing to load. The correct values are loaded at initialization
            proc_BR_in <= (others => '-');
            proc_QR_in <= (others => '-');
            
            --proc_counter_in <= std_logic_vector(unsigned(counter_out) + "0000001");
            proc_counter_in <= counter_add1;      -- add 1 to counter

            if(DorW = '1') then -- Operation on word
                if(QR_out(1) = '1' AND QR_out(0) = '0') then
                  proc_add_OR_sub <= '1'; -- subtraction : AC - BR
                  proc_AC_in <= X"00000000" & addsub_out(31) & addsub_out(31 downto 1); -- put the result back in AC_reg, and shift right arithmetically
                elsif(QR_out(1) = '0' AND QR_out(0) = '1') then
                  proc_add_OR_sub <= '0'; -- addition : AC + BR
                  proc_AC_in <= X"00000000" & addsub_out(31) & addsub_out(31 downto 1); -- put the result back in AC_reg, and shift right arithmetically
                else 
                  proc_add_OR_sub <= '-';
                  proc_AC_in <= X"00000000" & AC_out(31) & AC_out(31 downto 1); -- don't add/sum, only shift
                end if;
                proc_QR_in <= X"00000000" & QR_out(32) & QR_out(32 downto 1); -- always shift right arithmetically QR
            
            else -- Operation on double
                if(QR_out(1) = '1' AND QR_out(0) = '0') then
                  proc_add_OR_sub <= '1'; -- subtraction : AC - BR
                  proc_AC_in <= addsub_out(63) & addsub_out(63 downto 1); -- put the result back in AC_reg, and shift right arithmetically
                elsif(QR_out(1) = '0' AND QR_out(0) = '1') then
                  proc_add_OR_sub <= '0'; -- addition : AC + BR
                  proc_AC_in <= addsub_out(63) & addsub_out(63 downto 1); -- put the result back in AC_reg, and shift right arithmetically
                else 
                  proc_add_OR_sub <= '-';
                  proc_AC_in <= AC_out(63) & AC_out(63 downto 1); -- don't add/sum, only shift
                end if;
                proc_QR_in <= QR_out(64) & QR_out(64 downto 1); -- always shift right arithmetically QR
            end if; -- end if DorW
  
          end if; --end if counter_out

        else -- IsM = 0
          proc_counter_in <= "0000000";
          proc_BUSY <= '0';
          proc_load <= '0';
          proc_QR_in <= (others => '-');
          proc_BR_in <= (others => '-');
          proc_AC_in <= (others => '-');
          proc_add_OR_sub <= '-';

        end if;

      end process;

      load <= proc_load;
      BR_in <= proc_BR_in;
      QR_in <= proc_QR_in;
      AC_in <= proc_AC_in;
      counter_in <= proc_counter_in;
      BUSY <= proc_BUSY;
      add_OR_sub <= proc_add_OR_sub;

      
      counter_reg : entity work.reg_7b port map(counter_in, '1', clock, clear, counter_out);

      --counter_add1 <= std_logic_vector(unsigned(counter_out) + "0000001");
      counter_adder : entity work.ADDER_N generic map(N => 7) 
      port map(a => counter_out, 
               b => "0000001", 
               c_in => '0', s => counter_add1, Ovrf => open );

      adder_subtractor : entity work.ADDER_SUBTR 
        generic map (N => 64) 
        port map(addsub => add_OR_sub, 
        a => AC_out, b => BR_out, 
        s => addsub_out, overflow => open, 
        c_out => open);

      BR_reg: entity work.reg_64b port map(BR_in, load, clock, clear, BR_out); 
      QR_reg: entity work.reg_65b port map(QR_in, load, clock, clear, QR_out);
      AC_reg: entity work.reg_64b port map(AC_in, '1', clock, clear, AC_out);
      
      result <= AC_out & QR_out(64 downto 1);

end architecture booths_algorithm;