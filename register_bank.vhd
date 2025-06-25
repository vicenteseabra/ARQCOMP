-- register_bank.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_bank is
    port(
        clk           : in std_logic;
        rst           : in std_logic;
        wr_en         : in std_logic;
        data_in       : in unsigned(15 downto 0);
        read_addr_in  : in unsigned(2 downto 0);
        write_addr_in : in unsigned(2 downto 0);
        data_out      : out unsigned(15 downto 0)
    );
end entity register_bank;

architecture a_register_bank of register_bank is
    component reg16bits is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    signal data_out_0_s,data_out_1_s,data_out_2_s : unsigned(15 downto 0) := (others => '0');
    signal data_out_3_s,data_out_4_s,data_out_5_s : unsigned(15 downto 0) := (others => '0');

    signal wr_en_0_s,wr_en_1_s,wr_en_2_s : std_logic := '0';
    signal wr_en_3_s,wr_en_4_s,wr_en_5_s : std_logic := '0';

begin

    -- ALTERADO: A lógica de habilitação de escrita agora usa 'write_addr_in'
    wr_en_0_s <= '1' when wr_en = '1' and write_addr_in = "000" else '0';
    wr_en_1_s <= '1' when wr_en = '1' and write_addr_in = "001" else '0';
    wr_en_2_s <= '1' when wr_en = '1' and write_addr_in = "010" else '0';
    wr_en_3_s <= '1' when wr_en = '1' and write_addr_in = "011" else '0';
    wr_en_4_s <= '1' when wr_en = '1' and write_addr_in = "100" else '0';
    wr_en_5_s <= '1' when wr_en = '1' and write_addr_in = "101" else '0';

    -- Definição dos Registradores
    reg0: reg16bits port map(clk, rst, wr_en_0_s, data_in, data_out_0_s);
    reg1: reg16bits port map(clk, rst, wr_en_1_s, data_in, data_out_1_s);
    reg2: reg16bits port map(clk, rst, wr_en_2_s, data_in, data_out_2_s);
    reg3: reg16bits port map(clk, rst, wr_en_3_s, data_in, data_out_3_s);
    reg4: reg16bits port map(clk, rst, wr_en_4_s, data_in, data_out_4_s);
    reg5: reg16bits port map(clk, rst, wr_en_5_s, data_in, data_out_5_s);

    -- ALTERADO: O multiplexador de saída agora usa 'read_addr_in'
    data_out <= data_out_0_s when read_addr_in = "000" else
                data_out_1_s when read_addr_in = "001" else
                data_out_2_s when read_addr_in = "010" else
                data_out_3_s when read_addr_in = "011" else
                data_out_4_s when read_addr_in = "100" else
                data_out_5_s when read_addr_in = "101" else
                "0000000000000000";

end architecture a_register_bank;
