BUILD_PATH     = ./bin
SRC            = ./src/Main.swift
BINS           = $(BUILD_PATH)/defaultb

.PHONY: all clean install

all: $(BINS)

install: clean $(BINS)

clean:
	rm -rf $(BUILD_PATH)

$(BUILD_PATH)/defaultb: $(SRC)
	mkdir -p $(BUILD_PATH)
	swiftc -O $^ -o $@
