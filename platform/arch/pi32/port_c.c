
#include <k_api.h>
#include <k_task.h>

#if 0
void cpu_task_switch(void)
{
    int log_puts(const char *);
    log_puts("cpu_task_switch\n");
    log_puts(" FROM ");
    extern ktask_t *g_active_task[];
    extern ktask_t *g_preferred_ready_task[];
    log_puts(g_active_task[0]->task_name);
    log_puts(" TO ");
    log_puts(g_preferred_ready_task[0]->task_name);
    log_puts("\n");
}
#endif

void *cpu_task_stack_init(cpu_stack_t *stack_base, size_t stack_size,
                          void *arg, task_entry_t entry)
{
    cpu_stack_t *stk;
    uint32_t temp = (uint32_t)(stack_base + stack_size);

#if 0
    int log_puts(const char *);
    void put_u32hex(uint32_t a);
    log_puts("cpu_task_stack_init -> ");
    put_u32hex((uint32_t)stack_base);
    put_u32hex((uint32_t)arg);
    put_u32hex((uint32_t)stack_size);
    put_u32hex((uint32_t)temp);
    for (int i = 0; i < 20; ++i) {
        log_puts("  - ");
        put_u32hex((uint32_t)(stack_base - i));
        put_u32hex(*(stack_base - i));
    }
    {
        int log_puts(const char *);
        void put_u32hex(uint32_t a);
        unsigned icfg;
        __asm__ volatile ("%0 = icfg" : "=r"(icfg));
        log_puts("icfg => ");
        put_u32hex(icfg);
    }
#endif

    /* stack aligned by 4 byte */
    temp &= 0xfffffffc;
    stk = (cpu_stack_t *)temp;

    /* task context saved & restore by hardware: */
    *(--stk) = (cpu_stack_t)entry;       /* Entry Point      */
    *(--stk) = (cpu_stack_t)0x14141414L; /* R14 */
    *(--stk) = (cpu_stack_t)0x13131313L; /* R13 */
    *(--stk) = (cpu_stack_t)0x12121212L; /* R12 */
    *(--stk) = (cpu_stack_t)0x11111111L; /* R11 */
    *(--stk) = (cpu_stack_t)0x10101010L; /* R10 */
    *(--stk) = (cpu_stack_t)0x09090909L; /* R9  */
    *(--stk) = (cpu_stack_t)0x08080808L; /* R8  */
    *(--stk) = (cpu_stack_t)0x07070707L; /* R7  */
    *(--stk) = (cpu_stack_t)0x06060606L; /* R6  */
    *(--stk) = (cpu_stack_t)0x05050505L; /* R5  */
    *(--stk) = (cpu_stack_t)0x04040404L; /* R4  */
    *(--stk) = (cpu_stack_t)0x03030303L; /* R3  */
    *(--stk) = (cpu_stack_t)0x02020202L; /* R2  */
    *(--stk) = (cpu_stack_t)0x01010101L; /* R1  */
    *(--stk) = (cpu_stack_t)arg;         /* R0 : argument            */
    *(--stk) = (cpu_stack_t)0x00000300L; /* ICFG */
    *(--stk) = (cpu_stack_t)0x00000000L; /* Program State Register   */
    *(--stk) = (cpu_stack_t)krhino_task_deathbed; /* RETS            */
    return stk;
}

#if 0
extern ktask_t *g_active_task[];
void cpu_first_task_start()
{
    int log_puts(const char *out);
void put_u32hex(uint32_t a);
    log_puts("cpu_first_task_start\n");
    put_u32hex((uint32_t)g_active_task[0]);
    put_u32hex((uint32_t)g_active_task[0]->task_stack);
    uint32_t *task_stack = (uint32_t *)g_active_task[0]->task_stack;
    log_puts("task_stack content\n");
    for (int i = 0; i <= 32; ++i) {
        put_u32hex(task_stack[i]);
    }
    log_puts("name: ");
    log_puts(g_active_task[0]->task_name);
}
#endif
