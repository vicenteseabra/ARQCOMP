library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula_acc_bank_tb is
end entity;

architecture a_ula_acc_bank_tb of ula_acc_bank_tb is
    -- Component declaration for the unit under test (UUT)
    component ula_acc_bank is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            bank_wr_en  : in std_logic;
            reg_code    : in unsigned(2 downto 0);
            bank_data_in : in unsigned(15 downto 0);
            acc_wr_en   : in std_logic;
            selec_op    : in unsigned(1 downto 0);
            result      : out unsigned(15 downto 0);
            flag_zero   : out std_logic;
            flag_neg    : out std_logic;
            flag_carry  : out std_logic
        );
    end component;

    -- Clock period definition
    constant clk_period : time := 100 ns;
    
    -- Stimuli signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';  -- Initial reset
    signal bank_wr_en  : std_logic := '0';
    signal reg_code    : unsigned(2 downto 0) := "000";
    signal bank_data_in : unsigned(15 downto 0) := (others => '0');
    signal acc_wr_en   : std_logic := '0';
    signal selec_op    : unsigned(1 downto 0) := "00";  -- Addition operation
    
    -- Output signals
    signal result      : unsigned(15 downto 0);
    signal flag_zero   : std_logic;
    signal flag_neg    : std_logic;
    signal flag_carry  : std_logic;
    
    -- Simulation control
    signal finished    : std_logic := '0';

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: ula_acc_bank port map(
        clk         => clk,
        rst         => rst,
        bank_wr_en  => bank_wr_en,
        reg_code    => reg_code,
        bank_data_in => bank_data_in,
        acc_wr_en   => acc_wr_en,
        selec_op    => selec_op,
        result      => result,
        flag_zero   => flag_zero,
        flag_neg    => flag_neg,
        flag_carry  => flag_carry
    );

    -- Clock process
    clk_process: process
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait for clk_period;
        
        -- Test 1: Write vulae 10 to register 0
        bank_data_in <= to_unsigned(10, 16);
        reg_code <= "000";
        bank_wr_en <= '1';
        wait for clk_period;
        bank_wr_en <= '0';
        
        -- Test 2: Write vulae 20 to register 1
        bank_data_in <= to_unsigned(20, 16);
        reg_code <= "001";
        bank_wr_en <= '1';
        wait for clk_period;
        bank_wr_en <= '0';
        
        -- Test 3: Load vulae from register 0 (10) to accumulator through ula
        reg_code <= "000";  -- Select register 0
        selec_op <= "00";   -- Addition
        acc_wr_en <= '1';   -- Enable accumulator write
        wait for clk_period;
        acc_wr_en <= '0';
        
        -- Test 4: Add register 1 (20) to accumulator (10)
        reg_code <= "001";  -- Select register 1
        selec_op <= "00";   -- Addition
        acc_wr_en <= '1';   -- Enable accumulator write
        wait for clk_period;
        acc_wr_en <= '0';
        -- Accumulator should now contain 30 (10+20)
        
        -- Test 5: Subtract register 0 (10) from accumulator (30)
        reg_code <= "000";  -- Select register 0
        selec_op <= "01";   -- Subtraction
        acc_wr_en <= '1';   -- Enable accumulator write
        wait for clk_period;
        acc_wr_en <= '0';
        -- Accumulator should now contain 20 (30-10)
        
        -- Test 6: OR operation with register 1 (20)
        reg_code <= "001";  -- Select register 1
        selec_op <= "10";   -- OR operation
        acc_wr_en <= '1';   -- Enable accumulator write
        wait for clk_period;
        acc_wr_en <= '0';
        -- Accumulator should now contain 20 OR 20 = 20
        
        -- Test 7: Write a negative vulae to register 2 and test flags
        bank_data_in <= to_unsigned(65535, 16);  -- -1 in 2's complement
        reg_code <= "010";
        bank_wr_en <= '1';
        wait for clk_period;
        bank_wr_en <= '0';
        
        -- Test 8: Add negative vulae to accumulator to check negative flag
        reg_code <= "010";  -- Select register 2
        selec_op <= "00";   -- Addition
        acc_wr_en <= '1';   -- Enable accumulator write
        wait for clk_period;
        acc_wr_en <= '0';
        
        -- Test 9: Write big vulaes to test carry flag
        bank_data_in <= to_unsigned(65000, 16);
        reg_code <= "011";
        bank_wr_en <= '1';
        wait for clk_period;
        bank_wr_en <= '0';
        
        -- Test 10: Reset accumulator to 0
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        
        -- Test 11: Add register 3 (65000) to accumulator (0)
        reg_code <= "011";
        selec_op <= "00";   -- Addition
        acc_wr_en <= '1';
        wait for clk_period;
        acc_wr_en <= '0';
        
        -- Test 12: Add register 3 again (65000) to test carry flag
        reg_code <= "011";
        selec_op <= "00";   -- Addition
        acc_wr_en <= '1';
        wait for clk_period;
        acc_wr_en <= '0';
        -- Should generate carry flag
        
        -- End of test
        wait for 300 ns;
        finished <= '1';
        wait;
    end process;

end architecture;