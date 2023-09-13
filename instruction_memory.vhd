-- File       : instruction_memory.vhd
-- can uncomment/comment bubble_sort.c / arithm.c instructions 
-- (also instructions_NUM !)

library IEEE;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;


entity Instruction_Memory is
  port (
  pc_in: in std_logic_vector(63 downto 0);
  instruction_out: out  std_logic_vector(31 downto 0)
  );
end Instruction_Memory;

architecture Behavioral of Instruction_Memory is
  constant instructions_NUM : integer := 78; -- bubble_sort.c insn count
  --constant instructions_NUM : integer := 108; -- arithm.c program insn count


  type ROM_type is array (0 to instructions_NUM-1) of std_logic_vector(31 downto 0);
  constant rom_data: ROM_type:=(
  ----------------------------------------------------------------------------------
  -- bubble_sort.c      --instructions_NUM = 78
  ----------------------------------------------------------------------------------
    X"fd010113",          	--addi	sp,sp,-48
    X"02813423",          	--sd	s0,40(sp)
    X"03010413",          	--addi	s0,sp,48
    X"00300793",          	--li	a5,3
    X"fcf42823",          	--sw	a5,-48(s0)
    X"00500793",          	--li	a5,5
    X"fcf42a23",          	--sw	a5,-44(s0)
    X"00100793",          	--li	a5,1
    X"fcf42c23",          	--sw	a5,-40(s0)
    X"00200793",          	--li	a5,2
    X"fcf42e23",          	--sw	a5,-36(s0)
    X"00400793",          	--li	a5,4
    X"fef42023",          	--sw	a5,-32(s0)
    X"fe042623",          	--sw	zero,-20(s0)
    X"06e0006f", --"00000110111000000000000001101111",  -- 	j	.L2    --jal x0, 220  (immediate encoded here is 000000000000001101110 It is 110-decimal bec it gets shifted by <<1 in the datapath)
    X"fe042423",          	--sw	zero,-24(s0)      --.L6
    X"0560006f", --"00000101011000000000000001101111" -- 	j	.L3    --jal x0, 172
    X"fe842783",          	--lw	a5,-24(s0)        --.L5
    X"00279793",          	--slli	a5,a5,0x2
    X"ff078793",          	--addi	a5,a5,-16
    X"008787b3",          	--add	a5,a5,s0
    X"fe07a703",          	--lw	a4,-32(a5)
    X"fe842783",          	--lw	a5,-24(s0)
    X"0017879b",          	--addiw	a5,a5,1
    X"0007879b",          	--sext.w	a5,a5
    X"00279793",          	--slli	a5,a5,0x2
    X"ff078793",          	--addi	a5,a5,-16
    X"008787b3",          	--add	a5,a5,s0
    X"fe07a783",          	--lw	a5,-32(a5)
    X"02e7db63",  -- bge	a5,a4,.L4
    X"fe842783",          	--lw	a5,-24(s0)
    X"00279793",          	--slli	a5,a5,0x2
    X"ff078793",          	--addi	a5,a5,-16
    X"008787b3",          	--add	a5,a5,s0
    X"fe07a783",          	--lw	a5,-32(a5)
    X"fef42223",          	--sw	a5,-28(s0)
    X"fe842783",          	--lw	a5,-24(s0)
    X"0017879b",          	--addiw	a5,a5,1
    X"0007879b",          	--sext.w	a5,a5
    X"00279793",          	--slli	a5,a5,0x2
    X"ff078793",          	--addi	a5,a5,-16
    X"008787b3",          	--add	a5,a5,s0
    X"fe07a703",          	--lw	a4,-32(a5)
    X"fe842783",          	--lw	a5,-24(s0)
    X"00279793",          	--slli	a5,a5,0x2
    X"ff078793",          	--addi	a5,a5,-16
    X"008787b3",          	--add	a5,a5,s0
    X"fee7a023",          	--sw	a4,-32(a5)
    X"fe842783",          	--lw	a5,-24(s0)
    X"0017879b",          	--addiw	a5,a5,1
    X"0007879b",          	--sext.w	a5,a5
    X"00279793",          	--slli	a5,a5,0x2
    X"ff078793",          	--addi	a5,a5,-16
    X"008787b3",          	--add	a5,a5,s0
    X"fe442703",          	--lw	a4,-28(s0)
    X"fee7a023",          	--sw	a4,-32(a5)
    X"fe842783",          	--lw	a5,-24(s0)  --.L4
    X"0017879b",          	--addiw	a5,a5,1
    X"fef42423",          	--sw	a5,-24(s0)
    X"00400793",          	--li	a5,4        --.L3
    X"fec42703",          	--lw	a4,-20(s0)
    X"40e787bb",          	--subw	a5,a5,a4
    X"0007871b",          	--sext.w	a4,a5
    X"fe842783",          	--lw	a5,-24(s0)
    X"0007879b",          	--sext.w	a5,a5
    X"fae7c0e3",  -- blt a5,a4,-96 <.L5>      -48*4=-192 --> -192/2=-96 bec then it gets shifted
    X"fec42783",          	--lw	a5,-20(s0)
    X"0017879b",          	--addiw	a5,a5,1
    X"fef42623",          	--sw	a5,-20(s0)
    X"fec42783",          	--lw	a5,-20(s0)  --.L2
    X"0007871b",          	--sext.w	a4,a5
    X"00300793",          	--li	a5,3
    X"f8e7d7e3", --bge a5,a4, -114 <.L6>       -57*4/2=-114
    X"00000793",          	--li	a5,0
    X"00078513",          	--mv	a0,a5
    X"02813403",          	--ld	s0,40(sp)
    X"03010113",          	--addi	sp,sp,48  
    X"00000013"             --nop --addi x0, x0, 0
    --X"00008067"         	--ret --jalr x0, 0(x1)

  ----------------------------------------------------------------------------------
  -- arithm.c
  ----------------------------------------------------------------------------------

  -- X"f7010113",    --addi	sp,sp,-144
  -- X"08813423",    --sd	s0,136(sp)
  -- X"09010413",    --addi	s0,sp,144
  -- X"00300793",    --li	a5,3
  -- X"fef42623",    --sw	a5,-20(s0)
  -- X"00400793",    --li	a5,4
  -- X"fef42423",    --sw	a5,-24(s0)
  -- X"fec42783",    --lw	a5,-20(s0)
  -- X"00078713",    --mv	a4,a5
  -- X"fe842783",    --lw	a5,-24(s0)
  -- X"02f707bb",    --mulw	a5,a4,a5
  -- X"fef42223",    --sw	a5,-28(s0)
  -- X"fec42783",    --lw	a5,-20(s0)
  -- X"00078713",    --mv	a4,a5
  -- X"fe442783",    --lw	a5,-28(s0)
  -- X"02f747bb",    --divw	a5,a4,a5
  -- X"fef42423",    --sw	a5,-24(s0)
  -- X"fec42783",    --lw	a5,-20(s0)
  -- X"00078713",    --mv	a4,a5
  -- X"fe442783",    --lw	a5,-28(s0)
  -- X"02f767bb",    --remw	a5,a4,a5
  -- X"fef42623",    --sw	a5,-20(s0)
  -- X"fe842783",    --lw	a5,-24(s0)
  -- X"0037879b",    --addiw	a5,a5,3
  -- X"0007879b",    --sext.w	a5,a5
  -- X"fe442703",    --lw	a4,-28(s0)
  -- X"02f707bb",    --mulw	a5,a4,a5
  -- X"0007879b",    --sext.w	a5,a5
  -- X"fec42703",    --lw	a4,-20(s0)
  -- X"00f707bb",    --addw	a5,a4,a5
  -- X"0007871b",    --sext.w	a4,a5
  -- X"fe442783",    --lw	a5,-28(s0)
  -- X"0c87879b",    --addiw	a5,a5,200
  -- X"0007879b",    --sext.w	a5,a5
  -- X"fec42683",    --lw	a3,-20(s0)
  -- X"02d7c7bb",    --divw	a5,a5,a3
  -- X"0007879b",    --sext.w	a5,a5
  -- X"40f707bb",    --subw	a5,a4,a5
  -- X"0007871b",    --sext.w	a4,a5
  -- X"fe842783",    --lw	a5,-24(s0)
  -- X"00078693",    --mv	a3,a5
  -- X"00068793",    --mv	a5,a3
  -- X"0017979b",    --slliw	a5,a5,0x1
  -- X"00d787bb",    --addw	a5,a5,a3
  -- X"0007869b",    --sext.w	a3,a5
  -- X"fe442783",    --lw	a5,-28(s0)
  -- X"00078613",    --mv	a2,a5
  -- X"00500793",    --li	a5,5
  -- X"02f647bb",    --divw	a5,a2,a5
  -- X"0007879b",    --sext.w	a5,a5
  -- X"00f687bb",    --addw	a5,a3,a5
  -- X"0007879b",    --sext.w	a5,a5
  -- X"02f747bb",    --divw	a5,a4,a5  -- last div in d =...;
  -- X"fef42023",    --sw	a5,-32(s0)
  -- X"ffc00793",    --li	a5,-4
  -- X"00000713",    --li	a4,0
  -- X"02e7c7bb",    --divw	a5,a5,a4  -- e = -4/0;
  -- X"fcf42e23",    --sw	a5,-36(s0)
  -- X"fff00793",    --li	a5,-1
  -- X"fcf43823",    --sd	a5,-48(s0)
  -- X"fd043783",    --ld	a5,-48(s0)
  -- X"00178793",    --addi	a5,a5,1   -- g1 = f + 1;
  -- X"fcf43423",    --sd	a5,-56(s0)
  -- X"fff00793",    --li	a5,-1
  -- X"0017d793",    --srli	a5,a5,0x1
  -- X"fcf43023",    --sd	a5,-64(s0)
  -- X"fc043783",    --ld	a5,-64(s0)
  -- X"00178793",    --addi	a5,a5,1   -- g2 = h + 1;
  -- X"faf43c23",    --sd	a5,-72(s0)
  -- X"fc043703",    --ld	a4,-64(s0)
  -- X"06400793",    --li	a5,100
  -- X"02f707b3",    --mul	a5,a4,a5    -- g3 = h * 100;
  -- X"06400813",    --li	a6,100      --manually added
  -- X"03071833",    --mulh a6,a4,a6   --manually added
  -- X"faf43823",    --sd	a5,-80(s0)
  -- X"800007b7",    --lui	a5,0x80000
  -- X"faf43423",    --sd	a5,-88(s0)
  -- X"fa843783",    --ld	a5,-88(s0)
  -- X"0007879b",    --sext.w	a5,a5
  -- X"fff7879b",    --addiw	a5,a5,-1 # 7fffffff <main+0x7fffffff> -- g4 = h2 - 1; 
  -- X"0007879b",    --sext.w	a5,a5
  -- X"faf42223",    --sw	a5,-92(s0)
  -- X"fff00793",    --li	a5,-1
  -- X"faf42023",    --sw	a5,-96(s0)
  -- X"00300793",    --li	a5,3
  -- X"f8f42e23",    --sw	a5,-100(s0)
  -- X"fa042783",    --lw	a5,-96(s0)
  -- X"00078713",    --mv	a4,a5
  -- X"f9c42783",    --lw	a5,-100(s0)
  -- X"02f707bb",    --mulw	a5,a4,a5  -- rm = om1*om2;
  -- X"0007879b",    --sext.w	a5,a5
  -- X"02079793",    --slli	a5,a5,0x20
  -- X"0207d793",    --srli	a5,a5,0x20
  -- X"f8f43823",    --sd	a5,-112(s0)
  -- X"fff00793",    --li	a5,-1
  -- X"0207d793",    --srli	a5,a5,0x20
  -- X"f8f43423",    --sd	a5,-120(s0)
  -- X"00300793",    --li	a5,3
  -- X"f8f43023",    --sd	a5,-128(s0)
  -- X"f8843703",    --ld	a4,-120(s0)
  -- X"f8043783",    --ld	a5,-128(s0)
  -- X"02f707b3",    --mul	a5,a4,a5    -- r2m = o2m1*o2m2;
  -- X"f6f43c23",    --sd	a5,-136(s0)
  -- X"00000793",    --li	a5,0
  -- X"00078513",    --mv	a0,a5
  -- X"08813403",    --ld	s0,136(sp)
  -- X"09010113",    --addi	sp,sp,144
  -- X"00000013"     -- nop --addi x0, x0, 0
  -- --X"00008067"    --ret
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
    );
    signal internal_instruction : std_logic_vector (31 downto 0) := X"00000000";
begin
  process(pc_in) is
    variable rom_addr: std_logic_vector( (integer(ceil(log2(real(instructions_NUM)))) - 1) downto 0);
  begin
 
  rom_addr := pc_in((rom_addr'length-1+2) downto 2); -- PC changes in steps of 4 (decimal). So in base 2 by adding multiples of 0...00100. So I can relate the given pc to a rom_address by counting from the 3rd bit onward, as if decimal-4 was now worth 1
  
    if( pc_in < std_logic_vector(to_unsigned(instructions_NUM*4, pc_in'length)) ) then

      internal_instruction <= rom_data(to_integer(unsigned(rom_addr)));
    else -- if pc_in reaches out of bounds of the array
      internal_instruction <= X"00000013"; -- set to a nop
    end if;
  end process;
  -- internal_instruction <= rom_data(to_integer(unsigned(rom_addr))) when pc_in < std_logic_vector(to_unsigned(instructions_NUM*4, pc_in'length)) else X"00000000";
                                                                            --X"00000138"
  instruction_out <= internal_instruction;
  
end Behavioral;