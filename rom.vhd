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

    constant conteudo_rom : mem := (

        0 => LD_OP & B"0_011_0000000001", -- LD R3, 00
        1 => LD_OP & B"0_100_0000000001", -- LD R4, 00
        2 => MOV_ACC_RS_OP & "00000000000011", --MOV ACC <= R3
        3=> ADD_ACC_OP & "00000000000100", -- ADD ACC <= R4 + ACC
        4=> MOV_RD_ACC_OP & "01000000000000", -- MOV R4 <= ACC
        5=> LD_OP & B"1_000_0000000001", -- LD Acc <= 01
        6=> ADD_ACC_OP & "00000000000011", -- ADD ACC <= ACC + R3
        7=> MOV_RD_ACC_OP & "00110000000000", -- MOV R3 <= ACC
        8=> CMPI_OP & "00000000011110", -- CMPI 30
        9=> BCS_OP & B"01_000000001100", -- BCS 2
        10=> MOV_ACC_RS_OP & "00000000000100", -- MOV ACC <= R4
        11=> MOV_RD_ACC_OP & "01010000000001", -- MOV R5 <= ACC
        others => NOP_OP & "00000000000000" -- NOP para o resto
    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;