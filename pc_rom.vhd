library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_rom is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        pc_inc_en   : in  std_logic;             -- Sinal da UC para incrementar PC
        pc_wr_en: in std_logic;              -- Sinal de escrita no PC
        jump_en_ctrl: in  std_logic;             -- Sinal da UC para JMP
        addr_jump_ctrl: in  unsigned(6 downto 0);  -- Endereço de JMP da UC
        pc_out : out unsigned(6 downto 0);  -- Próximo valor do PC
        rom_data_out: out unsigned(17 downto 0) -- Instrução lida da ROM
    );
end entity pc_rom;

architecture a_pc_rom of pc_rom is

    component pc_controller is
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            pc_inc_en   : in  std_logic;
            jump_en     : in  std_logic;
            addr_jump   : in  unsigned(6 downto 0);
            pc_write_en : in std_logic;
            pc_next_val : out unsigned(6 downto 0)

        );
    end component;

    component rom is
        port(
            clk      : in  std_logic;
            endereco : in  unsigned(6 downto 0);
            dado     : out unsigned(17 downto 0)
        );
    end component;

    signal rom_data_out_s     : unsigned(17 downto 0);-- Dados lidos da ROM
    signal s_pc_current_addr      : unsigned(6 downto 0); -- Próximo valor do PC

begin
    -- Instancia o Controlador do PC
    pc_ctrl_inst: pc_controller
        port map(
            clk         => clk,
            rst         => rst,
            pc_inc_en   => pc_inc_en,       -- Controlado pela UC
            jump_en     => jump_en_ctrl,    -- Controlado pela UC
            addr_jump   => addr_jump_ctrl,  -- Controlado pela UC
            pc_next_val => s_pc_current_addr,
            pc_write_en => pc_wr_en
        );

    -- Instancia a ROM
    rom_inst: rom
        port map(
            clk      => clk,
            endereco => s_pc_current_addr, -- PC atualiza endereço da ROM
            dado     => rom_data_out_s
        );

    rom_data_out <= rom_data_out_s;
    pc_out <= s_pc_current_addr; -- Saída do PC para a UC
end architecture a_pc_rom;
