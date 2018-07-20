#ifndef __TYPEDEF_H_
#define __TYPEDEF_H_

#define _INLINE_        __attribute__((always_inline))
#define AT(x)           __attribute__((section(#x),used))
#define sec_used(x)     __attribute__((section(#x),used))
#define SEC_USED(x)     __attribute__((section(#x),used))
#define sec(x)          __attribute__((section(#x)))
#define SEC(x)          __attribute__((section(#x)))
#define AT(x)           __attribute__((section(#x),used))
#define SET(x)          __attribute__((x))
#define _GNU_PACKED_	__attribute__((packed))
#define _INLINE_        __attribute__((always_inline))
#define ALIGNED(x)      __attribute__((aligned(x)))
#define __weak          __attribute__((weak))
#define QLZ(x)         /* __attribute__((section(#x)))*/
#define SET_INTERRUPT   /* __attribute__((interrupt("SWITCH"))) */


#define AT_POWER        	AT(.poweroff_text)
#define AT_AUDIO        	AT(.audio_text)

#define AT_RAM 				AT(.common)
#define AT_VM 				AT(.vm)
#define AT_POWER_DOWN		AT(.powerdown_text)
#define AT_POWER_FLASH		AT(.poweroff_flash)


#ifndef likely
#define likely(x) __builtin_expect(!!(x), 1)
#endif /* ifndef likely */

#ifndef unlikely
#define unlikely(x) __builtin_expect(!!(x), 0)
#endif /* ifndef unlikely */

#define TRUE    1
#define FALSE   0

#define ARRAY_SIZE(array) (sizeof(array)/sizeof(array[0]))

#define BIT(n)     (1UL << (n))

#define SFR(sfr, start, len, dat)  (sfr = (sfr & ~((~(0xffffffff << (len))) << (start))) | (((dat) & (~(0xffffffff << (len)))) << (start)))

typedef unsigned long long u64;
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;
typedef signed long long s64;

typedef signed int s32;
typedef signed int s16;
typedef signed char s8;

typedef unsigned char BOOL, bit1;
typedef unsigned int tu32, tu16, tu8, tbool;

#ifndef NULL
#define NULL ((void *)0x0)
#endif

#endif

