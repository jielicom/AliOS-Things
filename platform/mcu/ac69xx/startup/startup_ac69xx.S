.section .stack, "a"
		 .space 0x1B00-0xB00
		 .global _stack_usp
_stack_usp:
		 .space 0xB00
		 .global _stack_ssp
_stack_ssp:


#define hi(x) ((x)>>16)
#define lo(x) ((x)&0xffff)
.section .text
	.align 2
	.global _start
	.extern memset
	.extern pll_init
	.type _start,@function
	.org 0

.extern board_main
.extern stack_detect_init
.extern app_irq_init
.extern task_run
.extern exception_isr_handler


_start:
	r8 = r0
	r7 = r1
	r5 = r2
	r6 = r3
	ssp.h = _stack_ssp
	ssp.h = _stack_ssp
	sp.l  = _stack_usp
	sp.l  = _stack_usp

	r0.h  = __bss_start__ 
	r0.l  = __bss_start__ 
	r1    = 0
	r2.h  = __bss_size__ 
	r2.l  = __bss_size__ 

	if (r2 == 0) goto .L_2
.L_1:
	cmp r2, 32
	if (nzcv >= 0) {
        r3 = 0
        r2 = r2 - 32
	} else {
        r3 = r2
	    r2 = 0
    }
	rep r3 {
	    b[r0++] = r1
    }
	if (r2 != 0) goto .L_1
.L_2:

	r0.h = __data_runtime_start__ 
	r0.l = __data_runtime_start__ 
	r1.h = __data_store_start__
	r1.l = __data_store_start__
	r2.h = __data_size__
	r2.l = __data_size__

	if (r2 == 0) goto .L4
.L2:
	cmp r2, 32
	if (nzcv >= 0) {
	    r4 = 0
	    r2 = r2 - 32
	} else {
        r4 = r2
	    r2 = 0
	}
    rep r4 {
        r3 = b[r1++]
        b[r0++] = r3
    }
    if (r2 != 0) goto .L2
.L4:

	r0 = r8
	r1 = r7
	r2 = r5
	r3 = r6
	goto main

	.section .bss, "aw"
	.align 4
IntCounter:
	.space 0x4

	.section .text.int

/*
	void CPU_INT_DIS(void);
	void CPU_INT_EN(void);
*/
	.global CPU_INT_DIS
	.type CPU_INT_DIS, @function

	.global CPU_INT_EN
	.type CPU_INT_EN, @function

CPU_INT_DIS:
	cli
	r0.l = IntCounter
	r0.h = IntCounter
	r1   = [r0 + 0]
	r1   = r1 + 1
	[r0 + 0] = r1
	rts

	.size CPU_INT_DIS, . - CPU_INT_DIS

CPU_INT_EN:
	r0.l = IntCounter
	r0.h = IntCounter
	r1 = [r0 + 0]
	r1 = r1 + -1
	[r0 + 0] = r1
	if (nzcv == 0) {
		sti
	}
	rts
	.size CPU_INT_EN, . - CPU_INT_EN
