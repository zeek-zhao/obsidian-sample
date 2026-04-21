SHELL := /bin/bash

# Paths
WORK_DIR := $(abspath .)

#LOG_DEBUG	  ?= 1
ifeq ($(LOG_DEBUG),1)
	export LOG_DEBUG=1
endif
# 颜色定义(可用 NO_COLOR=1 禁用, USE_TPUT=1 使用 tput)
USE_TPUT        ?= 0
NO_COLOR        ?= 0

ifeq ($(USE_TPUT),1)
	BOLD  := $(shell tput bold)
	RESET := $(shell tput sgr0)
	RED   := $(shell tput setaf 1)
	GREEN := $(shell tput setaf 2)
	YELLOW:= $(shell tput setaf 3)
	BLUE  := $(shell tput setaf 4)
else
	BOLD  := \033[1m
	RESET := \033[0m
	RED   := \033[31m
	GREEN := \033[32m
	YELLOW:= \033[33m
	BLUE  := \033[34m
endif

ifeq ($(NO_COLOR),1)
	BOLD  :=
	RESET :=
	RED   :=
	GREEN :=
	YELLOW:=
	BLUE  :=
endif

# 统一输出时间戳
NOW = $(shell date +"%Y-%m-%d %H:%M:%S")

# 执行宏: $(call RUN,<命令>)
define RUN
	@echo -e "${BOLD}${BLUE}---------COMMAND START---------${RESET}"
	@echo -e "[$(NOW)][$(BOLD)$(BLUE)CMD$(RESET)] $(YELLOW)$(1)$(RESET)"
	@if $(1); then \
		echo -e "$(GREEN)[ok]$(RESET)"; \
	else \
		rc=$$?; \
		echo -e "$(RED)[fail] exit $$rc$(RESET)"; \
		exit $$rc; \
	fi
	@echo -e "${BOLD}${BLUE}----------COMMAND END----------${RESET}"
endef

# 简洁模式: LOG_DEBUG=0 时不打印命令
ifeq ($(LOG_DEBUG),0)
	override define RUN
		@$(1)
	endef
endif

.PHONY: help init update_version_patch update_version_minor update_version_major

help:
	@echo "DevOps Makefile targets:"
	@echo "  update_version_patch -> bump patch version"
	@echo "  update_version_minor -> bump minor version"
	@echo "  update_version_major -> bump major version"
init:
	$(call RUN,npm install)
	$(call RUN,git config --global user.name "Zeek Zhao")
	$(call RUN,git config --global user.email "zeek.zhao@devops.com")
	$(call RUN,git config -l)

update_version_patch:
	$(call RUN,npm run release:patch)
update_version_minor:
	$(call RUN,npm run release:minor)
update_version_major:
	$(call RUN,npm run release:major)
