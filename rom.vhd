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
    constant CMP_OP     : unsigned(3 downto 0) := "1000"; -- Comparação
    constant CMPI_OP    : unsigned(3 downto 0) := "1001"; -- Comparação Imediato
    constant JMP_OP     : unsigned(3 downto 0) := "1111";

    constant conteudo_rom : mem := (

        0 => "010010001111111110", -- LD Acc, 0xFE
        1 => CMPI_OP & "10001111111110", -- CMPI 0xFE
        2 => CMPI_OP & "10001111111111", -- CMPI 0xFF
        others => NOP_OP & "00000000000000" -- NOP para o resto
    );
begin
    dado <= conteudo_rom(to_integer(endereco));
end architecture a_rom;