#include <k_api.h>
#include <assert.h>
#include <stdio.h>

#if (RHINO_CONFIG_MM_TLF > 0)
extern void *__heap_start__;
extern void *__heap_end__;
extern void *__heap_len__;

k_mm_region_t g_mm_region[] = {{(uint8_t *)&__heap_start__, (size_t)&__heap_len__}};

int g_region_num = sizeof(g_mm_region)/sizeof(k_mm_region_t);
#endif /* RHINO_CONFIG_MM_TLF > 0 */


#if (RHINO_CONFIG_TASK_STACK_CUR_CHECK > 0)
size_t soc_get_cur_sp()
{
    size_t sp = 0;
    __asm__ volatile ("%0 = sp\n" : "=r"(sp));
    return sp;
}
#endif /* RHINO_CONFIG_TASK_STACK_CUR_CHECK > 0 */

#if (RHINO_CONFIG_MM_LEAKCHECK > 0)
extern int __bss_start__, __bss_end__;
void aos_mm_leak_region_init(void)
{
#if (RHINO_CONFIG_MM_DEBUG > 0)
    // FIXME: ??
    // krhino_mm_leak_region_init(&__bss_start__, &__bss_end__);
#endif
}

#endif /* RHINO_CONFIG_MM_LEAKCHECK */

void soc_err_proc(kstat_t err)
{
    (void)err;
    printf("soc_err_proc = %d\n", err);

    assert(0);
}

krhino_err_proc_t g_err_proc = soc_err_proc;
