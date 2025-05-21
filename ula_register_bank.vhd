library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ula_register_bank is
    port (
        clk : in std_logic;
        rst : in std_logic;
        reg_wr_en, acc_wr_en : in std_logic;
        reg_load_src, acc_load_src : in unsigned(15 downto 0);
        ula_out_view : out unsigned(15 downto 0); --Pinos pra debugar
        register_out_view : out unsigned(15 downto 0); --Pinos pra debugar
        accumulator_out_view : out unsigned(15 downto 0); --Pinos pra debugar
        ula_op : in unsigned(1 downto 0);
        ula_src : in std_logic;
        register_code : in unsigned(2 downto 0);
        imm_const : in unsigned (15 downto 0); --Constante imediata
        flag_zero : out std_logic;
        flag_neg : out std_logic;
        flag_carry : out std_logic
    );
end entity ula_register_bank;

architecture a_ula_register_bank of ula_register_bank is

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

    component register_bank
    port(
        data_in   : in unsigned(15 downto 0);
        clk       : in std_logic;
        wr_en     : in std_logic;
        reg_code  : in unsigned(2 downto 0);
        rst       : in std_logic;
        data_out  : out unsigned(15 downto 0)
    );
    end component;

    component accumulator
        port(
            clk, rst, wr_en: in std_logic;
            data_in: in unsigned(15 downto 0);
            data_out: out unsigned(15 downto 0)
        );
    end component;

        --====== Signal Definition ======--
    signal ula_in_s, ula_out_s : unsigned(15 downto 0);
    signal accumulator_in_s, accumulator_out_s : unsigned(15 downto 0);
    signal register_in_s: unsigned(15 downto 0);
    signal register_bank_out_s : unsigned(15 downto 0);
    signal flag_zero_s, flag_neg_s, flag_carry_s  : std_logic;

    begin

        --====== Load data in registers ======--
    register_in_s <= imm_const when reg_load_src = '1' else
        accumulator_out_s;

     --====== Component Definition ======-
    ula: ula port map(ula_in_s,accumulator_out_s,ula_op,ula_out_s,flag_zero_s,flag_neg,flag_carry_s);
    register_bank: register_bank port map(register_in_s,clk,reg_wr_en,register_code,rst,register_bank_out_s);
    accumulator: accumulator port map(clk,rst,acc_wr_en,accumulator_in_s,accumulator_out_s);

             --====== Mux ======--
    ula_in_s <= register_bank_out_s when ula_src = '0' else
        imm_const; --A constante a ser usada

    accumulator_in_s <= imm_const when acc_load_src = '1' else
        ula_out_s; --Saída da Ula ou carga de constante

      --====== Output Definition ======--
    ula_out_view <= ula_out_s;
    register_out_view <= register_bank_out_s;
    accumulator_out_view <= accumulator_out_s;
    flag_zero <= flag_zero_s;
    flag_neg <= flag_neg_s;
    flag_carry <= flag_carry_s;

end a_ula_register_bank;