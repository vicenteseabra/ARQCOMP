library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        wr_en    : in  std_logic;               -- Habilita escrita no PC (para saltos ou incremento)
        data_in  : in  unsigned(6 downto 0);  -- Novo valor do PC (do PC_controller)
        data_out : out unsigned(6 downto 0)
    );
end entity pc;

architecture a_pc of pc is
    signal registro : unsigned(6 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            registro <= (others => '0'); -- Reset para o endereço 0
        elsif rising_edge(clk) then
            if wr_en = '1' then
                registro <= data_in;
            end if;
        end if;
    end process;

    data_out <= registro;
end architecture a_pc;
