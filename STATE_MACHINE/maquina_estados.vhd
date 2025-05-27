library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maquina_estados is
   port(
      clk    : in std_logic;
      rst    : in std_logic;
      estado : out std_logic
   );
end entity;

architecture a_maquina_estados of maquina_estados is
   signal estado_s : std_logic := '0';
begin
   process(clk, rst)
   begin
      if rst = '1' then
         estado_s <= '0'; -- Reset para estado fetch (0)
      elsif rising_edge(clk) then
         estado_s <= not estado_s; -- Alterna entre 0 (fetch) e 1 (decode/execute)
      end if;
   end process;
   
   estado <= estado_s;
end architecture;