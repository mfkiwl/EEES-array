.phony: all log

CFLAGS := -O2 -std=c99

ifeq ($(VERBOSE),1)
CFLAGS := $(CFLAGS) -DVERBOSE
endif

all:
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall

log:
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DFGETC_LOG
	@./jpeg_decoder 2>fgetc.log
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DCOMP_LOG
	@./jpeg_decoder 2>comp.log
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DQTABLE_LOG
	@./jpeg_decoder 2>qtable.log
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DHTABLE_LOG
	@./jpeg_decoder 2> htable.log
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DFBLOCK_LOG
	@./jpeg_decoder 2>fblock.log
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DPBLOCK_LOG
	@./jpeg_decoder 2>pblock.log
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DCOLOR_LOG
	@./jpeg_decoder 2>color.log
	@$(CC) $(CFLAGS) $(wildcard *.c) -o jpeg_decoder -Wall -DFRAMEBUFFER_LOG
	@./jpeg_decoder 2>frame.log

clean:
	rm -rf ./jpeg_decoder
