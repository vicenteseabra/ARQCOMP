-- pc_controller.vhd
-- Controla o incremento e saltos do PC.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_controller is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        pc_inc_en   : in  std_logic;             -- Habilita o incremento do PC (no Fetch)
        jump_en     : in  std_logic;             -- Habilita o salto
        addr_jump   : in  unsigned(6 downto 0);  -- Endereço para salto absoluto
        pc_write_en : in std_logic;             -- Sinal para habilitar a escrita no registrador PC
        pc_next_val : out unsigned(6 downto 0)  -- Próximo valor a ser escrito no PC

    );
end entity pc_controller;

architecture a_pc_controller of pc_controller is
    component pc is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
        );
    end component;

    signal ProgramCounterOut : unsigned(6 downto 0);
    signal ProgramCounterIn : unsigned(6 downto 0) := "0000000";

begin
    -- Instancia o Program Counter (Registrador)
    pc_reg_inst: pc
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => pc_write_en,
            data_in  => ProgramCounterIn,
            data_out => ProgramCounterOut
        );

    ProgramCounterIn <= addr_jump when jump_en = '1' else
                        ProgramCounterOut + "0000001";

    pc_next_val <= ProgramCounterOut;
end a_pc_controller;
