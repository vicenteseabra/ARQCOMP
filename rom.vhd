library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        clk      : in  std_logic;
        endereco : in  unsigned(6 downto 0);
        dado     : out unsigned(17 downto 0)
    );
end entity rom;

architecture a_rom of rom is
    type mem is array (0 to 127) of unsigned(17 downto 0);

    -- Opcodes (simplificado para este exemplo)
    constant NOP_OP     : unsigned(3 downto 0) := "0000";
    constant MOV_RR_OP  : unsigned(3 downto 0) := "0001"; -- Rd <= Rs
    constant ADD_ACC_OP : unsigned(3 downto 0) := "0010"; -- ACC <= ACC + Rs
    constant SUB_ACC_OP : unsigned(3 downto 0) := "0011"; -- ACC <= ACC - Rs
    constant LD_OP      : unsigned(3 downto 0) := "0100"; -- Rd <= Imm
    constant MOV_ACC_RS_OP: unsigned(3 downto 0) := "0101"; -- ACC <= Rs
    constant MOV_RD_ACC_OP: unsigned(3 downto 0) := "0110"; -- Rd <= ACC
    constant JMP_OP     : unsigned(3 downto 0) := "1111";

    constant conteudo_rom : mem := (

        -- R3 = "00011", R4 = "00100", R5 = "00101"

        -- A. LD R3, #5
        --    Op=0100, Rd=R3(00011), Imm=5 (0000101)
        0   => "0100" & '0' & "011" & "0000" & "000101" , -- LD R3, 5

        -- B. LD R4, #8
        --    Op=0100, Rd=R4(00100), Imm=8 (0001000)
        1   =>"0100" & '0' & "100" & "00000" & "01000"  , -- LD R4, 8

        -- C. Soma R3 com R4 e guarda em R5 (R5 <= R3 + R4)
        --    1. ADD  R3 (ACC <= ACC + R3)
        --       Op=0010, Rs=R3(00011)
        2   => "0010" & "00" & "00000" & "0000" & "011", -- ADD_ACC R3
        --    2. ADD R4 (ACC <= ACC + R4)
        --       Op=0010, Rs=R4(00100)
        3   => "0010" & "00" & "00000" & "0000" & "100", -- ADD_ACC R4

        --    3. MOV_RD_ACC R5 (R5 <= ACC)
        --       Op=0101, Rd=R5(101)
        4   => "0101" & '0' & "101" & "000" & "0000" & "000", -- MOV_RD_ACC R5

        -- D. Subtrai 1 de R5 (R5 <= R5 - 1)

        --    1. LD Acc, 1 (setamos Acc pra 1)
        --       Op=0100, f=(1), Rd=R0(000), Imm=0 (000001)
        5   => "0100" & '1' & "000000" & "0000001" , -- LD Acc, 0

        --    2.sub_ACC_RS R5 (ACC <= R5 - ACC)
        --       Op=0101, Rs=R5(101)
        6   => "0011" & '0' & "101" & "000" & "0000101", -- MOV_ACC_RS R5

        --    3. MOV_RD_ACC R5 (R5 <= ACC)
        --       Op=0101, Rd=R5(101)
        7   => "0101" & '0' & "101" & "000" & "0000" & "000", -- MOV_RD_ACC R5

        -- E. Salta para o endereço 20
        --    Op=1111, Addr=20 (0010100) -> Usando instr_s(8 downto 2) para addr
        8   => "1111" & "00" & "000" & "0010100" & "00",   -- JMP 20

        -- F. Zera R5 (LD R5, #0) (nunca será executada)
        --    Op=0100, Rd=R5(00101), Imm=0 (0000000)
        10  => "0100" & "01" & "00101" & "0000000", -- LD R5, 0
        11  => NOP_OP & "00000000000000",
        12  => NOP_OP & "00000000000000",
        13  => NOP_OP & "00000000000000",
        14  => NOP_OP & "00000000000000",
        15  => NOP_OP & "00000000000000",
        16  => NOP_OP & "00000000000000",
        17  => NOP_OP & "00000000000000",
        18  => NOP_OP & "00000000000000",
        19  => NOP_OP & "00000000000000",

        -- G. No endereço 20, copia R5 para R3 (R3 <= R5)
        --    1. LD Acc, 0 (setamos Acc pra 0)
        --       Op=0100, f=(1), Rd=R0(00000), Imm=0 (000000)
        20   => "0100" & '1' & "000000" & "0000000" , -- LD Acc, 0

        --    2. ADD R5 (ACC <= ACC + R5)
        --       Op=0010, Rs=R5(101)
        21   => "0010" & "00" & "00000" & "0000" & "101", -- ADD_ACC R5

        --    3. MOV_RD_ACC R5 (R3 <= ACC)
        --       Op=0101, Rd=R3(011)
        22   => "0101" & '0' & "011" & "000" & "0000" & "000", -- MOV_RD_ACC R3

        23   => "0100" & '1' & "000000" & "0000000" , -- LD Acc, 0

        -- H. Salta para o passo C (endereço 2)
        --    Op=1111, Addr=2 (0000010)
        24  => "1111" & "00" & "000" & "0000010" & "00",   -- JMP 2
        -- I. Zera R3 (LD R3, #0) (nunca será executada)
        --    Op=0100, Rd=R3(00011), Imm=0 (0000000)
        25  => "0100" & "01" & "00011" & "0000000", -- LD R3, 0

        others => NOP_OP & "00000000000000" -- NOP para o resto
    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;