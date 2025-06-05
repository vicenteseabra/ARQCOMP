-- microprocessador.vhd
-- Arquivo principal que conecta todos os componentes.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity microprocessador is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- Saídas para Debug conforme solicitado
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
        port(clk: in std_logic; rst: in std_logic; estado: out unsigned(1 downto 0));
    end component;

    -- Componente: Interface PC-ROM
    component pc_rom is
        port(clk: in std_logic; rst: in std_logic; pc_inc_en: in std_logic;
             jump_en_ctrl: in std_logic; addr_jump_ctrl: in unsigned(6 downto 0);
             rom_data_out: out unsigned(17 downto 0); pc_addr_out: out unsigned(6 downto 0));
    end component;

    -- Componente: Registrador de Instrução
    component instruction_register is
        port(clk: in std_logic; rst: in std_logic; wr_en: in std_logic;
             data_in: in unsigned(17 downto 0); data_out: out unsigned(17 downto 0));
    end component;

    -- Componente: Unidade de Controle
    component unidade_controle is
        port(clk: in std_logic; rst: in std_logic; fsm_estado_in: in unsigned(1 downto 0);
             ir_instr_in: in unsigned(17 downto 0);
             pc_inc_en_out: out std_logic; pc_jump_en_out: out std_logic;
             pc_jump_addr_out: out unsigned(6 downto 0); ir_wr_en_out: out std_logic;
             dp_reg_wr_en_out: out std_logic; dp_reg_wr_addr_out: out unsigned(2 downto 0);
             dp_reg_rd_addr_out: out unsigned(2 downto 0); dp_acc_wr_en_out: out std_logic;
             dp_alu_sel_out: out unsigned(1 downto 0); dp_bank_in_sel_out: out std_logic;
             dp_imm_data_out: out unsigned(15 downto 0));
    end component;

    -- Componente: Datapath Core (ULA, ACC, Banco, MUX)
    component ula_acc_bank is
        port(clk: in std_logic; rst: in std_logic; ctrl_reg_wr_en: in std_logic;
             ctrl_reg_wr_addr: in unsigned(2 downto 0); ctrl_reg_rd_addr: in unsigned(2 downto 0);
             ctrl_acc_wr_en: in std_logic; ctrl_alu_sel: in unsigned(1 downto 0);
             ctrl_bank_in_sel: in std_logic; immediate_data_in: in unsigned(15 downto 0);
             ula_flag_zero: out std_logic; ula_flag_neg: out std_logic; ula_flag_carry: out std_logic;
             acc_data_debug: out unsigned(15 downto 0); bank_data_debug: out unsigned(15 downto 0);
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
    signal s_ir_wr_en     : std_logic;

    signal s_dp_reg_wr_en   : std_logic;
    signal s_dp_reg_wr_addr : unsigned(2 downto 0);
    signal s_dp_reg_rd_addr : unsigned(2 downto 0);
    signal s_dp_acc_wr_en   : std_logic;
    signal s_dp_alu_sel     : unsigned(1 downto 0);
    signal s_dp_bank_in_sel : std_logic;
    signal s_dp_imm_data    : unsigned(15 downto 0);

    -- Sinais de flags (não usados ainda, mas prontos)
    -- signal s_ula_zero, s_ula_neg, s_ula_carry : std_logic;

begin
    -- Instanciação da Máquina de Estados
    maquina_estados_inst: maquina_estados
        port map(clk => clk, rst => rst, estado => s_fsm_estado);

    -- Instanciação da Interface PC-ROM
    pc_rom_inst: pc_rom
        port map(
            clk            => clk,
            rst            => rst,
            pc_inc_en      => s_pc_inc_en,
            jump_en_ctrl   => s_pc_jump_en,
            addr_jump_ctrl => s_pc_jump_addr,
            rom_data_out   => s_rom_data,
            pc_addr_out    => s_pc_addr
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
            pc_jump_en_out     => s_pc_jump_en,
            pc_jump_addr_out   => s_pc_jump_addr,
            ir_wr_en_out       => s_ir_wr_en,
            dp_reg_wr_en_out   => s_dp_reg_wr_en,
            dp_reg_wr_addr_out => s_dp_reg_wr_addr,
            dp_reg_rd_addr_out => s_dp_reg_rd_addr,
            dp_acc_wr_en_out   => s_dp_acc_wr_en,
            dp_alu_sel_out     => s_dp_alu_sel,
            dp_bank_in_sel_out => s_dp_bank_in_sel,
            dp_imm_data_out    => s_dp_imm_data
        );

    -- Instanciação do Datapath Core
    ula_acc_bank_inst: ula_acc_bank
        port map(
            clk                => clk,
            rst                => rst,
            ctrl_reg_wr_en     => s_dp_reg_wr_en,
            ctrl_reg_wr_addr   => s_dp_reg_wr_addr,
            ctrl_reg_rd_addr   => s_dp_reg_rd_addr,
            ctrl_acc_wr_en     => s_dp_acc_wr_en,
            ctrl_alu_sel       => s_dp_alu_sel,
            ctrl_bank_in_sel   => s_dp_bank_in_sel,
            immediate_data_in  => s_dp_imm_data,
            -- ula_flag_zero      => s_ula_zero, -- Conectar se for usar
            -- ula_flag_neg       => s_ula_neg,
            -- ula_flag_carry     => s_ula_carry,
            acc_data_debug     => debug_acc_out,
            bank_data_debug    => debug_reg_bank_out,
            ula_result_debug   => debug_ula_out
        );

    -- Saídas de Debug para o Top Level
    debug_fsm_estado <= s_fsm_estado;
    debug_pc_addr    <= s_pc_addr;
    debug_ir_instr   <= s_ir_instr;

end architecture structural;
