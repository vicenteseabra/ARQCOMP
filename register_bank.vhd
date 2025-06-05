library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_bank is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        wr_en       : in  std_logic;                 -- Habilita escrita
        reg_wr_addr : in  unsigned(2 downto 0);    -- Endereço do registrador para escrita (0-5)
        reg_rd_addr : in  unsigned(2 downto 0);    -- Endereço do registrador para leitura (0-5)
        data_in     : in  unsigned(15 downto 0);   -- Dado para escrever
        data_out    : out unsigned(15 downto 0)    -- Dado lido
    );
end entity register_bank;

architecture a_register_bank of register_bank is
    type reg_file_type is array (0 to 5) of unsigned(15 downto 0);
    signal registers : reg_file_type := (others => (others => '0'));

begin
    -- Processo de Escrita (síncrono)
    process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if wr_en = '1' then
                if to_integer(reg_wr_addr) < 6 then -- Proteção para endereços válidos
                    registers(to_integer(reg_wr_addr)) <= data_in;
                end if;
            end if;
        end if;
    end process;

    -- Processo de Leitura (combinacional)
    -- Lê diretamente do array de sinais. A saída reflete a mudança no reg_rd_addr.
    data_out <= registers(to_integer(reg_rd_addr)) when to_integer(reg_rd_addr) < 6 else (others => 'X'); -- 'X' para endereço inválido

end architecture a_register_bank;