-- pc_controller.vhd
-- Controla o incremento e saltos do PC.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_controller is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        pc_inc_en   : in  std_logic;             -- Habilita o incremento do PC (geralmente no Fetch)
        jump_en     : in  std_logic;             -- Habilita o salto
        addr_jump   : in  unsigned(6 downto 0);  -- Endereço para salto absoluto
        pc_current  : in  unsigned(6 downto 0);  -- Valor atual do PC (lido do registrador PC)
        pc_next_val : out unsigned(6 downto 0);  -- Próximo valor a ser escrito no PC
        pc_write_en : out std_logic              -- Sinal para habilitar a escrita no registrador PC
    );
end entity pc_controller;

architecture a_pc_controller of pc_controller is
begin
    process(pc_current, pc_inc_en, jump_en, addr_jump)
    begin
        if jump_en = '1' then
            pc_next_val <= addr_jump;
        elsif pc_inc_en = '1' then
            pc_next_val <= pc_current + 1;
        else
            pc_next_val <= pc_current; -- Mantém o valor se não há incremento nem salto
        end if;
    end process;

    -- O PC deve ser escrito se houver um salto ou um incremento habilitado.
    pc_write_en <= jump_en or pc_inc_en;

end architecture a_pc_controller;
