library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_register is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wr_en   : in  std_logic;               -- Habilita escrita no IR
        data_in : in  unsigned(17 downto 0); -- Instrução vinda da ROM
        data_out: out unsigned(17 downto 0)  -- Instrução para a Unidade de Controle
    );
end entity instruction_register;

architecture a_ir of instruction_register is
    signal ir_value : unsigned(17 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            ir_value <= (others => '0'); -- Reset para NOP (0000...)
        elsif rising_edge(clk) then
            if wr_en = '1' then
                ir_value <= data_in;
            end if;
        end if;
    end process;

    data_out <= ir_value;
end architecture a_ir;
