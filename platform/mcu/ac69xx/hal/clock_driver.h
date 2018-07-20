#ifndef	_CLOCK_DRIVER_H_
#define _CLOCK_DRIVER_H_

#include <k_types.h>
#include "common/typedef.h"

u32 get_sfc_clk_hz(void);
void apc_freq_set_api(u32 out_freq);
void rfi_freq_set_api(u32 out_freq);
u32 get_lsb_div(void);
void set_lsb_div(u8 div);
u32 get_lsb_clk_hz(void);
u32 get_hsb_clk_hz(void);
void clock_set_freq_fast(u32 out_freq);
void set_sys_div(u8 div);
void hw_clock_init(u8 sys_in, u32 input_freq, u32 out_freq);
void hw_clock_switching(u32 out_freq);

u32 clock_get_usb_freq(void);

u32 clock_get_dac_freq(void);

u32 clock_get_apc_freq(void);

u32 clock_get_uart_freq(void);

u32 clock_get_bt_freq(void);

u32 clock_get_sfc_freq(void);

u32 clock_get_hsb_freq(void);

u32 clock_get_lsb_freq(void);

u32 clock_get_iosc_freq(void);

u32 clock_get_osc_freq(void);

u32 clock_get_sys_freq(void);
void clock_dump(void);
void clock_set_apc_freq(u32 freq, u8 apc_src);

#define USB_CLK         clock_get_usb_freq()
#define DAC_CLK         clock_get_dac_freq()
#define APC_CLK         clock_get_apc_freq()
#define UART_CLK        clock_get_uart_freq()
#define BT_CLK          clock_get_bt_freq()


#define SFC_CLK         clock_get_sfc_freq()
#define SYS_CLK         clock_get_hsb_freq()
#define LSB_CLK         clock_get_lsb_freq()

#define IOSC_CLK        clock_get_iosc_freq()
#define OSC_CLK         clock_get_osc_freq()

void set_spi_speed_auto(void);

#endif
