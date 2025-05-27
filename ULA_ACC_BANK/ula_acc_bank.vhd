library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula_acc_bank is
    port (
        -- Global control signals
        clk         : in std_logic;
        rst         : in std_logic;
        
        -- Register bank control
        bank_wr_en  : in std_logic;
        reg_code    : in unsigned(2 downto 0);
        bank_data_in : in unsigned(15 downto 0);
        
        -- Accumulator control
        acc_wr_en   : in std_logic;
        
        -- ula control
        selec_op    : in unsigned(1 downto 0);
        
        -- ula outputs
        result      : out unsigned(15 downto 0);
        flag_zero   : out std_logic;
        flag_neg    : out std_logic;
        flag_carry  : out std_logic
    );
end entity ula_acc_bank;

architecture a_ula_acc_bank of ula_acc_bank is
    -- Register bank component
    component register_bank is
        port(
            data_in   : in unsigned(15 downto 0);
            clk       : in std_logic;
            wr_en     : in std_logic;
            reg_code  : in unsigned(2 downto 0);
            rst       : in std_logic;
            data_out  : out unsigned(15 downto 0)
        );
    end component;

    -- ula component (use lowercase consistently)
    component ula is
        port (
            entrada_A : in unsigned(15 downto 0);
            entrada_B : in unsigned(15 downto 0);
            selec_op  : in unsigned(1 downto 0);
            resultado : out unsigned(15 downto 0);
            flag_zero : out std_logic;
            flag_neg  : out std_logic;
            flag_carry : out std_logic
        );
    end component;

    -- Accumulator component
    component accumulator is
        port(
            clk, rst, wr_en: in std_logic;
            data_in: in unsigned(15 downto 0);
            data_out: out unsigned(15 downto 0)
        );
    end component;

    -- Internal connection signals
    signal bank_data_out : unsigned(15 downto 0);
    signal acc_data_out  : unsigned(15 downto 0);
    signal ula_result    : unsigned(15 downto 0);

begin
    -- Register bank instance
    bank: register_bank port map(
        data_in  => bank_data_in,
        clk      => clk,
        wr_en    => bank_wr_en,
        reg_code => reg_code,
        rst      => rst,
        data_out => bank_data_out
    );
    
    -- Accumulator instance
    acc: accumulator port map(
        clk      => clk,
        rst      => rst,
        wr_en    => acc_wr_en,
        data_in  => ula_result,
        data_out => acc_data_out
    );
    
    -- ula instance (use lowercase to match component declaration)
    ula_comp: ula port map(
        entrada_A => acc_data_out,   -- Accumulator as first ula input
        entrada_B => bank_data_out,  -- Register bank as second ula input
        selec_op  => selec_op,
        resultado => ula_result,
        flag_zero => flag_zero,
        flag_neg  => flag_neg,
        flag_carry => flag_carry
    );
    
    -- Connect ula result to module output
    result <= ula_result;

end architecture a_ula_acc_bank;