/******************************************************************************
 *  Extern Prameters
 *****************************************************************************/

.extern g_active_task
.extern g_preferred_ready_task
.extern krhino_stack_ovf_check

/******************************************************************************
 *  Export Functions
 *****************************************************************************/

.global  cpu_intrpt_save
.global  cpu_intrpt_restore
.global  cpu_task_switch
.global  cpu_intrpt_switch
.global  cpu_first_task_start


.text
.align 2

/**************************************************************************
 * Functions:
 *     size_t cpu_intrpt_save(void);
 *     void cpu_intrpt_restore(size_t cpsr);
 *************************************************************************/

.type cpu_intrpt_save, @function
cpu_intrpt_save:
    rep 2 {
        r1 = icfg
        r0 = r1
        r1 &= (~(1 << 8));
        icfg = r1
        rts
    }
.size cpu_intrpt_save, . - cpu_intrpt_save

.type cpu_intrpt_restore, @function
cpu_intrpt_restore:
    rep 2 {
        icfg = r0
        rts
    }
.size cpu_intrpt_restore, . - cpu_intrpt_restore

/**************************************************************************
 * Functions:
 *     void cpu_intrpt_switch(void);
 *     void cpu_task_switch(size_t cpsr);
 *************************************************************************/

#if 1
.type cpu_task_switch, @function
cpu_task_switch:
    [--sp] = {rets, r14-r0}
    [--sp] = {icfg, psr, rets}

    /* g_active_task->task_stack = sp */
    r0.l = g_active_task
    r0.h = g_active_task
    r0 = [r0]
    [r0] = sp

    // call krhino_stack_ovf_check

    /* fall through */
    goto __cpu_task_switch

.size cpu_task_switch, . - cpu_task_switch
#endif

.type cpu_intrpt_switch, @function
cpu_intrpt_switch:
    /* 如果是来自中断切换任务，则这个时候必然是中断的最后一层 */
    /* 原来任务的状态任务的栈上 */

#if 0
    r0.l = 0xFFEE
    r0.h = 0XFFEE
    call put_u32hex
    r0 = ssp
    call put_u32hex
#endif
    /* 这个时候 usp 是原来的任务的栈，
        ssp 是中断栈的栈顶 */
    r0 = ssp

    /* 首先，退出中断状态 */
    reti.l = .L_unbreak_int
    reti.h = .L_unbreak_int
    rti
.L_unbreak_int:
    /* 重新把 ssp 设置成初始状态，因为最后一次中断退出直接切换了任务
     * 这个时候并没有执行完栈回退的动作 */
    ssp = r0

__cpu_task_switch:

#if 0
    r0.l = 0xBEEF
    r0.h = 0xDEAD
    call put_u32hex
    r0 = sp
    call put_u32hex
#endif

    r0.l = g_preferred_ready_task
    r0.h = g_preferred_ready_task

    r1.l = g_active_task
    r1.h = g_active_task

    r0 = [r0]
    [r1] = r0

    r0.l = g_active_task
    r0.h = g_active_task

    r0 = [r0]
    sp = [r0]

#if 0
    r0 = sp
    call put_u32hex
    r0 = [sp + (4 * 0)] # rets
    call put_u32hex
    r0 = [sp + (4 * 1)] # psr
    call put_u32hex
    r0 = [sp + (4 * 2)] # icfg
    call put_u32hex
    r0 = [sp + (4 * 18)] # pc
    call put_u32hex
#endif

    /* restore new task context */
    rep 2 {
        {icfg, psr, rets} = [sp++]
        {pc, r14-r0} = [sp++]
    }
.size cpu_intrpt_switch, . - cpu_intrpt_switch

/**************************************************************************
 * Functions:
 *     void cpu_first_task_start(void);
 *************************************************************************/
 .type cpu_first_task_start, @function
 cpu_first_task_start:
    r0.l = g_active_task
    r0.h = g_active_task
    r0 = [r0]
    sp = [r0]

    rep 2 {
        {icfg, psr, rets} = [sp++]
        {pc, r14-r0} = [sp++]
    }
.size cpu_first_task_start, . - cpu_first_task_start

/*************************************************************************
 * interrupt handlers
 * 
 ************************************************************************/
.type __pi32_interrupt_common_handler, @function
__pi32_interrupt_common_handler:
    /* 中断中可能会发生任务切换，见 krhino_intrpt_exit
     * 但是这个只会发生在最外层的中断，也就是从中断状态返回到普通状态的时候
     * 中断和普通任务使用不同的栈
     * 当第一次进入某个中断的时候，我们需要把当前任务的状态存储到任务的栈上
     * 如果不是第一次进入中断了，这个时候就不需要保存任务状态了
     */
    /* icfg[3:0] 中，1的个数表示了嵌套层次 */
    [--sp] = {r1, r0}
    r0 = icfg
    r0 = r0 & 0xf
    r1 = r0 - 1
    r0 = r1 & r0 /* r0 = ((icfg & 0xf) - 1) & (icfg & 0xf) */
    
    /* 这个时候，已经不是第一次进入中断 */
    if (r0 != 0) goto .L_not_level_1

    /* 第一次进入中断，首先需要保存状态到任务的栈上 */
    r0 = usp
    [--r0] = {pc}
    [--r0] = {r14-r0}
    [--r0] = {icfg, psr, rets}

    /* 需要修复一些错误的值 */
    r1 = [sp + (2 * 4)] /* 正确的 rets */
    [r0 + (0 * 4)] = r1

    r1 = [sp + (3 * 4)]
    [r0 + (1 * 4)] = r1 /* psr */

    r1 = icfg
    r1 &= (~0xf)
    r1 |= 0x300
    [r0 + (2 * 4)] = r1 /* 修正 icfg，能进入中断，表示 GIE[0], GIE[1]都是1 */

    r1 = [sp + (0 * 4)] /* 正确的 r0 */
    [r0 + (3 * 4)] = r1

    r1 = [sp + (1 * 4)] /* 正确的 r1 */
    [r0 + (4 * 4)] = r1

    r1 = reti
    [r0 + (18 * 4)] = r1 /* pc 修正为 reti */


    /* 最后，更新对应的 active_task[cpu_num]->task_stack */
    r1.l = g_active_task
    r1.h = g_active_task
    r1 = [r1] # g_active_task[0]
    [r1] = r0 # 更新栈

.L_not_level_1:
    {r1, r0} = [sp++]
    rts
.size __pi32_interrupt_common_handler, . - __pi32_interrupt_common_handler

.macro define_int_entry isr
    .type __pi32_interrupt_irq_\isr\()_entry, @function
    .global __pi32_interrupt_irq_\isr\()_entry
    __pi32_interrupt_irq_\isr\()_entry:
        [--sp] = {psr, rets}
        call __pi32_interrupt_common_handler
        {psr, rets} = [sp++]
        [--sp] = {r3-r0}
        [--sp] = {psr, rets, reti}
        call irq_\isr
        {psr, rets, reti} = [sp++]
        {r3-r0} = [sp++]
        rti

    .size __pi32_interrupt_irq_\isr\()_entry, . - __pi32_interrupt_irq_\isr\()_entry
.endm

define_int_entry timer0_isr_fun
define_int_entry uart0_isr_fun
