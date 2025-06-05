library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg16bits is
   port( clk      : in std_logic;
         rst      : in std_logic;
         wr_en    : in std_logic;
         data_in  : in unsigned(15 downto 0);
         data_out : out unsigned(15 downto 0)
   );
end entity;

architecture a_reg16bits of reg16bits is
   signal registro: unsigned(15 downto 0) := (others => '0');  -- inicializa o registro com 0
begin
   process(clk,rst)  -- acionado se houver mudança em clk, rst ou wr_en
   begin
      if rst='1' then
         registro <= (others => '0');
      elsif rising_edge(clk) then
            registro <= data_in when wr_en = '1' else
                        registro;  -- mantém o valor atual se wr_en = '0'
      end if;
end process;

   data_out <= registro;

end architecture a_reg16bits;