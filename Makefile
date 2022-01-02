mats := integration algebre topologie premaster

.PHONY: clean all figures help newchapter init release $(mats)

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

help: ## Print available targets
	@echo "${PURPLE}:: ${BOLD}${GREEN}$$(basename $$(pwd))${RESET} ${PURPLE}::${RESET}"
	@echo ""
	@echo "Usage:"
	@echo "  | make all -j8  ${YELLOW}# Tout compiler avec 8 threads${RESET}"
	@echo "  | make algebre  ${YELLOW}# Cours d'algèbre${RESET}"
	@echo ""
	@echo "$(YELLOW)List of PHONY targets:$(RESET)"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  ${GREEN}${BOLD}%-22s${RESET} %s\n", $$1, $$2}'
	@echo "$(YELLOW)List of courses:$(RESET)"
	@echo "  $(GREEN)$(BOLD)$(mats)$(RESET)"
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

release: all ## Create a new release
	@gh release create "$$(date +"%Y-%m-%d-%H-%M")" target/* -t "$$(date +"%d-%m-%Y %H:%M")" -n ''

clean: ## Delete compiled documents and latex-generated files
	rm -rf target build
	cd src/figures && latexmk -C || true
	mkdir build
	ln -s ../indexstyle.ist build/

all: $(PDFS) ## Build everything

figures: $(FIGURES) ## Build every figure in src/figures/

src/figures/%.pdf: src/figures/%.tex
	@echo "$(GREEN)Compiling figure $(YELLOW)$(<F)$(GREEN) into $(YELLOW)$@$(RESET)"
	cd src/figures/ && $(LATEXMK) $(<F) && latexmk -silent -c $(<F)

$(PDFS): | target

target:
	mkdir target

.SECONDEXPANSION:
PER := %
target/%.pdf: %.tex src/preamble.tex src/preamble/*.tex $$(findstring src/%.tex,$$(wildcard src/*.tex)) $$(wildcard src/%-*.tex) $$(patsubst $$(PER).tex,$$(PER).pdf,$$(wildcard src/figures/%-*.tex))
	@echo "$(GREEN)Compiling document $(YELLOW)$(<F)$(GREEN) into $(YELLOW)$@$(RESET)"
	$(LATEXMK) $<
	cp build/$(@F) $@

$(mats): target/$$@.pdf
