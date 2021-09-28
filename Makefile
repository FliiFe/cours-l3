INTEGRATION_FN := integration
ALGEBRE_FN := algebre
TOPOLOGIE_FN := topologie
ANALYSE_FN := analyse

.PHONY: clean all figures help integration newchapter init

BLACK        := $(shell tput -Txterm setaf 0)
RED          := $(shell tput -Txterm setaf 1)
GREEN        := $(shell tput -Txterm setaf 2)
YELLOW       := $(shell tput -Txterm setaf 3)
LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
PURPLE       := $(shell tput -Txterm setaf 5)
BLUE         := $(shell tput -Txterm setaf 6)
WHITE        := $(shell tput -Txterm setaf 7)
BOLD         := $(shell tput bold)
RESET        := $(shell tput -Txterm sgr0)

SHELL := /usr/bin/env bash
PDFS := $(addprefix target/,$(patsubst %.tex,%.pdf,$(wildcard *.tex)))
FIGURES := $(patsubst %.tex,%.pdf,$(wildcard src/figures/*.tex))
ifndef VERBOSE
SILENT := -silent
endif
LATEXMK := latexmk $(SILENT)
INTEGRATION_TARGET := target/$(INTEGRATION_FN).pdf
ALGEBRE_TARGET     := target/$(ALGEBRE_FN).pdf
TOPOLOGIE_TARGET   := target/$(TOPOLOGIE_FN).pdf
ANALYSE_TARGET     := target/$(ANALYSE_FN).pdf

help: ## Print available targets
	@echo "${PURPLE}:: ${BOLD}${GREEN}$$(basename $$(pwd))${RESET} ${PURPLE}::${RESET}"
	@echo ""
	@echo "Example:"
	@echo "  | make all -j8  ${YELLOW}# Tout compiler avec 8 threads${RESET}"
	@echo "  | make integration  ${YELLOW}# Cours d'intégration, théorie de la mesure et de probabilités${RESET}"
	@echo "  | make algebre  ${YELLOW}# Cours d'algèbre ${RESET}"
	@echo "  | make topologie  ${YELLOW}# Cours de topologie et de calcul différentiel${RESET}"
	@echo "  | make analyse  ${YELLOW}# Cours d'analyse complexe${RESET}"
	@echo ""
	@echo "$(YELLOW)List of PHONY targets:$(RESET)"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  ${GREEN}${BOLD}%-22s${RESET} %s\n", $$1, $$2}'
	@if ! [[ -z "$(FIGURES)" ]]; then echo "$(YELLOW)List of figures:$(RESET)"; fi
	@for f in $(FIGURES); do \
		echo " " $${f}; \
	done
	@if [[ "$(PDFS)" != "$(INTEGRATION_TARGET)" ]] && ! [[ -z "$(PDFS)" ]]; then \
		echo "$(YELLOW)List of chapters:$(RESET)"; fi
	@for f in $(PDFS); do \
		if [[ $$f =~ .*-[0-9].* ]]; then \
			echo " " $$f; \
		fi; \
	done

newchapter: ## Make a new chapter
	@echo -n -e "${GREEN}Chapter filename (no extension):${RESET} "; \
	read fn; \
	echo -n -e "${GREEN}Chapter name:${RESET} "; \
	read cn; \
	if [[ "$$fn" =~ ^[a-zA-Z0-9-]+$$ ]]; then \
		if ! [[ -z "$$cn" ]]; then \
			cat .latex_templates/chapter-base.tex | sed s/FN/$$fn/g >$$fn.tex; \
			cat .latex_templates/chapter-src.tex | sed "s/CN/$$cn/g" >src/$$fn.tex; \
		else \
			echo "Chapter name empty"; \
			exit 1; \
		fi \
	else \
		echo "Filename does not match ^[a-zA-Z0-9-]+$$"; \
		exit 1; \
	fi;

integration: $(INTEGRATION_TARGET) ## Cours d'intégration, théorie de la mesure et de probabilités
algebre: $(ALGEBRE_TARGET) ## Cours d'algèbre
analyse: $(ANALYSE_TARGET) ## Cours d'analyse complexe
topologie: $(TOPOLOGIE_TARGET) ## Cours de topologie et de calcul différentiel

all: $(PDFS) ## Build everything

src/figures/%.pdf: src/figures/%.tex
	@echo "$(GREEN)Compiling figure $(YELLOW)$(<F)$(GREEN) into $(YELLOW)$@$(RESET)"
	cd src/figures/ && $(LATEXMK) $(<F) && latexmk -silent -c $(<F)

$(INTEGRATION_TARGET): $(INTEGRATION_FN).tex src/$(INTEGRATION_FN)-*.tex src/preamble.tex src/preamble/*.tex $(FIGURES)
	@echo "$(GREEN)Compiling document $(YELLOW)$(<F)$(GREEN) into $(YELLOW)$@$(RESET)"
	$(LATEXMK) $<
	cp build/$(@F) $@

$(ANALYSE_TARGET): $(ANALYSE_FN).tex src/$(ANALYSE_FN)-*.tex src/preamble.tex src/preamble/*.tex $(FIGURES)
	@echo "$(GREEN)Compiling document $(YELLOW)$(<F)$(GREEN) into $(YELLOW)$@$(RESET)"
	$(LATEXMK) $<
	cp build/$(@F) $@

$(ALGEBRE_TARGET): $(ALGEBRE_FN).tex src/$(ALGEBRE_FN)-*.tex src/preamble.tex src/preamble/*.tex $(FIGURES)
	@echo "$(GREEN)Compiling document $(YELLOW)$(<F)$(GREEN) into $(YELLOW)$@$(RESET)"
	$(LATEXMK) $<
	cp build/$(@F) $@

$(TOPOLOGIE_TARGET): $(TOPOLOGIE_FN).tex src/$(TOPOLOGIE_FN)-*.tex src/preamble.tex src/preamble/*.tex $(FIGURES)
	@echo "$(GREEN)Compiling document $(YELLOW)$(<F)$(GREEN) into $(YELLOW)$@$(RESET)"
	$(LATEXMK) $<
	cp build/$(@F) $@

$(PDFS): | target

target:
	mkdir target

clean: ## Delete compiled documents and latex-generated files
	rm -rf target build
	cd src/figures && latexmk -C || true
	mkdir build
	ln -s ../indexstyle.ist build/

figures: $(FIGURES) ## Build every figure in src/figures/

.SECONDEXPANSION:
PER := %
target/%.pdf: %.tex src/preamble.tex src/preamble/*.tex src/%.tex $$(patsubst $$(PER).tex,$$(PER).pdf,$$(wildcard src/figures/%-*.tex))
	@echo "$(GREEN)Compiling $(YELLOW)$(<)$(GREEN) into $(YELLOW)$@$(RESET)"
	$(LATEXMK) $<
	cp build/$(@F) $@

