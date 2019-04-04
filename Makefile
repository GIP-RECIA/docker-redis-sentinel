.PHONY: run down test down_test down_master down_slave configure check_vars

# Set dir of Makefile to a variable to use later
MAKEPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := $(dir $(MAKEPATH))

HOST := `hostname`

MASTER_NAME ?= defaultmaster
QUORUM ?= 2
ANNOUNCE_IP ?= $(shell getent hosts $(HOST) | head -1  | cut -d' ' -f1)

BOOL_VAL := y n
MASTERCONF_FILE := MASTER_CONF
SLAVECONF_FILE := SLAVE_CONF

configure:
	@:$(call check_defined, MASTER_DNS, is required)
	$(eval MASTER ?= $(shell getent hosts $(MASTER_DNS) | head -1 | cut -d' ' -f1))
	@:$(call check_defined, IS_MASTER, value y/n is required)
	@[ -f $(SLAVECONF_FILE) ] && rm $(SLAVECONF_FILE) || true
	@[ -f $(MASTERCONF_FILE) ] && rm $(MASTERCONF_FILE) || true
ifeq ($(IS_MASTER),y)
		$(info applying Master configuration)
		touch $(MASTERCONF_FILE)
else ifeq ($(IS_MASTER),n)
		$(info applying Slave configuration)
		touch $(SLAVECONF_FILE)
else
		$(error IS_MASTER=$(IS_MASTER) does not exist in $(BOOL_VAL))
endif
	@[ -f .env ] && mv .env .env.`date +'%Y%m%d_%H:%M:%S'` || true
	@echo "MASTER_NAME=$(MASTER_NAME)\nQUORUM=$(QUORUM)\nMASTER=$(MASTER)\nANNOUNCE_IP=$(ANNOUNCE_IP)" > .env
ifdef MEMORY
	@echo "MEMORY=$(MEMORY)\n" >> .env
endif
	@echo "Generated .env file :" && cat .env

run: .env
ifeq ($(shell test -e $(MASTERCONF_FILE) && echo -n yes),yes)
		$(info running redis + sentinel in master mode)
		@cat .env
		@docker-compose down && \
			docker-compose build --pull --no-cache && \
			docker-compose up -d --remove-orphans
else ifeq ($(shell test -e $(SLAVECONF_FILE) && echo -n yes),yes)
		$(info running redis + sentinel in slave mode)
		@cat .env
		@docker-compose down && \
			docker-compose build --pull --no-cache && \
			docker-compose -f docker-compose.yml -f docker-compose.slave.yml up -d --remove-orphans
else
		$(error run create_env to be able to define master or slave mod run)
endif

down: .env
ifeq ($(shell test -e $(MASTERCONF_FILE) && echo -n yes),yes)
		$(info stopping redis + sentinel in master mode)
		@docker-compose down
else ifeq ($(shell test -e $(SLAVECONF_FILE) && echo -n yes),yes)
		$(info stopping redis + sentinel in slave mode)
		@docker-compose -f docker-compose.yml -f docker-compose.slave.yml down
else
		$(error run create_env to be able to define master or slave mod run)
endif


master: .env
	@docker-compose down && \
		docker-compose build --pull --no-cache && \
		docker-compose up -d --remove-orphans

slave: .env
	@docker-compose down && \
		docker-compose build --pull --no-cache && \
		docker-compose -f docker-compose.yml -f docker-compose.slave.yml up -d --remove-orphans

test:
	@cd test && \
		docker-compose down && \
		docker-compose build --pull --no-cache && \
		docker-compose up -d --remove-orphans && \
		cd -

down_test:
	@cd test && \
		docker-compose down && \
		cd -

down_slave:
	@docker-compose  -f docker-compose.yml -f docker-compose.slave.yml down

down_master:
	@docker-compose down

check_vars:
	@:$(call check_defined, MASTER_NAME, is required)
	@:$(call check_defined, QUORUM, is required)
	@:$(call check_defined, MASTER, is required)
	@:$(call check_defined, ANNOUNCE_IP, is required)

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))
