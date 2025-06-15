-- microprocessador.vhd
-- Arquivo principal que conecta todos os componentes.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity microprocessador is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- Saídas para Debug
        debug_fsm_estado  : out unsigned(1 downto 0);
        debug_pc_addr     : out unsigned(6 downto 0);
        debug_ir_instr    : out unsigned(17 downto 0);
        debug_reg_bank_out: out unsigned(15 downto 0); -- Saída do registrador lido pelo ula_acc_bank
        debug_acc_out     : out unsigned(15 downto 0);
        debug_ula_out     : out unsigned(15 downto 0)
    );
end entity microprocessador;

architecture structural of microprocessador is
    -- Componente: Máquina de Estados
    component maquina_estados is
        port(
            clk: in std_logic;
            rst: in std_logic;
            estado: out unsigned(1 downto 0)
        );
    end component;

    -- Componente: Interface PC-ROM
    component pc_rom is
        port(
            clk: in std_logic;
            rst: in std_logic;
            pc_inc_en: in std_logic;
            jump_en_ctrl: in std_logic;
            addr_jump_ctrl: in unsigned(6 downto 0);
            pc_out: out unsigned(6 downto 0);
            rom_data_out: out unsigned(17 downto 0);
            pc_wr_en: in std_logic  -- Sinal de escrita no PC
            );
    end component;

    -- Componente: Registrador de Instrução
    component instruction_register is
        port(clk: in std_logic; rst: in std_logic; wr_en: in std_logic;
             data_in: in unsigned(17 downto 0); data_out: out unsigned(17 downto 0));
    end component;

    -- Componente: Unidade de Controle
    component unidade_controle is
        port(
            clk: in std_logic;
            rst: in std_logic;
            fsm_estado_in: in unsigned(1 downto 0);
            ir_instr_in: in unsigned(17 downto 0);
            pc_inc_en_out: out std_logic;
            pc_jump_en_out: out std_logic;
            pc_jump_addr_out: out unsigned(6 downto 0);
            pc_wr_en_out: out std_logic;
            ir_wr_en_out: out std_logic;
            ula_zero_in: in std_logic;
            ula_carry_in: in std_logic;
            debug_reg_wr_en_out: out std_logic;
            debug_reg_addr_out: out unsigned(2 downto 0);
            debug_acc_wr_en_out: out std_logic;
            debug_alu_sel_out: out unsigned(1 downto 0);
            debug_bank_in_sel_out: out std_logic;
            debug_imm_data_out: out unsigned(15 downto 0)
            );
    end component;

    -- Componente: Datapath Core (ULA, ACC, Banco, MUX)
    component ula_acc_bank is
        port(   clk: in std_logic;
                rst: in std_logic;
                ctrl_reg_wr_en: in std_logic;
                ctrl_reg_addr: in unsigned(2 downto 0);
                acc_wr_en: in std_logic;
                ula_op: in unsigned(1 downto 0);
                ctrl_bank_in_sel: in std_logic;
                immediate_data_in: in unsigned(15 downto 0);
                ula_flag_zero: out std_logic;
                ula_flag_carry: out std_logic;
                acc_data_debug: out unsigned(15 downto 0);
                bank_data_debug: out unsigned(15 downto 0);
                ula_result_debug: out unsigned(15 downto 0));
    end component;

    -- Sinais de interconexão
    signal s_fsm_estado   : unsigned(1 downto 0);
    signal s_pc_addr      : unsigned(6 downto 0);
    signal s_rom_data     : unsigned(17 downto 0);
    signal s_ir_instr     : unsigned(17 downto 0);

    signal s_pc_inc_en    : std_logic;
    signal s_pc_jump_en   : std_logic;
    signal s_pc_jump_addr : unsigned(6 downto 0);
    signal s_pc_wr_en     : std_logic;
    signal s_ir_wr_en     : std_logic;

    signal s_debug_reg_wr_en   : std_logic;
    signal s_debug_reg_addr : unsigned(2 downto 0);
    signal s_debug_acc_wr_en   : std_logic;
    signal s_debug_alu_sel     : unsigned(1 downto 0);
    signal s_debug_bank_in_sel : std_logic;
    signal s_debug_imm_data    : unsigned(15 downto 0);

    -- Sinais de flags
    signal s_ula_zero, s_ula_carry : std_logic;

begin
    -- Instanciação da Máquina de Estados
    maquina_estados_inst: maquina_estados
        port map(
            clk => clk,
            rst => rst,
            estado => s_fsm_estado
            );

    -- Instanciação da Interface PC-ROM
    pc_rom_inst: pc_rom
        port map(
            clk            => clk,
            rst            => rst,
            pc_inc_en      => s_pc_inc_en,
            jump_en_ctrl   => s_pc_jump_en,
            addr_jump_ctrl => s_pc_jump_addr,
            pc_out         => s_pc_addr,
            pc_wr_en       => s_pc_wr_en,  -- Sinal de escrita no PC
            rom_data_out   => s_rom_data
        );

    -- Instanciação do Registrador de Instrução
    instruction_register_inst: instruction_register
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => s_ir_wr_en,
            data_in  => s_rom_data,
            data_out => s_ir_instr
        );

    -- Instanciação da Unidade de Controle
    uc_inst: unidade_controle
        port map(
            clk                => clk,
            rst                => rst,
            fsm_estado_in      => s_fsm_estado,
            ir_instr_in        => s_ir_instr,
            pc_inc_en_out      => s_pc_inc_en,
            pc_wr_en_out     => s_pc_wr_en,
            pc_jump_en_out     => s_pc_jump_en,
            pc_jump_addr_out   => s_pc_jump_addr,
            ir_wr_en_out       => s_ir_wr_en,
            ula_zero_in     => s_ula_zero,
            ula_carry_in    => s_ula_carry,
            debug_reg_wr_en_out   => s_debug_reg_wr_en,
            debug_reg_addr_out => s_debug_reg_addr,
            debug_acc_wr_en_out   => s_debug_acc_wr_en,
            debug_alu_sel_out     => s_debug_alu_sel,
            debug_bank_in_sel_out => s_debug_bank_in_sel,
            debug_imm_data_out    => s_debug_imm_data
        );

    -- Instanciação do Datapath Core
    ula_acc_bank_inst: ula_acc_bank
        port map(
            clk                => clk,
            rst                => rst,
            ctrl_reg_wr_en     => s_debug_reg_wr_en,
            ctrl_reg_addr      => s_debug_reg_addr,
            acc_wr_en          => s_debug_acc_wr_en,
            ula_op             => s_debug_alu_sel,
            ctrl_bank_in_sel   => s_debug_bank_in_sel,
            immediate_data_in  => s_debug_imm_data,
            ula_flag_zero      => s_ula_zero,
            ula_flag_carry     => s_ula_carry,
            acc_data_debug     => debug_acc_out,
            bank_data_debug    => debug_reg_bank_out,
            ula_result_debug   => debug_ula_out
        );

    -- Saídas de Debug para o Top Level
    debug_fsm_estado <= s_fsm_estado;
    debug_pc_addr    <= s_pc_addr;
    debug_ir_instr   <= s_ir_instr;

end architecture structural;
