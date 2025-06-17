library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula_acc_bank is
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;

        -- Sinais de Controle da UC
        ctrl_reg_wr_en   : in  std_logic;
        ctrl_reg_addr : in  unsigned(2 downto 0);
        acc_wr_en   : in  std_logic;
        ula_op     : in  unsigned(1 downto 0);
        ctrl_bank_in_sel : in  std_logic;             -- '0': ULA_result, '1': Immediate_data
        immediate_data_in: in  unsigned(15 downto 0); -- Dado imediato da UC (para LD)
        mux_ula_ram_data : in  std_logic; -- Seleção de dados para o banco de registradores (0: ULA, 1: RAM)
        ram_data : in  unsigned(15 downto 0); -- Dado lido da RAM
        -- Saídas para UC (Flags)
        ula_flag_zero    : out std_logic;
        ula_flag_carry   : out std_logic;

        -- Saídas para Debug/Top-Level
        acc_data_debug   : out unsigned(15 downto 0);
        bank_data_debug  : out unsigned(15 downto 0); -- Saída do registrador lido
        ula_result_debug : out unsigned(15 downto 0)
    );
end entity ula_acc_bank;

architecture a_ula_acc_bank of ula_acc_bank is
    component accumulator is
        port(
            clk, rst, wr_en: in std_logic;
            data_in: in unsigned(15 downto 0);
            data_out: out unsigned(15 downto 0)
            );
    end component;

    component register_bank is
        port(
            clk, rst, wr_en: in std_logic;
            reg_code: in unsigned(2 downto 0);
            data_in: in unsigned(15 downto 0);
            data_out: out unsigned(15 downto 0)
            );
    end component;

    component ula is
        port(
            entrada_A, entrada_B: in unsigned(15 downto 0);
            selec_op: in unsigned(1 downto 0);
            resultado: out unsigned(15 downto 0);
            flag_zero, flag_carry: out std_logic
            );
    end component;

    -- Sinais internos de conexão
    signal s_acc_data_out    : unsigned(15 downto 0);
    signal s_bank_data_out   : unsigned(15 downto 0);
    signal s_ula_result      : unsigned(15 downto 0) := (others => '0');
    signal s_data_for_bank_in: unsigned(15 downto 0);
    signal s_mux_bank_Imm_data : unsigned(15 downto 0);
    signal s_data_in         : unsigned(15 downto 0); -- Dado de entrada para o banco de registradores
    signal s_ram_data        : unsigned(15 downto 0); -- Dado lido da RAM

begin
    -- Instanciação do Acumulador
    acc_inst: accumulator
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => acc_wr_en,
            data_in  => s_ula_result,       -- ACC recebe resultado da ULA ou dado imediato
            data_out => s_acc_data_out
        );

    -- Instanciação do Banco de Registradores
    bank_inst: register_bank
        port map(
            clk         => clk,
            rst         => rst,
            wr_en       => ctrl_reg_wr_en,
            reg_code    => ctrl_reg_addr,
            data_in     => s_data_in, -- Dado de entrada para o banco de registradores
            data_out    => s_bank_data_out
        );

    -- Instanciação da ULA
    ula_inst: ula
        port map(
            entrada_A  => s_acc_data_out,    -- ULA operando A é o ACC
            entrada_B  => s_mux_bank_Imm_data,   -- ULA operando B é a saída do banco ou Immediate
            selec_op   => ula_op,
            resultado  => s_ula_result,
            flag_zero  => ula_flag_zero,
            flag_carry => ula_flag_carry
        );

    -- Multiplexador para a entrada de dados na ULA
    s_mux_bank_Imm_data <= s_bank_data_out      when ctrl_bank_in_sel = '0' else -- Para MOV Rd, Rs (resultado da ULA)
                          immediate_data_in     when ctrl_bank_in_sel = '1'; -- Para LD Rd, Imm


    -- Multiplexador para a entrada de dados no Banco de Registradores
    s_data_in <= s_ula_result   when mux_ula_ram_data = '0' else -- Resultado da ULA
                 s_ram_data     when mux_ula_ram_data = '1'; -- Dado imediato


    -- Saídas de Debug

    acc_data_debug   <= s_acc_data_out;
    bank_data_debug  <= s_bank_data_out;
    ula_result_debug <= s_ula_result;

end architecture a_ula_acc_bank;