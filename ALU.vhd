library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity ALU is
	port (
    clock, clear : in std_logic;
		operand_1, operand_2 : in std_logic_vector(63 downto 0);
		ALU_func : in std_logic_vector(4 downto 0);
		ALU_output : out std_logic_vector(63 downto 0);
    Stall_ALU  : out std_logic;
    exc_type : out exc_type_t
	);
end entity ALU;

------- CONFIGURATION WITH SEPARATED MULTIPLIER AND DIVIDER. IT'S NOT THE DEFAULT ------

architecture separated_mul_div of ALU is
  signal o1, o2 : std_logic_vector(63 downto 0) := (others => '0'); -- signals for the operands to be used as input to the adder-subtractor or multiplier/divisior
	signal proc_o1, proc_o2 : std_logic_vector(63 downto 0) := (others => '0'); -- internal to process
  signal internal_ALU_output : std_logic_vector(63 downto 0) := (others => '0');
  signal IsM, proc_IsM : std_logic := '0';               -- signals if it is a multiplication
  signal IsD, proc_IsD : std_logic := '0';               -- signals if it is a division
  signal IsSignedOp, proc_IsSignedOp : std_logic := '0'; -- signals if mul/div operation is signed or unsigned
  signal D_or_W, proc_D_or_W : std_logic := '0'; -- signals if mul/div operation is on Double(64-bit) or on Word(32-bit)
  signal M_result, D_result : std_logic_vector(127 downto 0) := (others => '0');    -- temporary 128 bit result from the multiplier/divider
  signal IsSub, proc_IsSub : std_logic := '0'; -- ctrl for adder-subtractor. 0 is addition, 1 is subtraction
  signal addsub_result : std_logic_vector(63 downto 0) := (others => '0');
  signal addsub_CarryOut, addsub_Ovrf, addsub_Ovrf_W : std_logic := '0';
  signal Stall_ALU_M, Stall_ALU_D : std_logic := '0'; -- Signals for BUSY output of multiplier and divider. An OR will give the final output Stall_ALU

  signal proc_exc_type : exc_type_t := EXC_NONE;
  signal exc_type_D : exc_type_t := EXC_NONE; -- for exception_type output of divider

begin

	process (operand_1, operand_2, ALU_func, addsub_result, addsub_CarryOut, addsub_Ovrf, M_result, D_result) is
    -- variable ou1, ou2   : unsigned(63 downto 0);
    -- variable os1, os2   : signed(63 downto 0);
    -- variable ows1, ows2 : signed(31 downto 0);
    -- variable owu1, owu2 : unsigned(31 downto 0);
    variable tmpw : std_logic_vector(31 downto 0) := (others => '0');
    variable ow1, ow2 : std_logic_vector(31 downto 0) := (others => '0');
    
	begin

    -- ou1 := unsigned(operand_1);
    -- os1 := signed(operand_1);
    -- ows1 := signed(operand_1(31 downto 0));
    -- owu1 := unsigned(operand_1(31 downto 0));

    -- ou2 := unsigned(operand_2);
    -- os2 := signed(operand_2);
    -- ows2 := signed(operand_2(31 downto 0));
    -- owu2 := unsigned(operand_2(31 downto 0));

    ow1 := operand_1(31 downto 0);
    ow2 := operand_2(31 downto 0);


    --tmpw := std_logic_vector(ows1 + ows2);

    proc_IsM <= '0';
    proc_IsD <= '0';
    proc_D_or_W <= '0';
    proc_IsSignedOp <= '1';
    proc_o1 <= operand_1;
    proc_o2 <= operand_2;
    proc_IsSub <= '0';
    proc_exc_type <= EXC_NONE; -- exception


    case(ALU_func) is

      when func_add =>
        internal_ALU_output <= addsub_result;
        if(addsub_Ovrf = '1') then
          proc_exc_type <= ADD_OVF;
        end if;

      when func_sub =>
        proc_IsSub <= '1';
        internal_ALU_output <= addsub_result;
        if(addsub_Ovrf = '1') then
          proc_exc_type <= SUB_OVF;
        end if;

      when func_addw =>
        proc_o1 <= X"00000000" & ow1; -- will load in the 64-bit adder-sub the least significant 32 bits of the operand
        proc_o2 <= X"00000000" & ow2;
          for i in 63 downto 32 loop
            internal_ALU_output(i) <= addsub_result(31);
          end loop;
        internal_ALU_output(31 downto 0) <= addsub_result(31 downto 0);
        if(addsub_Ovrf_W = '1') then
          proc_exc_type <= ADDW_OVF;
        end if;

      when func_subw =>
        proc_o1 <= X"00000000" & ow1;
        proc_o2 <= X"00000000" & ow2;
        proc_IsSub <= '1';
          for i in 63 downto 32 loop
            internal_ALU_output(i) <= addsub_result(31);
          end loop;
        internal_ALU_output(31 downto 0) <= addsub_result(31 downto 0);
        if(addsub_Ovrf_W = '1') then
          proc_exc_type <= SUBW_OVF;
        end if;

      when func_mul =>
        proc_IsM <= '1';
        internal_ALU_output <= M_result(63 downto 0);
     
      when func_mulh =>   -- h stands for high part of the 128-bit result
        proc_IsM <= '1';
        internal_ALU_output <= M_result(127 downto 64);
      
      when func_mulhu => 
        proc_IsM <= '1';
        internal_ALU_output <= M_result(127 downto 64);

      when func_mulhsu =>
        proc_IsM <= '1';
        proc_D_or_W <= '0';
        internal_ALU_output <= M_result(127 downto 64);

      when func_mulw =>
        proc_o1 <= X"00000000" & ow1;
        proc_o2 <= X"00000000" & ow2;
        proc_IsM <= '1';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= M_result(31);
        end loop;
        internal_ALU_output(31 downto 0) <= M_result(31 downto 0);
      
      when func_rem =>
        proc_IsD <= '1';
        internal_ALU_output <= D_result(127 downto 64);
        proc_exc_type <= exc_type_D;

      when func_remu =>
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        internal_ALU_output <= D_result(127 downto 64);
        proc_exc_type <= exc_type_D;

      when func_remuw =>
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= D_result(63);
        end loop;
        internal_ALU_output(31 downto 0) <= D_result(63 downto 32);
        proc_exc_type <= exc_type_D;

      when func_remw =>
        proc_IsD <= '1';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= D_result(63);
        end loop;
        internal_ALU_output(31 downto 0) <= D_result(63 downto 32);
        proc_exc_type <= exc_type_D;

      when func_div =>
        proc_IsD <= '1';
        internal_ALU_output <= D_result(63 downto 0);
        proc_exc_type <= exc_type_D;

      when func_divu =>
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        internal_ALU_output <= D_result(63 downto 0);
        proc_exc_type <= exc_type_D;

      when func_divw =>
        proc_IsD <= '1';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= D_result(31);
        end loop;
        internal_ALU_output(31 downto 0) <= D_result(31 downto 0);
        proc_exc_type <= exc_type_D;

      when func_divuw => 
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= D_result(31);
        end loop;
        internal_ALU_output(31 downto 0) <= D_result(31 downto 0);
        proc_exc_type <= exc_type_D;

      when func_sll =>
        internal_ALU_output <= std_logic_vector(shift_left(unsigned(proc_o1), to_integer(unsigned(proc_o2))));

      when func_sllw =>
        tmpw := std_logic_vector(shift_left(unsigned(ow1), to_integer(unsigned(ow2))));            
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= tmpw(31);
        end loop;
        internal_ALU_output(31 downto 0) <= tmpw;

      when func_slt =>
        proc_IsSub <= '1';
        if (addsub_Ovrf ='0' AND addsub_result(63) = '1') OR (addsub_Ovrf ='1' AND addsub_CarryOut = '1') then
          internal_ALU_output <= X"0000000000000001";
        else
          internal_ALU_output <= (others => '0');
        end if;

      when func_sltu =>
        proc_IsSub <= '1';
        if addsub_result(63) = '1' then
          internal_ALU_output <= X"0000000000000001";
        else
          internal_ALU_output <= (others => '0');
        end if;

      when func_sra =>
        internal_ALU_output <= std_logic_vector(shift_right(signed(proc_o1), to_integer(unsigned(proc_o2))));
      
      when func_sraw =>
        tmpw := std_logic_vector(shift_right(signed(ow1), to_integer(unsigned(ow2))));            
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= tmpw(31);
        end loop;
        internal_ALU_output(31 downto 0) <= tmpw;

      when func_srl =>
        internal_ALU_output <= std_logic_vector(shift_right(unsigned(proc_o1), to_integer(unsigned(proc_o2))));
      
      when func_srlw =>
        tmpw := std_logic_vector(shift_right(unsigned(ow1), to_integer(unsigned(ow2))));              
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= tmpw(31);
        end loop;
        internal_ALU_output(31 downto 0) <= tmpw;

      when func_xor =>
        internal_ALU_output <= proc_o1 XOR proc_o2;

      when func_or =>
        internal_ALU_output <= proc_o1 OR proc_o2;

      when func_and =>
        internal_ALU_output <= proc_o1 AND proc_o2;     

      when "-----" => internal_ALU_output <= (others => '-');

      when others  => internal_ALU_output <= (others => 'U');

    end case; -- eof case(funct3) -- eof R-type/I-type
  
  end process;

  o1 <= proc_o1;
  o2 <= proc_o2;
  IsSub <= proc_IsSub;
  IsM <= proc_IsM;
  IsD <= proc_IsD;
  IsSignedOp <= proc_IsSignedOp;
  D_or_W <= proc_D_or_W;

  Booth_multiplier : entity work.booth_multiplier
                        port map( clock => clock,
                        clear => clear,
                        A => o1,
                        B => o2,
                        IsM => IsM,
                        DorW => D_or_W,
                        result => M_result,
                        BUSY => Stall_ALU_M);
  
  divider         : entity work.divider
                        port map( clock => clock,
                        clear => clear,
                        A => o1,
                        B => o2,
                        IsD => IsD,
                        IsSignedOp => IsSignedOp,
                        DorW => D_or_W,
                        result => D_result,
                        BUSY => Stall_ALU_D,
                        exc_type => exc_type_D);

  adder_subtractor : entity work.ADDER_SUBTR_W_OVRF
                      port map(addsub => IsSub, 
                      a => o1, b => o2, 
                      s => addsub_result, overflow => addsub_Ovrf,
                      overflow_Word => addsub_Ovrf_W, 
                      c_out => addsub_CarryOut);

  Stall_ALU <= Stall_ALU_M OR Stall_ALU_D;
  ALU_output <= internal_ALU_output;
  exc_type <= proc_exc_type;

end architecture separated_mul_div;


------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

------------- CONFIGURATION WITH COMBINED MULTIPLIER-DIVIDER. IT'S THE DEFAULT --------------

architecture Behavioral of ALU is
  signal o1, o2 : std_logic_vector(63 downto 0) := (others => '0'); -- signals for the operands to be used as input to the adder-subtractor or multiplier/divisior
	signal proc_o1, proc_o2 : std_logic_vector(63 downto 0) := (others => '0'); -- internal to process
  signal internal_ALU_output : std_logic_vector(63 downto 0) := (others => '0');
  signal IsM, proc_IsM : std_logic := '0';               -- signals if it is a multiplication
  signal IsD, proc_IsD : std_logic := '0';               -- signals if it is a division
  signal IsSignedOp, proc_IsSignedOp : std_logic := '0'; -- signals if mul/div operation is signed or unsigned
  signal D_or_W, proc_D_or_W : std_logic := '0'; -- signals if mul/div operation is on double or on word
  signal MD_result : std_logic_vector(127 downto 0) := (others => '0');    -- temporary 128 bit result from the multiplier/divider
  signal IsSub, proc_IsSub : std_logic := '0'; -- ctrl for adder-subtractor. 0 is addition, 1 is subtraction
  signal addsub_result : std_logic_vector(63 downto 0) := (others => '0');
  signal addsub_CarryOut, addsub_Ovrf, addsub_Ovrf_W : std_logic := '0';

  signal proc_exc_type : exc_type_t := EXC_NONE;
  signal exc_type_D : exc_type_t := EXC_NONE; -- for exc_type output of mul-divider

begin

	process (operand_1, operand_2, ALU_func, addsub_result, addsub_CarryOut, addsub_Ovrf, addsub_Ovrf_W, MD_result) is
    variable tmpw : std_logic_vector(31 downto 0) := (others => '0');
    variable ow1, ow2 : std_logic_vector(31 downto 0) := (others => '0');
    
	begin

    ow1 := operand_1(31 downto 0);
    ow2 := operand_2(31 downto 0);


    proc_IsM <= '0';
    proc_IsD <= '0';
    proc_D_or_W <= '0';
    proc_IsSignedOp <= '1';
    proc_o1 <= operand_1;
    proc_o2 <= operand_2;
    proc_IsSub <= '0';
    proc_exc_type <= EXC_NONE;


    case(ALU_func) is

      when func_add =>
        internal_ALU_output <= addsub_result;
        if(addsub_Ovrf = '1') then
          proc_exc_type <= ADD_OVF;
        end if;
      
      when func_sub =>
        proc_IsSub <= '1';
        internal_ALU_output <= addsub_result;
        if(addsub_Ovrf = '1') then
          proc_exc_type <= SUB_OVF;
        end if;
      
      when func_addw =>
        proc_o1 <= X"00000000" & ow1; -- will load in the 64-bit adder-sub the least significant 32 bits of the operand
        proc_o2 <= X"00000000" & ow2;
          for i in 63 downto 32 loop
            internal_ALU_output(i) <= addsub_result(31);
          end loop;
        internal_ALU_output(31 downto 0) <= addsub_result(31 downto 0);
        if(addsub_Ovrf_W = '1') then
          proc_exc_type <= ADDW_OVF;
        end if;
      
      when func_subw =>
        proc_o1 <= X"00000000" & ow1;
        proc_o2 <= X"00000000" & ow2;
        proc_IsSub <= '1';
          for i in 63 downto 32 loop
            internal_ALU_output(i) <= addsub_result(31);
          end loop;
        internal_ALU_output(31 downto 0) <= addsub_result(31 downto 0);
        if(addsub_Ovrf_W = '1') then
          proc_exc_type <= SUBW_OVF;
        end if;
      
      when func_mul =>
        proc_IsM <= '1';
        internal_ALU_output <= MD_result(63 downto 0);
     
      when func_mulh =>   -- h stands for high part of the 128-bit result
        proc_IsM <= '1';
        internal_ALU_output <= MD_result(127 downto 64);
      
      when func_mulhu => 
        proc_IsM <= '1';
        proc_IsSignedOp <= '0';
        internal_ALU_output <= MD_result(127 downto 64);

      when func_mulhsu =>
        proc_IsM <= '1';
        proc_D_or_W <= '0';
        internal_ALU_output <= MD_result(127 downto 64);

      when func_mulw =>
        proc_o1 <= X"00000000" & ow1;
        proc_o2 <= X"00000000" & ow2;
        proc_IsM <= '1';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= MD_result(31);
        end loop;
        internal_ALU_output(31 downto 0) <= MD_result(31 downto 0);
      
      when func_rem =>
        proc_IsD <= '1';
        internal_ALU_output <= MD_result(127 downto 64);
        proc_exc_type <= exc_type_D;
      
      when func_remu =>
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        internal_ALU_output <= MD_result(127 downto 64);
        proc_exc_type <= exc_type_D;

      when func_remuw =>
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= MD_result(63);
        end loop;
        internal_ALU_output(31 downto 0) <= MD_result(63 downto 32);
        proc_exc_type <= exc_type_D;

      when func_remw =>
        proc_IsD <= '1';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= MD_result(63);
        end loop;
        internal_ALU_output(31 downto 0) <= MD_result(63 downto 32);
        proc_exc_type <= exc_type_D;
      
      when func_div =>
        proc_IsD <= '1';
        internal_ALU_output <= MD_result(63 downto 0);
        proc_exc_type <= exc_type_D;
      
      when func_divu =>
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        internal_ALU_output <= MD_result(63 downto 0);
        proc_exc_type <= exc_type_D;
    
      when func_divw =>
        proc_IsD <= '1';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= MD_result(31);
        end loop;
        internal_ALU_output(31 downto 0) <= MD_result(31 downto 0);
        proc_exc_type <= exc_type_D;

      when func_divuw => 
        proc_IsD <= '1';
        proc_IsSignedOp <= '0';
        proc_D_or_W <= '1';
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= MD_result(31);
        end loop;
        internal_ALU_output(31 downto 0) <= MD_result(31 downto 0);
        proc_exc_type <= exc_type_D;

      when func_sll =>
        internal_ALU_output <= std_logic_vector(shift_left(unsigned(proc_o1), to_integer(unsigned(proc_o2))));

      when func_sllw =>
        tmpw := std_logic_vector(shift_left(unsigned(ow1), to_integer(unsigned(ow2))));            
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= tmpw(31);
        end loop;
        internal_ALU_output(31 downto 0) <= tmpw;

      when func_slt =>
        proc_IsSub <= '1';
        if (addsub_Ovrf ='0' AND addsub_result(63) = '1') OR (addsub_Ovrf ='1' AND addsub_CarryOut = '1') then
          internal_ALU_output <= X"0000000000000001";
        else
          internal_ALU_output <= (others => '0');
        end if;

      when func_sltu =>
        proc_IsSub <= '1';
        if addsub_result(63) = '1' then
          internal_ALU_output <= X"0000000000000001";
        else
          internal_ALU_output <= (others => '0');
        end if;

      when func_sra =>
        internal_ALU_output <= std_logic_vector(shift_right(signed(proc_o1), to_integer(unsigned(proc_o2))));
      
      when func_sraw =>
        tmpw := std_logic_vector(shift_right(signed(ow1), to_integer(unsigned(ow2))));            
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= tmpw(31);
        end loop;
        internal_ALU_output(31 downto 0) <= tmpw;

      when func_srl =>
        internal_ALU_output <= std_logic_vector(shift_right(unsigned(proc_o1), to_integer(unsigned(proc_o2))));
      
      when func_srlw =>
        tmpw := std_logic_vector(shift_right(unsigned(ow1), to_integer(unsigned(ow2))));              
        for i in 63 downto 32 loop
          internal_ALU_output(i) <= tmpw(31);
        end loop;
        internal_ALU_output(31 downto 0) <= tmpw;

      when func_xor =>
        internal_ALU_output <= proc_o1 XOR proc_o2;

      when func_or =>
        internal_ALU_output <= proc_o1 OR proc_o2;

      when func_and =>
        internal_ALU_output <= proc_o1 AND proc_o2;     

      when "-----" => internal_ALU_output <= (others => '-');

      when others  => 
        internal_ALU_output <= (others => '0');
        --report "WARNING! The ALU has received order to operate an undefined function! It will output a null result..." severity warning;

    end case; -- eof case(funct3) -- eof R-type/I-type
  
  end process;

  o1 <= proc_o1;
  o2 <= proc_o2;
  IsSub <= proc_IsSub;
  IsM <= proc_IsM;
  IsD <= proc_IsD;
  IsSignedOp <= proc_IsSignedOp;
  D_or_W <= proc_D_or_W;
  

  multiplier_divider : entity work.multiplier_divider 
                        port map( clock => clock,
                        clear => clear,
                        A => o1,
                        B => o2,
                        IsM => IsM,
                        IsD => IsD,
                        IsSignedOp => IsSignedOp,
                        DorW => D_or_W,
                        result => MD_result,
                        BUSY => Stall_ALU,
                        exc_type => exc_type_D);

  adder_subtractor : entity work.ADDER_SUBTR_W_OVRF 
                      port map(addsub => IsSub, 
                      a => o1, b => o2, 
                      s => addsub_result, overflow => addsub_Ovrf,
                      overflow_Word => addsub_Ovrf_W, 
                      c_out => addsub_CarryOut);

  ALU_output <= internal_ALU_output;
  exc_type <= proc_exc_type;
  
end architecture Behavioral;

configuration ALU_default_CFG of ALU is
  for Behavioral
  end for;
end ALU_default_CFG;


