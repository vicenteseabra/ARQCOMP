library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maquina_estados is
    port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        estado : out unsigned(1 downto 0) -- "00": Fetch, "01": Decode, "10": Execute
    );
end entity;

architecture a_maquina_estados of maquina_estados is
    signal estado_s : unsigned(1 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            estado_s <= "00";
        elsif rising_edge(clk) then
            if estado_s = "10" then        -- se agora esta em 3 (Execute)
                estado_s <= "00";         -- o prox vai voltar ao zero (Fetch)
            else
                estado_s <= estado_s + 1;   -- senao avanca
            end if;
        end if;
    end process;

    estado <= estado_s;
end architecture;
