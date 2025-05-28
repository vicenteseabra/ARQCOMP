library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
   port(
      clk      : in std_logic;
      endereco : in unsigned(6 downto 0);
      dado     : out unsigned(17 downto 0)  -- ROM de 18 bits
   );
end entity;

architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(17 downto 0);
   constant conteudo_rom : mem := (
      -- caso endereco => conteudo (18 bits por instrução)
      0  => "000000000000000010",  -- instrução exemplo
      1  => "100000000000000000",  -- instrução exemplo
      2  => "000000000000000000",  -- instrução exemplo
      3  => "000000000000000000",  -- instrução exemplo
      4  => "100000000000000000",  -- instrução exemplo
      5  => "000000000000000010",  -- instrução exemplo
      6  => "111100000000000011",  -- JUMP para endereço 3
      7  => "000000000000000010",  -- instrução exemplo
      8  => "000000000000000010",  -- instrução exemplo
      9  => "000000000000000000",  -- instrução exemplo
      10 => "000000000000000000",  -- instrução exemplo
      -- abaixo: casos omissos => (zero em todos os bits)
      others => (others=>'0')
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;