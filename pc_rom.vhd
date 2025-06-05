library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_rom is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        pc_inc_en   : in  std_logic;             -- Sinal da UC para incrementar PC
        jump_en_ctrl: in  std_logic;             -- Sinal da UC para JMP
        addr_jump_ctrl: in  unsigned(6 downto 0);  -- Endereço de JMP da UC

        rom_data_out: out unsigned(17 downto 0); -- Instrução lida da ROM
        pc_addr_out : out unsigned(6 downto 0)   -- Endereço atual do PC (para debug/UC)
    );
end entity pc_rom;

architecture a_pc_rom of pc_rom is
    component pc is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
        );
    end component;

    component pc_controller is
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            pc_inc_en   : in  std_logic;
            jump_en     : in  std_logic;
            addr_jump   : in  unsigned(6 downto 0);
            pc_current  : in  unsigned(6 downto 0);
            pc_next_val : out unsigned(6 downto 0);
            pc_write_en : out std_logic
        );
    end component;

    component rom is
        port(
            clk      : in  std_logic;
            endereco : in  unsigned(6 downto 0);
            dado     : out unsigned(17 downto 0)
        );
    end component;

    signal s_pc_current_val : unsigned(6 downto 0);
    signal s_pc_next_val    : unsigned(6 downto 0);
    signal s_pc_write_en    : std_logic;

begin
    -- Instancia o Program Counter (Registrador)
    pc_reg_inst: pc
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => s_pc_write_en,
            data_in  => s_pc_next_val,
            data_out => s_pc_current_val
        );

    -- Instancia o Controlador do PC
    pc_ctrl_inst: pc_controller
        port map(
            clk         => clk,
            rst         => rst,
            pc_inc_en   => pc_inc_en,       -- Controlado pela UC
            jump_en     => jump_en_ctrl,    -- Controlado pela UC
            addr_jump   => addr_jump_ctrl,  -- Controlado pela UC
            pc_current  => s_pc_current_val,
            pc_next_val => s_pc_next_val,
            pc_write_en => s_pc_write_en
        );

    -- Instancia a ROM
    rom_inst: rom
        port map(
            clk      => clk,
            endereco => s_pc_current_val, -- PC atualiza endereço da ROM
            dado     => rom_data_out
        );

    -- Saída do endereço atual do PC
    pc_addr_out <= s_pc_current_val;

end architecture a_pc_rom;
