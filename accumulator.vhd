library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accumulator is
    port(
        clk, rst, wr_en: in std_logic;
        data_in: in unsigned(15 downto 0);
        data_out: out unsigned(15 downto 0)
    );
end entity accumulator;

architecture a_accumulator of accumulator is

    signal data: unsigned(15 downto 0);

    begin

        process(clk, rst, wr_en)
        begin
            if rst = '1' then
                data <= "0000000000000000";
            elsif wr_en = '1' then
                if rising_edge(clk) then
                    data <= data_in;
                end if;
            end if;
        end process;

        data_out <= data;

end architecture a_accumulator;