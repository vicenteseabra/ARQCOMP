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
    constant LW_OP      : unsigned(3 downto 0) := "0001"; -- Load Word
    constant SW_OP      : unsigned(3 downto 0) := "0110"; -- Store Word (mesmo opcode do LW, mas com diferente controle na UC)
    constant ADD_ACC_OP : unsigned(3 downto 0) := "0010"; -- ACC <= ACC + Rs
    constant SUB_ACC_OP : unsigned(3 downto 0) := "0011"; -- ACC <= ACC - Rs
    constant LD_OP      : unsigned(3 downto 0) := "0100"; -- Rd <= Imm
    constant MOV_ACC_RS_OP: unsigned(3 downto 0) := "0111"; -- ACC <= Rs
    constant MOV_RD_ACC_OP: unsigned(3 downto 0) := "0101"; -- Rd <= ACC
    constant CMP_OP     : unsigned(3 downto 0) := "1000"; -- Comparação
    constant CMPI_OP    : unsigned(3 downto 0) := "1001"; -- Comparação Imediato
    constant BNE_OP     : unsigned(3 downto 0) := "1101"; -- BNE (Branch if Not Equal)
    constant BCS_OP     : unsigned(3 downto 0) := "1110"; -- BCS (Branch if Carry Set)
    constant JMP_OP     : unsigned(3 downto 0) := "1111"; -- JMP


    -- Campos dos registradores (3 bits)
    constant R0 : unsigned(2 downto 0) := "000";
    constant R1 : unsigned(2 downto 0) := "001";
    constant R2 : unsigned(2 downto 0) := "010";
    constant R3 : unsigned(2 downto 0) := "011";
    constant R4 : unsigned(2 downto 0) := "100";
    constant R5 : unsigned(2 downto 0) := "101";

    constant conteudo_rom : mem := (

 --------------------------------------------------------------------------------------------
        -- FASE 1: TESTE DE ESCRITA (SW)
        -- Formato SW: 0110 0000 000e eeee ee
        --------------------------------------------------------------------------------------------
        0  => "0100" & '1' & "000" & "1000101110", -- LD ACC, 222
        1  => "0110" & "0000000" & "0110010",     -- SW MEM[50], ACC

        2  => "0100" & '1' & "000" & "0111101101", -- LD ACC, 125
        3  => "0110" & "0000000" & "0001010",     -- SW MEM[10], ACC

        4  => "0100" & '1' & "000" & "1010101010", -- LD ACC, 170 (0xAA)
        5  => "0110" & "0000000" & "0011001",     -- SW MEM[25], ACC

        --------------------------------------------------------------------------------------------
        -- FASE 2: "RESFRIAMENTO" E TESTE DE REGISTRADORES
        --------------------------------------------------------------------------------------------
        -- Formato LD (Reg): 0100 0ddd cccc cccc cc
        6  => "0100" & '0' & R0  & "1001111000",     -- LD R0, 158
        7  => "0100" & '0' & R1  & "0011001000",     -- LD R1, 50

        -- Formato MOV_ACC_RS: 0111 0000 0000 000s ss
        -- Formato ADD:        0010 0000 0000 000s ss
        8  => "0111" & "00000000000" & R0,          -- MOV ACC, R0
        9  => "0010" & "00000000000" & R1,          -- ADD ACC, R1

        -- Formato MOV_RD_ACC: 0101 0ddd 0000 0000 00
        10 => "0101" & '0' & R5  & "0000000000",     -- MOV R5, ACC

        --------------------------------------------------------------------------------------------
        -- FASE 3: TESTE DE LEITURA (LW)
        -- Formato LW: 0001 0ddd 000e eeee ee
        --------------------------------------------------------------------------------------------
        11 => "0001" & '0' & R2  & "000" & "0110010", -- LW R2, MEM[50]
        12 => "0001" & '0' & R3  & "000" & "0001010", -- LW R3, MEM[10]
        13 => "0001" & '0' & R4  & "000" & "0011001", -- LW R4, MEM[25]
        14 => "0001" & '0' & R2  & "000" & "0001010", -- LW R2, MEM[50]


        --------------------------------------------------------------------------------------------
        -- FASE 4: FIM DO TESTE
        -- Formato JMP: 1111 00aa aaaa aaaa aa
        --------------------------------------------------------------------------------------------
        15 => "1111" & "00" & "00000001110" & "0", -- JMP 14

        -- Preenche o resto da ROM com NOPs
        others => "000000000000000000" -- NOP


    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;