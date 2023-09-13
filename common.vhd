library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ALL;


package common is
  constant MEM_SIZE_in_bytes : integer := 4096;
  --constant STATIC_DATA_begin : integer := 512;
  constant MEM_SIZE_in_banks : integer := MEM_SIZE_in_bytes/8; -- a membank is made of 8 bytes -- 4096/8=512
  constant MEMBANK_ADDRESS_range : integer := integer(ceil(log2(real(MEM_SIZE_in_banks))))-1; -- # of bits minus 1 needed to address MEM_SIZE_in_banks -- =8

  type t_regbank_array is array (0 to 31) of std_logic_vector(63 downto 0);

  ------------ OPCODES constants ---------------
  constant op_load     : std_logic_vector(6 downto 0) := "0000011";
  --constant op_misc_mem : std_logic_vector(6 downto 0) := "0001111";
  constant op_imm      : std_logic_vector(6 downto 0) := "0010011";
  constant op_imm_w    : std_logic_vector(6 downto 0) := "0011011";
  constant op_auipc    : std_logic_vector(6 downto 0) := "0010111";
  constant op_store    : std_logic_vector(6 downto 0) := "0100011";
  constant op_Rtype    : std_logic_vector(6 downto 0) := "0110011";
  constant op_lui      : std_logic_vector(6 downto 0) := "0110111";
  constant op_branch   : std_logic_vector(6 downto 0) := "1100011";
  constant op_jalr     : std_logic_vector(6 downto 0) := "1100111";
  constant op_jal      : std_logic_vector(6 downto 0) := "1101111";
  --constant op_system : std_logic_vector(6 downto 0) := "1110011";
  constant op_RWtype   : std_logic_vector(6 downto 0) := "0111011";


  ---------------- ALU FUNCTION constants ---------------
  constant func_add     : std_logic_vector(4 downto 0) := "00010";
  constant func_sub     : std_logic_vector(4 downto 0) := "00110";
  constant func_addw    : std_logic_vector(4 downto 0) := "10010";
  constant func_subw    : std_logic_vector(4 downto 0) := "10110";
  constant func_mul     : std_logic_vector(4 downto 0) := "01000";
  constant func_mulh    : std_logic_vector(4 downto 0) := "01001";
  constant func_mulhu   : std_logic_vector(4 downto 0) := "01011";
  constant func_mulhsu  : std_logic_vector(4 downto 0) := "01010";
  constant func_mulw    : std_logic_vector(4 downto 0) := "10011";
  constant func_rem     : std_logic_vector(4 downto 0) := "11010";
  constant func_remu    : std_logic_vector(4 downto 0) := "11011";
  constant func_remuw   : std_logic_vector(4 downto 0) := "10101";
  constant func_remw    : std_logic_vector(4 downto 0) := "10100";
  constant func_div     : std_logic_vector(4 downto 0) := "11000";
  constant func_divu    : std_logic_vector(4 downto 0) := "11001";
  constant func_divw    : std_logic_vector(4 downto 0) := "10000";
  constant func_divuw   : std_logic_vector(4 downto 0) := "10001";
  constant func_sll     : std_logic_vector(4 downto 0) := "01101";
  constant func_sllw    : std_logic_vector(4 downto 0) := "11101";
  constant func_slt     : std_logic_vector(4 downto 0) := "00100";
  constant func_sltu    : std_logic_vector(4 downto 0) := "00111";
  constant func_sra     : std_logic_vector(4 downto 0) := "01111";
  constant func_sraw    : std_logic_vector(4 downto 0) := "11111";
  constant func_srl     : std_logic_vector(4 downto 0) := "01110";
  constant func_srlw    : std_logic_vector(4 downto 0) := "11110";
  constant func_xor     : std_logic_vector(4 downto 0) := "00011";
  constant func_or      : std_logic_vector(4 downto 0) := "00001";
  constant func_and     : std_logic_vector(4 downto 0) := "00000";

  ---------------- Types of Arithmetic Exceptions ---------------
  type exc_type_t is (EXC_NONE, ADD_OVF, ADDW_OVF, SUB_OVF, SUBW_OVF, DIV_BY_0, DIVW_BY_0);
  
end package common;