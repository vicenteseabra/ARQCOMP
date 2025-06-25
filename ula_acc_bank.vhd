-- ula_acc_bank.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula_acc_bank is
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;

        -- Sinais de Controle da UC
        ctrl_reg_wr_en  : in  std_logic;

        ctrl_reg_read_addr : in  unsigned(2 downto 0);

        ctrl_reg_write_addr: in  unsigned(2 downto 0);
        acc_wr_en       : in  std_logic;
        ula_op          : in  unsigned(1 downto 0);
        ctrl_bank_in_sel: in  std_logic;
        immediate_data_in: in  unsigned(15 downto 0);
        mux_ula_ram_data: in  std_logic;
        ram_data        : in  unsigned(15 downto 0);

        -- Saídas para UC (Flags)
        ula_flag_zero   : out std_logic;
        ula_flag_carry  : out std_logic;

        -- Saídas para Debug/Top-Level
        acc_data_debug   : out unsigned(15 downto 0);
        bank_data_debug  : out unsigned(15 downto 0);
        ula_result_debug : out unsigned(15 downto 0)
    );
end entity ula_acc_bank;

architecture a_ula_acc_bank of ula_acc_bank is
    -- ALTERADO: Componente do banco de registradores atualizado
    component register_bank is
        port(
            clk           : in std_logic;
            rst           : in std_logic;
            wr_en         : in std_logic;
            data_in       : in unsigned(15 downto 0);
            read_addr_in  : in unsigned(2 downto 0);
            write_addr_in : in unsigned(2 downto 0);
            data_out      : out unsigned(15 downto 0)
        );
    end component;

    -- Outros componentes (accumulator, ula) permanecem os mesmos...
    component accumulator is
        port(clk, rst, wr_en: in std_logic; data_in: in unsigned(15 downto 0); data_out: out unsigned(15 downto 0));
    end component;
    component ula is
        port(entrada_A, entrada_B: in unsigned(15 downto 0); selec_op: in unsigned(1 downto 0);
             resultado: out unsigned(15 downto 0); flag_zero, flag_carry: out std_logic);
    end component;

    -- Sinais internos
    signal s_acc_data_out     : unsigned(15 downto 0);
    signal s_bank_data_out    : unsigned(15 downto 0);
    signal s_ula_result       : unsigned(15 downto 0) := (others => '0');
    signal s_data_for_bank_in : unsigned(15 downto 0);
    signal s_mux_bank_Imm_data: unsigned(15 downto 0);
    signal s_data_in          : unsigned(15 downto 0);

begin
    -- Instanciação do Acumulador
    acc_inst: accumulator port map(
        clk      => clk, rst      => rst, wr_en    => acc_wr_en,
        data_in  => s_ula_result, data_out => s_acc_data_out
    );

    -- ALTERADO: Instanciação do Banco de Registradores com novos ports
    bank_inst: register_bank port map(
        clk           => clk,
        rst           => rst,
        wr_en         => ctrl_reg_wr_en,
        read_addr_in  => ctrl_reg_read_addr,  -- Endereço para leitura
        write_addr_in => ctrl_reg_write_addr, -- Endereço para escrita
        data_in       => s_data_in,
        data_out      => s_bank_data_out
    );

    -- Instanciação da ULA
    ula_inst: ula port map(
        entrada_A  => s_acc_data_out,
        entrada_B  => s_mux_bank_Imm_data,
        selec_op   => ula_op,
        resultado  => s_ula_result,
        flag_zero  => ula_flag_zero,
        flag_carry => ula_flag_carry
    );

    -- Multiplexador para a entrada de dados na ULA
    s_mux_bank_Imm_data <= s_bank_data_out when ctrl_bank_in_sel = '0' else immediate_data_in;

    -- Multiplexador para a entrada de dados no Banco de Registradores
    s_data_in <= s_ula_result when mux_ula_ram_data = '0' else ram_data;

    -- Saídas de Debug
    acc_data_debug   <= s_acc_data_out;
    bank_data_debug  <= s_bank_data_out; -- Esta saída é crucial agora, pois fornecerá o endereço para a RAM
    ula_result_debug <= s_ula_result;

end architecture a_ula_acc_bank;
