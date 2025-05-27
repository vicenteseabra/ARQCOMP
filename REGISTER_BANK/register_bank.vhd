library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_bank is
    port(
        data_in   : in unsigned(15 downto 0);
        clk       : in std_logic;
        wr_en     : in std_logic;
        reg_code  : in unsigned(2 downto 0);
        rst       : in std_logic;
        data_out  : out unsigned(15 downto 0)
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

  signal data_out_0_s,data_out_1_s,data_out_2_s : unsigned(15 downto 0);
  signal data_out_3_s,data_out_4_s,data_out_5_s : unsigned(15 downto 0);

  signal wr_en_0_s,wr_en_1_s,wr_en_2_s : std_logic := '0';
  signal wr_en_3_s,wr_en_4_s,wr_en_5_s : std_logic := '0';

  begin

    --WRITE ENABLE
    wr_en_0_s <= '1' when wr_en = '1' and reg_code = "000" else '0';
    wr_en_1_s <= '1' when wr_en = '1' and reg_code = "001" else '0';
    wr_en_2_s <= '1' when wr_en = '1' and reg_code = "010" else '0';
    wr_en_3_s <= '1' when wr_en = '1' and reg_code = "011" else '0';
    wr_en_4_s <= '1' when wr_en = '1' and reg_code = "100" else '0';
    wr_en_5_s <= '1' when wr_en = '1' and reg_code = "101" else '0';


    --REGISTER DEFINITION
    reg0: reg16bits port map(clk,rst,wr_en_0_s,data_in,data_out_0_s);
    reg1: reg16bits port map(clk,rst,wr_en_1_s,data_in,data_out_1_s);
    reg2: reg16bits port map(clk,rst,wr_en_2_s,data_in,data_out_2_s);
    reg3: reg16bits port map(clk,rst,wr_en_3_s,data_in,data_out_3_s);
    reg4: reg16bits port map(clk,rst,wr_en_4_s,data_in,data_out_4_s);
    reg5: reg16bits port map(clk,rst,wr_en_5_s,data_in,data_out_5_s);

    data_out <= data_out_0_s when reg_code = "000" else
                data_out_1_s when reg_code = "001" else
                data_out_2_s when reg_code = "010" else
                data_out_3_s when reg_code = "011" else
                data_out_4_s when reg_code = "100" else
                data_out_5_s when reg_code = "101" else
                "0000000000000000";

end architecture a_register_bank;