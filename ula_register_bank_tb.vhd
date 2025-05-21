library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula_register_bank is
end;

architecture a_ula_register_bank_tb of ula_register_bank_tb is
    component ula_register_bank is
        port (
            clk : in std_logic;
            rst : in std_logic;
            reg_wr_en, acc_wr_en : in std_logic;
            reg_load_src, acc_load_src : in std_logic;
            ula_out_view : out unsigned(15 downto 0); --Pinos pra debugar
            register_out_view : out unsigned(15 downto 0); --Pinos pra debugar
            accumulator_out_view : out unsigned(15 downto 0); --Pinos pra debugar
            ula_op : in unsigned(1 downto 0);
            ula_src : in std_logic;
            imm_const : in unsigned (15 downto 0); --Constante imediata
            register_code : in unsigned(2 downto 0);
            flag_zero : out std_logic;
            imm_cont : in unsigned (15 downto 0); --Constante imediata
            flag_neg : out std_logic
        );
    end component;

    constant period_time  : time := 100 ns;

    signal finished,clk_s,rst_s,reg_wr_en_s,acc_wr_en_s,ula_src_s: std_logic := '0';
    signal reg_load_src_s,acc_load_src_s : std_logic := '0'
    signal ula_out_view_s,register_out_view_s,accumulator_out_view_s: unsigned(15 downto 0) := (others => '0');
    signal ula_op_s: unsigned(1 downto 0) := (others => '0');
    signal register_code_s: unsigned(2 downto 0) := (others => '0');
    signal flag_zero_s,flag_neg_s: std_logic := '0';

begin
    UTT: ula_register_bank port map (
        clk => clk_s,
        rst => rst_s,
        reg_wr_en => reg_wr_en_s,
        acc_wr_en => acc_wr_en_s,
        reg_load_src => reg_load_src_s,
        acc_load_src => acc_load_src_s,
        ula_out_view => ula_out_view_s,
        register_out_view => register_out_view_s,
        accumulator_out_view => accumulator_out_view_s,
        ula_op => ula_op_s,
        ula_src => ula_src_s,
        register_code => register_code_s,
        flag_zero => flag_zero_s,
        flag_neg => flag_neg_s
    );

    --reset_global
    reset_global:process
    begin
        rst_s <= '1';
        wait for 200 ns; -- period_time*2
        rst_s <= '0';
        wait;
    end process;

    sim_time_proc:process
    begin
        wait for 10 us;     -- <== TEMPO TOTAL DA SIMULAÇÃO!!!
        finished <= '1';
        wait;
    end process;

    clk_proc:process
    begin
        while finished /= '1' loop  -- gera clock até que sim_time_proc termine
            clk_s <= '0';
            wait for 50 ns; -- metade do periodo
            clk_s <= '1';
            wait for 50 ns; -- metade do periodo
        end loop;
        wait;
    end process clk_proc;

    process
    begin
      wait for 200 ns;

      --carrega registradores
      reg_wr_en_s <= '1';
      reg_load_src_s <= '1';
      alu_src_s <= '0';
