-- File       : multiplier_divider.vhd

-- Multiplier:
-- 1. If the least-significant bit of A is 1, then register B, containing bn-1 bn-2...b0 is added to P; otherwise
-- 00...00 is added to P.
-- 2. The sum is placed back into P.
-- Registers P and A are shifted right, with the carry-out of the sum being moved into the high-order bit
-- of P, the low-order bit of P being moved into register A, and the rightmost bit of A, which is not used
-- in the rest of the algorithm, being shifted out.
-- Divider:
-- a/b, a in A, b in B, 0 in P. Produces one quotient bit at a time in A, remainder In P.
-- 1. Shift the register pair (P,A) one bit left.
-- 2. Subtract the content of register B (which is bn-1 bn-2...b0) from register P, putting the result back
-- into P.
-- 3. If the result of step 2 is negative, set the low-order bit of A to 0, otherwise to 1.
-- 4. If the result of step 2 is negative, restore the old value of P by adding the contents of register B
-- back into P.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.common.all;


entity multiplier_divider is
	port (
  clock : in std_logic;
  clear : in std_logic;
  A : in std_logic_vector(63 downto 0 );
  B : in std_logic_vector(63 downto 0 );
  IsM : in std_logic;
  IsD : in std_logic;
  IsSignedOp : in std_logic;
  DorW : in std_logic;
  result : out std_logic_vector(127 downto 0);
  BUSY : out std_logic;
  exc_type : out exc_type_t
  );
end entity multiplier_divider;

architecture behavioural of multiplier_divider is

  signal IsMorD : std_logic                                               := '0';
  signal counter_in, counter_out : std_logic_vector(6 downto 0)           := (others => '0');
  signal B_in, B_out : std_logic_vector(63 downto 0)                      := (others => '0');
  signal accumulator_in, accumulator_out : std_logic_vector(127 downto 0) := (others => '0');
  signal add_OR_sub : std_logic                                           := '0';
  signal AND_ctrl : std_logic                                             := '1';
  signal operand_1, operand_2 : std_logic_vector(63 downto 0)             := (others => '0');
  signal addsub_out : std_logic_vector(63 downto 0)                       := (others => '0');
  signal CarryOut : std_logic         := '0';
  signal load : std_logic                                                 := '0';
  signal proc_counter_in : std_logic_vector(6 downto 0)                   := (others => '0');
  signal proc_B_in : std_logic_vector(63 downto 0)                        := (others => '0');
  signal proc_accumulator_in : std_logic_vector(127 downto 0)             := (others => '0');
  signal proc_add_OR_sub : std_logic                                      := '0';
  signal proc_AND_ctrl : std_logic                                        := '1';
  signal proc_operand_1 : std_logic_vector(63 downto 0)                   := (others => '0');
  signal proc_BUSY : std_logic                                            := '0';
  signal proc_load : std_logic                                            := '0';

  signal counter_add1 : std_logic_vector(6 downto 0)                      := (others => '0');
  signal signs_AB_in, signs_AB_out : std_logic_vector(1 downto 0)         := "00";
  signal proc_signs_AB_in : std_logic_vector(1 downto 0)                  := "00";
  signal proc_result : std_logic_vector(127 downto 0)                     := (others => '0');
  
  signal div_by_zero, proc_div_by_zero : std_logic                        := '0';
  signal proc_div_by_zero_result : std_logic_vector(127 downto 0)         := (others => '0');
  signal proc_exc_type : exc_type_t := EXC_NONE;

  begin
      IsMorD <= IsM OR IsD;

      --MSB <= 31 when DorW = '1' else 63;

      --Axored <= A XOR X"1111111111111111"; Bxored <= B XOR X"1111111111111111"; 

      -- add1A : entity work.ADDER_SUBTR 
      -- generic map (N => 64) 
      -- port map(addsub => '0', 
      -- a => Axored, b => X"0000000000000001", 
      -- s => A_in, overflow => open, 
      -- c_out => open); 
      -- add1B : entity work.ADDER_SUBTR 
      -- generic map (N => 64) port map('0', Bxored, X"0000000000000001", B_in, open, open); 

      process(A, B, counter_out, accumulator_out, IsSignedOp, DorW, IsM, IsD, IsMorD, counter_add1, CarryOut, addsub_out)
        variable A_tmp, B_tmp: unsigned(63 downto 0) := (others => '0');
        variable allone_debug : std_logic_vector(63 downto 0) := (others => '1');
        variable MSB : integer := 0;
      begin

        proc_load <= '0';
        proc_div_by_zero <= '0';
        proc_BUSY <= '0';

        if(DorW ='1') then MSB := 31; else MSB := 63; end if;

        if(counter_out = "0000000" AND IsD = '1' AND DorW = '1' AND B(31 downto 0) = X"00000000") OR 
          (counter_out = "0000000" AND IsD = '1' AND B = X"0000000000000000") then
          proc_div_by_zero <= '1'; -- if dividng by zero will set a default result value
        
  
        elsif(IsMorD = '1') then  -- could maybe remove this if and put IsMorD in the load of the registers
          if(counter_out = "0000000")  then -- initialize
            ---- If inputs are negative turn them to positive ----
            A_tmp := unsigned(A);
            B_tmp := unsigned(B);
            
            if(IsSignedOp = '1' AND A(MSB) = '1') then
              A_tmp := unsigned(A XOR allone_debug);
              A_tmp := A_tmp + X"0000000000000001"; end if;
            if(IsSignedOp = '1' AND B(MSB) = '1') then 
              B_tmp := unsigned(B XOR allone_debug);
              B_tmp := B_tmp + X"0000000000000001"; end if;
            
            proc_load <= '1';                                                   -- storing in B and signs_AB registers:
            proc_signs_AB_in <= (A(MSB), B(MSB));                               -- store signs for the end
            if(DorW = '1') then  -- Operation on word                   
              proc_B_in <= (X"00000000" & std_logic_vector(B_tmp(31 downto 0)));  -- store value of B
              proc_accumulator_in <= (X"000000000000000000000000" & std_logic_vector(A_tmp(31 downto 0)));  -- initialize accumulator with A
            else                 -- Operation on double
              proc_B_in <= std_logic_vector(B_tmp);                               -- store value of B
              proc_accumulator_in <= (X"0000000000000000" & std_logic_vector(A_tmp));
            end if;
            proc_BUSY <= '1';                                            -- signal the mul/div is running from now on. Will stall pipeline
            proc_counter_in <= "0000001";                                -- add one to counter
            proc_add_OR_sub <= '-';
            proc_AND_ctrl <= '-';
            proc_operand_1 <= (others => '-');
          
          elsif(DorW = '1' AND counter_out(5) = '1' AND counter_out(0) = '1') then -- Operation on words, counter_out = 33. Finished a multiplication/division           
            proc_load <= '0';               -- nothing to load in B and signs registers
            proc_B_in <= (others => '-');
            proc_signs_AB_in <= (others => '-');
            proc_accumulator_in <= (others => '-');
            proc_BUSY <= '0';               -- signal the operation is done
            proc_counter_in <= "0000000";   -- reset counter
            proc_add_OR_sub <= '-';
            proc_AND_ctrl <= '-';
            proc_operand_1 <= (others => '-');

          elsif(counter_out(6) = '1' AND counter_out(0) = '1') then -- Operation on doubles, counter_out = 65. Finished a multiplication/division           
            proc_load <= '0';               -- nothing to load in B and signs registers
            proc_B_in <= (others => '-');
            proc_signs_AB_in <= (others => '-');
            proc_accumulator_in <= (others => '-');
            proc_BUSY <= '0';               -- signal the operation is done
            proc_counter_in <= "0000000";   -- reset counter
            proc_add_OR_sub <= '-';
            proc_AND_ctrl <= '-';
            proc_operand_1 <= (others => '-');
          
          elsif(IsM = '1') then  

          ---- MULTIPLICATION LOGIC -------------------------------------------------------------

            proc_BUSY <= '1';
            proc_load <= '0';         -- nothing to load. The correct values are loaded at initialization
            proc_B_in <= (others => '-');
            proc_signs_AB_in <= (others => '-');
            
            proc_counter_in <= counter_add1;      -- add 1 to counter

            proc_AND_ctrl <= accumulator_out(0);  -- this is the AND between the LSB of A and the 64 bits of B. --
                                                  -- if LSB is 1 we sum B, otherwise we sum 0                   --
            proc_add_OR_sub <= '0';               -- adder-subtractor will perform addition
            if(DorW = '1') then -- Operation on word
              proc_operand_1 <= (X"00000000" & accumulator_out(63 downto 32));
            -- Look at double first for comment --
              proc_accumulator_in <= (X"0000000000000000" & addsub_out(32) & addsub_out(31 downto 0) & accumulator_out(31 downto 1)); -- shifted right multiplier and partial product

            else -- Operation on double
              proc_operand_1 <= accumulator_out(127 downto 64);
            -- The result of the adder plus the carryout bit are wired back to the accumulator --
            -- register's sixtyfive bits numbered [127 - 63], in a way that includes a shift   --
            -- right, where the LSB of the accumulator gets pushed out                         -- 
              proc_accumulator_in <= (CarryOut & addsub_out & accumulator_out(63 downto 1)); -- shifted right multiplier and partial product
            end if;
  
          elsif(IsD = '1') then
          
          ---- DIVISION LOGIC -------------------------------------------------------------

            proc_BUSY <= '1';
            proc_load <= '0';       -- nothing to load. The correct values are loaded at initialization
            proc_B_in <= (others => '-');
            proc_signs_AB_in <= (others => '-');
            proc_counter_in <= counter_add1;
            proc_add_OR_sub <= '1'; -- adder-subtractor will perform subtraction
            proc_AND_ctrl <= '1';   -- B will go inside adder-subtractor 
            if(DorW = '1') then -- Operation on words  

              proc_operand_1 <= (X"00000000" & accumulator_out(62 downto 31)); -- in case of division the accumulator has to go trough shift left before entering the adder-subtractor
              if(addsub_out(31) = '1') then -- subtraction result negative
                proc_accumulator_in(0) <= '0'; -- LSB of accumulator will be set to 0
                proc_accumulator_in(127 downto 32) <= (X"0000000000000000" & accumulator_out(62 downto 31)); -- will put back in left half of accum what was before (but shifted left)
              else                          -- subtraction result positive
                proc_accumulator_in(0) <= '1'; -- LSB of accumulator will be set to  1
                proc_accumulator_in(127 downto 32) <= (X"0000000000000000" & addsub_out(31 downto 0)); -- result of sub will go in left half of accumulator
              end if;
              proc_accumulator_in(31 downto 1) <= accumulator_out(30 downto 0); -- right part of accumulator will get what was before but shifted left. LSB was set according to above
            
            else -- Operation on double

              proc_operand_1 <= accumulator_out(126 downto 63); -- in case of division the accumulator has to go trough shift left before entering the adder-subtractor
              if(addsub_out(63) = '1') then -- subtraction result negative
                proc_accumulator_in(0) <= '0'; -- LSB of accumulator will be set to 0
                proc_accumulator_in(127 downto 64) <= accumulator_out(126 downto 63); -- will put back in left half of accum what was before (but shifted left)
              else                          -- subtraction result positive
                proc_accumulator_in(0) <= '1'; -- LSB of accumulator will be set to  1
                proc_accumulator_in(127 downto 64) <= addsub_out(63 downto 0); -- result of sub will go in left half of accumulator
              end if;
              proc_accumulator_in(63 downto 1) <= accumulator_out(62 downto 0); -- right part of accumulator will get what was before but shifted left. LSB was set according to above
            
            end if;
          
          end if;

        else -- IsMorD = 0
          proc_counter_in <= "0000000";
          proc_BUSY <= '0';
          proc_load <= '0';
          proc_B_in <= (others => '-');
          proc_signs_AB_in <= (others => '-');
          proc_accumulator_in <= (others => '-');
          proc_add_OR_sub <= '-';
          proc_AND_ctrl <= '-';           
          proc_operand_1 <= (others => '-');

        end if;

      end process;

      load <= proc_load;
      B_in <= proc_B_in;
      signs_AB_in <= proc_signs_AB_in;
      accumulator_in <= proc_accumulator_in;
      counter_in <= proc_counter_in;
      operand_1 <= proc_operand_1;
      BUSY <= proc_BUSY;
      add_OR_sub <= proc_add_OR_sub;
      AND_ctrl <= proc_AND_ctrl;
      div_by_zero <= proc_div_by_zero;


      B_reg : entity work.reg_64b port map(B_in, load, clock, clear, B_out);
      
      addsub_operand_2_AND_1x64 : entity work.AND_1xN port map(b => AND_ctrl, v => B_out, v_out => operand_2);

      accumulator_reg   : entity work.reg_128b port map(accumulator_in, '1', clock, clear, accumulator_out);
      
      counter_reg : entity work.reg_7b port map(counter_in, '1', clock, clear, counter_out);

      --counter_add1 <= std_logic_vector(unsigned(counter_out) + "0000001");
      counter_adder : entity work.ADDER_N generic map(N => 7) 
                      port map(a => counter_out, 
                               b => "0000001", 
                               c_in => '0', s => counter_add1, Ovrf => open );

      adder_subtractor : entity work.ADDER_SUBTR 
        generic map (N => 64) 
        port map(addsub => add_OR_sub, 
        a => operand_1, b => operand_2, 
        s => addsub_out, overflow => open, 
        c_out => CarryOut);
      
      signs_AB_reg : entity work.reg_2b port map(signs_AB_in, load, clock, clear, signs_AB_out);
      

      result_sign_handle_proc : process(signs_AB_out, accumulator_out, IsSignedOp) is
        variable result_tmp : unsigned(127 downto 0) := (others => '0');
        variable allone_debug : std_logic_vector(127 downto 0) := (others => '1');

      begin
        if(IsSignedOp = '1') then
          -- If signs of A xor B where negative turn the output to negative --
          result_tmp := unsigned(accumulator_out XOR allone_debug);
          result_tmp := result_tmp + X"0000000000000001";
          case signs_AB_out is
            when "10"    => proc_result <= std_logic_vector(result_tmp);
            when "01"    => proc_result <= std_logic_vector(result_tmp);
            when others  => proc_result <= accumulator_out;
          end case;
        else 
        proc_result <= accumulator_out;
        end if;
      end process;
      
      result_div_by_zero_handle_proc : process(div_by_zero, DorW) is
      begin
        proc_exc_type <= EXC_NONE;
        if(div_by_zero = '1' AND DorW = '1') then
          proc_div_by_zero_result <= (X"0000000000000000" & A(31 downto 0) & X"FFFFFFFF");
          proc_exc_type <= DIVW_BY_0;
        elsif(div_by_zero = '1') then
          proc_div_by_zero_result <= (A & X"FFFFFFFFFFFFFFFF");
          proc_exc_type <= DIV_BY_0;
        end if;
      end process;

      result <= proc_div_by_zero_result when div_by_zero = '1' else
                proc_result             when div_by_zero = '0';
      
      exc_type <= proc_exc_type;

end architecture behavioural;