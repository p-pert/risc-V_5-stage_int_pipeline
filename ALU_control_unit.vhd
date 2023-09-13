-- File       : ALU_control_unit.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity ALU_control is
	port (
		ALUOp : in std_logic_vector(1 downto 0);
    insn_bit_30 : in std_logic;
    insn_bit_25 : in std_logic;
    funct3 : in std_logic_vector(2 downto 0);
    insn_bit_5 : in std_logic;
    insn_bit_3 : in std_logic;
		ALU_func   : out std_logic_vector(4 downto 0)
	);
end entity ALU_control;



architecture Behavioral of ALU_control is
  
	signal internal_ALU_func : std_logic_vector(4 downto 0) := (others => '0');
  
begin

	process (ALUOp, insn_bit_30, funct3, insn_bit_5, insn_bit_3) is

	begin

    case(ALUOp) is

      when "01" => --BRANCH
        internal_ALU_func <= func_add;         -- branch_comparator unit handles branches. 
        --internal_ALU_func <= (others => '-') -- The ALU result is meaningless

      when "00" => -- LOAD / STORE / JAL / JALR / AUIPC / LUI
        internal_ALU_func <= func_add; -- os1 + os2 64bit signed sum

      when "10" => -- R-type / I-type

        case (funct3) is

          when "000" => 
            if(insn_bit_30 = '1' AND insn_bit_5 = '1' AND insn_bit_3 = '1') then -- SUBW
                internal_ALU_func <= func_subw;
            elsif(insn_bit_30 = '1' AND insn_bit_5 = '1') then -- SUB
                internal_ALU_func <= func_sub;
            elsif(insn_bit_25 = '1' AND insn_bit_5 = '1' AND insn_bit_3 ='1') then -- MULW
                internal_ALU_func <= func_mulw;
            elsif(insn_bit_3 = '1') then -- ADDW/ADDIW
                internal_ALU_func <= func_addw;
            elsif(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- MUL
                internal_ALU_func <= func_mul;
            else --ADD/ADDI
                internal_ALU_func <= func_add;
            end if;

          when "001" => 
            if(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- MULH
                internal_ALU_func <= func_mulh;
            elsif(insn_bit_3 = '1') then -- SLLIW/SLLW
                internal_ALU_func <= func_sllw;
            else -- SLL/SLLI
                internal_ALU_func <= func_sll;
            end if;

          when "010" => 
            if(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- MULHSU
                internal_ALU_func <= func_mulhsu;
            else -- SLT/SLTI
                internal_ALU_func <= func_slt;
            end if;

          when "011" => 
            if(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- MULHU
                internal_ALU_func <= func_mulhu;
            else -- SLTU/SLTIU
                internal_ALU_func <= func_sltu;
            end if;

          when "100" =>
            if(insn_bit_25 = '1' AND insn_bit_5 = '1' AND insn_bit_3 ='1') then -- DIVW
                internal_ALU_func <= func_divw;
            elsif(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- DIV
                internal_ALU_func <= func_div;
            else -- XOR/XORI
                internal_ALU_func <= func_xor;
            end if;

          when "101" =>
            if(insn_bit_25 = '1' AND insn_bit_5 = '1' AND insn_bit_3 ='1') then -- DIVUW
                internal_ALU_func <= func_divuw;
            elsif(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- DIVU
                internal_ALU_func <= func_divu;
            elsif(insn_bit_30 = '1' AND insn_bit_3 = '1') then -- SRAIW/SRAW  
                internal_ALU_func <= func_sraw;
            elsif(insn_bit_30 = '1' AND insn_bit_5 = '1') then -- SRA/SRAI
                internal_ALU_func <= func_sra;
            elsif(insn_bit_3 = '1') then -- SRLIW/SRLW
                internal_ALU_func <= func_srlw;
            else -- SRL/SRLI
                internal_ALU_func <= func_srl;
            end if;
          
          when "110"  =>
            if(insn_bit_25 = '1' AND insn_bit_5 = '1' AND insn_bit_3 ='1') then -- REMW
                internal_ALU_func <= func_remw; 
            elsif(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- REM
                internal_ALU_func <= func_rem;
            else -- OR/ORI
                internal_ALU_func <= func_or;
            end if;            

          when "111"  =>
            if(insn_bit_25 = '1' AND insn_bit_5 = '1' AND insn_bit_3 ='1') then -- REMUW
                internal_ALU_func <= func_remuw;  
            elsif(insn_bit_25 = '1' AND insn_bit_5 = '1') then -- REMU
                internal_ALU_func <= func_remu;
            else -- AND/ANDI
                internal_ALU_func <= func_and;
            end if;

          when others => internal_ALU_func <= func_add; -- would be unsupported func3 bits, anyway other control lines should be at nop
        end case; -- eof case(funct3) -- eof R-type/I-type
        
      when "--" => internal_ALU_func <= (others => '-');
      when others => internal_ALU_func <= (others => 'U');
        
    end case; -- eof ALUOp
  
  end process;

  ALU_func <= internal_ALU_func;
  
end architecture Behavioral;
