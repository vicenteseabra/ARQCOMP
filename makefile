# description:
#   run with make simulate tb=testBenchxxxxx

CC = ghdl
SIM = gtkwave
WORKDIR = debug
WAVEDIR = wave
QUIET = @ #remove '@' if you want the commands to show in terminal

tb?= testBench

# analyze these first since some other circuits depend on these
VHDL_SOURCES += ula.vhd
VHDL_SOURCES += reg16bits.vhd
VHDL_SOURCES += accumulator.vhd
VHDL_SOURCES += register_bank.vhd
VHDL_SOURCES += pc.vhd
VHDL_SOURCES += unidade_controle.vhd


# add rest of the files in directory for analyzing
VHDL_SOURCES += \$(wildcard *.vhd)


TBS = $(wildcard *.vhd)

TB = $(tb)

CFLAGS += --warn-binding
CFLAGS += --warn-no-library # turn off warning on design replace with same name


.PHONY: analyze
analyze: clean
	@echo ">>> analyzing designs..."
	$(QUIET)mkdir -p $(WORKDIR)
	$(QUIET)$(CC) -a $(CFLAGS) --workdir=$(WORKDIR) $(VHDL_SOURCES) $(TBS)

.PHONY: elaborate
elaborate: analyze
	@echo ">>> elaborating designs.."
	@echo ">>> sources..."
	$(QUIET)mkdir -p $(WORKDIR)
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) ula
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) reg16bits
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) accumulator
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) register_bank
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) ula_acc_bank
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) pc
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) maquina_estados
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) unidade_controle
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) rom

	@echo ">>> test benches..."
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) ula_tb
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) reg16bits_tb
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) ula_acc_bank_tb
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) maquina_estados_tb
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) unidade_controle_tb
	$(QUIET)$(CC) -e $(CFLAGS) --workdir=$(WORKDIR) rom_tb

.PHONY: simulate
simulate: elaborate
	@echo ">>> simulating design:" $(TB)
	$(QUIET)mkdir -p $(WAVEDIR)
	$(QUIET)$(CC) -r $(CFLAGS) --workdir=$(WORKDIR) $(TB) --wave=$(WAVEDIR)/$(TB).ghw
	$(QUIET)$(SIM) $(WAVEDIR)/$(TB).ghw


.PHONY: clean
clean:
	@echo ">>> cleaning design..."
	$(QUIET)ghdl --remove --workdir=$(WORKDIR)
	$(QUIET)rm -f $(WORKDIR)/*
	$(QUIET)rm -rf $(WORKDIR)
	$(QUIET)rm -f $(WAVEDIR)/*
	$(QUIET)rm -rf $(WAVEDIR)
	@echo ">>> done..."