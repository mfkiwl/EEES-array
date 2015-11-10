typedef struct free_block {
  unsigned size;
  struct free_block* next;
} free_block;

extern unsigned __heap_start;

static unsigned heap_ptr;
static free_block free_block_list_head;

void init_malloc() {
  heap_ptr = __heap_start;
  free_block_list_head.size = 0;
  free_block_list_head.next = 0;
}

static const unsigned align_to = 16;

void* malloc(unsigned size) {
    size = (size + sizeof(free_block) + (align_to - 1)) & ~ (align_to - 1);
    free_block* block = free_block_list_head.next;
    free_block** head = &(free_block_list_head.next);
    while (block != 0) {
        if (block->size >= size) {
            *head = block->next;
            return ((char*)block) + sizeof(free_block);
        }
        head = &(block->next);
        block = block->next;
    }

    block = (free_block*)heap_ptr;
    heap_ptr += size;
    block->size = size;

    return ((char*)block) + sizeof(free_block);
}

void free(void* ptr) {
    if (!ptr) { return; }
    free_block* block = (free_block*)(((char*)ptr) - sizeof(free_block ));
    block->next = free_block_list_head.next;
    free_block_list_head.next = block;
}
