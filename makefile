# Makefile para projeto VHDL com estrutura de diretórios no Windows/MSYS2

# Definição do compilador e flags
GHDL = ghdl
FLAGS = --std=08 --ieee=synopsys -frelaxed-rules

# Diretório base do projeto
PROJECT_DIR = C:/Users/vicen/Documents/ARQCOMP
WORK_DIR = $(PROJECT_DIR)/work

# Nome do testbench e entidade principal
TESTBENCH = unidade_controle_tb
ENTITY = unidade_controle_tb

# Definição dos diretórios dos componentes
ACC_DIR = $(PROJECT_DIR)/ACC
REG16_DIR = $(PROJECT_DIR)/REG16
REGBANK_DIR = $(PROJECT_DIR)/REGISTER_BANK
ULA_DIR = $(PROJECT_DIR)/ULA
ULA_ACC_DIR = $(PROJECT_DIR)/ULA_ACC_BANK

ROM_DIR = $(PROJECT_DIR)/ROM
STATE_MACHINE_DIR = $(PROJECT_DIR)/STATE_MACHINE
PC_CONTROLLER_DIR = $(PROJECT_DIR)/PC_CONTROLLER
PC_ROM_DIR = $(PROJECT_DIR)/PC_ROM
UC_DIR = $(PROJECT_DIR)/UC

# Arquivos fonte com caminhos completos
SOURCES = $(ULA_DIR)/ula.vhd \
          $(REG16_DIR)/reg16bits.vhd \
          $(ACC_DIR)/accumulator.vhd \
          $(REGBANK_DIR)/register_bank.vhd \
          $(ULA_ACC_DIR)/ula_acc_bank.vhd \
		  $(PROJECT_DIR)/pc.vhd \
          $(ROM_DIR)/rom.vhd \
          $(STATE_MACHINE_DIR)/maquina_estados.vhd \
          $(PC_CONTROLLER_DIR)/pc_controller.vhd \
          $(PC_ROM_DIR)/pc_rom.vhd \
          $(UC_DIR)/unidade_controle.vhd \
          $(UC_DIR)/$(TESTBENCH).vhd

# Testbenches individuais para cada componente
TB_ROM = rom_tb
TB_STATE_MACHINE = maquina_estados_tb
TB_PC_CONTROLLER = pc_controller_tb
TB_PC_ROM = pc_rom_tb
TB_UC = unidade_controle_tb

# Arquivo de saída da forma de onda
WAVE_FILE = $(PROJECT_DIR)/$(ENTITY).vcd

# Tempo de simulação
SIM_TIME = 2000ns

# Alvo principal
all: simulate

# Cria diretório de trabalho se não existir
$(WORK_DIR):
	@mkdir -p $(WORK_DIR)

# Analisar todos os arquivos VHDL
analyze: $(WORK_DIR) clean-obj
	@echo "Analisando arquivos VHDL..."
	@for src in $(SOURCES); do \
		echo "  - $$src"; \
		$(GHDL) -a $(FLAGS) --workdir=$(WORK_DIR) "$$src" || exit 1; \
	done

# Elaborar o design
elaborate: analyze
	@echo "Elaborando design..."
	$(GHDL) -e $(FLAGS) --workdir=$(WORK_DIR) $(ENTITY) || exit 1

# Executar a simulação (sem a opção -Wno-numeric-std)
simulate: elaborate
	@echo "Executando simulacao por $(SIM_TIME)..."
	$(GHDL) -r $(FLAGS) --workdir=$(WORK_DIR) $(ENTITY) --vcd=$(WAVE_FILE) --stop-time=$(SIM_TIME)
	
# Visualizar as formas de onda no GTKWave
view: simulate
	@echo "Abrindo visualizador de ondas..."
	gtkwave $(WAVE_FILE)

# Simulações individuais para cada componente
test-rom: $(WORK_DIR) clean-obj
	@echo "Testando ROM..."
	$(GHDL) -a $(FLAGS) --workdir=$(WORK_DIR) $(ROM_DIR)/rom.vhd $(ROM_DIR)/$(TB_ROM).vhd
	$(GHDL) -e $(FLAGS) --workdir=$(WORK_DIR) $(TB_ROM)
	$(GHDL) -r $(FLAGS) --workdir=$(WORK_DIR) $(TB_ROM) --vcd=$(PROJECT_DIR)/$(TB_ROM).vcd --stop-time=$(SIM_TIME)
	gtkwave $(PROJECT_DIR)/$(TB_ROM).vcd

test-state-machine: $(WORK_DIR) clean-obj
	@echo "Testando Máquina de Estados..."
	$(GHDL) -a $(FLAGS) --workdir=$(WORK_DIR) $(STATE_MACHINE_DIR)/maquina_estados.vhd $(STATE_MACHINE_DIR)/$(TB_STATE_MACHINE).vhd
	$(GHDL) -e $(FLAGS) --workdir=$(WORK_DIR) $(TB_STATE_MACHINE)
	$(GHDL) -r $(FLAGS) --workdir=$(WORK_DIR) $(TB_STATE_MACHINE) --vcd=$(PROJECT_DIR)/$(TB_STATE_MACHINE).vcd --stop-time=$(SIM_TIME)
	gtkwave $(PROJECT_DIR)/$(TB_STATE_MACHINE).vcd

test-pc: $(WORK_DIR) clean-obj
	@echo "Testando PC..."
	$(GHDL) -a $(FLAGS) --workdir=$(WORK_DIR) $(PROJECT_DIR)/pc.vhd $(PC_CONTROLLER_DIR)/pc_controller.vhd $(PC_CONTROLLER_DIR)/$(TB_PC_CONTROLLER).vhd
	$(GHDL) -e $(FLAGS) --workdir=$(WORK_DIR) $(TB_PC_CONTROLLER)
	$(GHDL) -r $(FLAGS) --workdir=$(WORK_DIR) $(TB_PC_CONTROLLER) --vcd=$(PROJECT_DIR)/$(TB_PC_CONTROLLER).vcd --stop-time=$(SIM_TIME)
	gtkwave $(PROJECT_DIR)/$(TB_PC_CONTROLLER).vcd

test-pc-rom: $(WORK_DIR) clean-obj
	@echo "Testando PC com ROM..."
	$(GHDL) -a $(FLAGS) --workdir=$(WORK_DIR) $(PROJECT_DIR)/pc.vhd $(ROM_DIR)/rom.vhd $(PC_CONTROLLER_DIR)/pc_controller.vhd $(PC_ROM_DIR)/pc_rom.vhd $(PC_ROM_DIR)/$(TB_PC_ROM).vhd
	$(GHDL) -e $(FLAGS) --workdir=$(WORK_DIR) $(TB_PC_ROM)
	$(GHDL) -r $(FLAGS) --workdir=$(WORK_DIR) $(TB_PC_ROM) --vcd=$(PROJECT_DIR)/$(TB_PC_ROM).vcd --stop-time=$(SIM_TIME)
	gtkwave $(PROJECT_DIR)/$(TB_PC_ROM).vcd

test-uc: $(WORK_DIR) clean-obj
	@echo "Testando Unidade de Controle..."
	$(GHDL) -a $(FLAGS) --workdir=$(WORK_DIR) $(PROJECT_DIR)/pc.vhd $(ROM_DIR)/rom.vhd $(STATE_MACHINE_DIR)/maquina_estados.vhd $(UC_DIR)/unidade_controle.vhd $(UC_DIR)/$(TB_UC).vhd
	$(GHDL) -e $(FLAGS) --workdir=$(WORK_DIR) $(TB_UC)
	$(GHDL) -r $(FLAGS) --workdir=$(WORK_DIR) $(TB_UC) --vcd=$(PROJECT_DIR)/$(TB_UC).vcd --stop-time=$(SIM_TIME)
	gtkwave $(PROJECT_DIR)/$(TB_UC).vcd

# Limpar arquivos temporários
clean-obj:
	@echo "Limpando arquivos de objeto..."
	@rm -f $(WORK_DIR)/*.o $(WORK_DIR)/*.cf


# Limpar arquivos temporários
clean-obj:
	@echo "Limpando arquivos de objeto..."
	@rm -f $(WORK_DIR)/*.o $(WORK_DIR)/*.cf

# Limpar todos os arquivos gerados
clean: clean-obj
	@echo "Limpando todos os arquivos gerados..."
	@rm -f $(PROJECT_DIR)/*.vcd $(PROJECT_DIR)/*.ghw
	@rm -rf $(WORK_DIR)

# Metas fictícias (não correspondem a arquivos)
.PHONY: all analyze elaborate simulate view clean clean-obj help

# Ajuda
help:
	@echo "Alvos disponíveis:"
	@echo "  all              - Analisa, elabora e simula o sistema completo (padrão)"
	@echo "  analyze          - Apenas analisa os arquivos VHDL"
	@echo "  elaborate        - Analisa e elabora o design"
	@echo "  simulate         - Executa a simulação do sistema completo"
	@echo "  view             - Executa a simulação e abre o GTKWave"
	@echo "  test-rom         - Testa o componente ROM isoladamente"
	@echo "  test-state-machine - Testa a Máquina de Estados isoladamente"
	@echo "  test-pc          - Testa o Program Counter isoladamente"
	@echo "  test-pc-rom      - Testa a integração PC+ROM isoladamente"
	@echo "  test-uc          - Testa a Unidade de Controle completa"
	@echo "  clean            - Remove todos os arquivos gerados"
	@echo "  help             - Mostra esta mensagem de ajuda"
