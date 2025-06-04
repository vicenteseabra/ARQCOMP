library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
   port(
      clk      : in  std_logic;
      endereco : in  unsigned(6 downto 0);
      dado     : out unsigned(17 downto 0)
   );
end entity;

architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(17 downto 0);
   constant conteudo_rom : mem := (
      --  0: LD R3, #5
      0  => "010001000110000101",
      --  1: LD R4, #8
      1  => "010001001000001000",
      --  2: MOV R5, R3
      2  => "000100001010001100",
      --  3: ADD R5, R4
      3  => "001000001010010000",
      --  4: LD R0, #1
      4  => "010001000000000001",
      --  5: SUB R5, R0
      5  => "001100001010000000",
      --  6: JMP 20
      6  => "111100001010000000",
      --  7: LD R5, #0 (não executada)
      7  => "010001001010000000",
      --  8..19: NOP
      8   => "000000000000000000",
      9   => "000000000000000000",
      10  => "000000000000000000",
      11  => "000000000000000000",
      12  => "000000000000000000",
      13  => "000000000000000000",
      14  => "000000000000000000",
      15  => "000000000000000000",
      16  => "000000000000000000",
      17  => "000000000000000000",
      18  => "000000000000000000",
      19  => "000000000000000000",
      -- 20: MOV R3, R5
      20 => "000100000110010100",
      -- 21: JMP 2
      21 => "111100000000010000",
      -- 22: LD R3, #0 (não executada)
      22 => "010001000110000000"
   );
begin
   process(clk)
   begin
      if rising_edge(clk) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture a_rom;
