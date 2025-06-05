library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accumulator is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        wr_en    : in  std_logic;               -- Habilita escrita no acumulador
        data_in  : in  unsigned(15 downto 0); -- Dado da ULA para o acumulador
        data_out : out unsigned(15 downto 0)  -- Saída do acumulador para a ULA
    );
end entity accumulator;

architecture a_accumulator of accumulator is
    signal acc_value : unsigned(15 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            acc_value <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' then
                acc_value <= data_in;
            end if;
        end if;
    end process;

    data_out <= acc_value;
end architecture a_accumulator;
