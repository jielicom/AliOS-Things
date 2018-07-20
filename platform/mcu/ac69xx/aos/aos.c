#include <aos/aos.h>
#include <k_api.h>
#include <aos/kernel.h>
#include <stdio.h>
#include <stdlib.h>
#include <hal/clock_driver.h>
#include <hal/clock_interface.h>
#include <hal/uart_port.h>
#include <hal/flash/flash_port.h>

#include "hw/irq_api.h"
#include "hw/timer.h"
#include <stdio.h>

#define AOS_START_STACK 1024
ktask_t *g_aos_init;


static const u8 irq_index_2_prio_tab[][2] = {
    {IRQ_EXCEPTION_IDX, 	0},
    {IRQ_TICK_TMR_IDX, 		0},
#if UI_ENABLE
    {IRQ_TIME0_IDX, 		2}, //解决蓝牙软中断导致频闪的问题
#else
    {IRQ_TIME0_IDX, 		1},
#endif
    {IRQ_TIME1_IDX, 		1},
    {IRQ_TIME2_IDX, 		0},
    {IRQ_TIME3_IDX, 		0},
    {IRQ_USB_SOF_IDX, 		2},
    {IRQ_USB_CTRL_IDX, 		2},
    {IRQ_RTC_IDX, 			0},
    {IRQ_ALINK_IDX, 		2},
    {IRQ_DAC_IDX, 			3},
    {IRQ_PORT_IDX, 			0},
    {IRQ_SPI0_IDX, 			0},
    {IRQ_SPI1_IDX, 			0},
    {IRQ_SD0_IDX, 			2},
    {IRQ_SD1_IDX, 			2},
    {IRQ_UART0_IDX, 		0},
    {IRQ_UART1_IDX, 		3},
    {IRQ_UART2_IDX, 		0},
    {IRQ_PAP_IDX, 			0},
    {IRQ_IIC_IDX, 			0},
    {IRQ_SARADC_IDX, 		0},
    {IRQ_PDM_LINK_IDX, 		1},
    {IRQ_BREDR_IDX, 		2},
    {IRQ_BT_CLKN_IDX, 		2},
    {IRQ_BT_DBG_IDX, 		1},
    {IRQ_BT_PCM_IDX, 		2},
    {IRQ_SRC_IDX, 			1},
    {IRQ_EQ_IDX, 			2},
    {IRQ_SPDIF_IDX, 		3},
    {IRQ_FM_IDX, 			2},
    {IRQ_FM_LOFC_IDX,		1},
    {IRQ_BLE_RX_IDX, 		2},
    {IRQ_BLE_EVENT_IDX,		2},
    {IRQ_SOFT_REC_IDX,  	0},
    {IRQ_SOFT0_IDX, 		1},
    {IRQ_SOFT_IDX, 			0},
    {IRQ_SOFT_ECHO_IDX, 	0},
    {IRQ_UI_LCD_IDX, 	   0},
};

extern int vfs_init(void);
extern int aos_kv_init(void);
extern int vfs_device_init(void);
extern int aos_framework_init(void);
extern void flash_mode_init(void);
extern int application_start(int argc, char **argv);
static void aos_system_init(void *arg)
{
    log_puts(" ->> aos_system_init\n");
    {
        int log_puts(const char *);
        void put_u32hex(uint32_t a);
        unsigned icfg;
        __asm__ volatile ("%0 = icfg" : "=r"(icfg));
        log_puts("icfg => ");
        put_u32hex(icfg);
    }
    (void)arg;
    log_puts("before kv init\n");
    flash_ioctrl(SET_READ_CMD_MODE, 0x10);
    flash_mode_init();
    aos_kv_init();
    log_puts("before vfs init\n");
    vfs_init();
    vfs_device_init();
    log_puts("before aos loop init\n");
	aos_loop_init();
    log_puts("before aos_framwork_init\n");
    aos_framework_init();
    log_puts("before application_start\n");
    application_start(0, NULL);
}

typedef u32 UINT;
struct flash_cfg {
    UINT flash_id;
    //flash容量
    UINT flash_size;
    //代码、数据、配置区的总大小
    UINT flash_file_size;
    UINT sdfile_head_addr;
    //[1:0]data width 0--1wire_1bit 1--2wire_1bit 2--2wire_2bit 3/4--4wire_4bit
    //[2] SPI_IS_CONTINUE_READ
    //[3] SPI_IS_OUTPUT
    //[4] SPI_NWIRE_SEND_CMD
    //[8:5] SPI_CS_DESELECT
    UINT spi_run_mode;
    UINT spi_div;
    UINT flash_base;
    //低16有效，对应flash reg0和reg1
    UINT protected_arg;
    //配置区起始地址
    UINT cfg_zone_addr;
    //配置区大小
    UINT cfg_zone_size;
};
typedef struct _APP_USE_FLASH_SYS_CFG {
    UINT cfg_zone_addr;
    UINT flash_size;
    UINT cfg_zone_size;
    UINT btif_addr;
    UINT btif_len;
    UINT vmif_addr;
    UINT vmif_len;
} APP_USE_FLASH_SYS_CFG;
struct sdr_cfg {
    UINT sdram_refresh_cycle;
    UINT sdram_refresh_time;
    UINT sdram_cas_latency;
    UINT sdram_trfc;
    UINT sdram_trp;
    UINT sdram_trcd;
    UINT sdram_colum;
    UINT sdram_clk_hd_en;
    UINT sdram_trrd;
    UINT sdram_clkoe;
    UINT sdram_size;
    UINT sdram_fast_clock_rate;
};
struct clk_cfg {
    UINT pll_sel;
    UINT osc_freq;
    UINT osc_src;
    UINT osc_hc_en;
    UINT osc_1pin_en;
};

typedef struct _FLASH_SYS_CFG {
    struct flash_cfg flash_cfg;
//    struct sdr_cfg sdr_cfg;
    struct clk_cfg clk_cfg;
} FLASH_SYS_CFG;

FLASH_SYS_CFG sys_cfg;

int main(int cfg_addr)
{
    irq_init();

    irq_index_tab_reg((void *)irq_index_2_prio_tab,sizeof(irq_index_2_prio_tab));

	hw_clock_init(SYS_CLOCK_IN,24000000L,120000000);
    hal_uart_init(NULL);

	log_puts("aos_init\n");

    log_puts("after irq init\n");

    timer_init();

    log_puts("after timer init\n");

    aos_init();

    log_puts("after aos init\n");

    memcpy(&sys_cfg, (void *)(0x1000000 + cfg_addr), sizeof(FLASH_SYS_CFG));
    printf("SFC BASE %x\r\n", sys_cfg.flash_cfg.flash_base);

    krhino_task_dyn_create(&g_aos_init, "my-aos-init", 0, AOS_DEFAULT_APP_PRI, 0, AOS_START_STACK, aos_system_init, 1);

    log_puts("after dyn create\n");
    {
        unsigned icfg;
        __asm__ volatile ("%0 = icfg" : "=r"(icfg));
        log_puts("icfg => ");
        put_u32hex(icfg);
    }

    puts("call puts\n");
    printf("a test of printf %d, %x\n", 1234, 0x1234);

    /* 否则 LOG 不能正常工作，里面会初始化一些mutex等 */
    aos_cli_init();

    aos_start();
    return 0;
}
