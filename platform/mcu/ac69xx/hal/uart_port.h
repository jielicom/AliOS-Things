#ifndef __UART_PORT_H_
#define __UART_PORT_H_

#include <aos/aos.h>
#include <hal/hal.h>

#define MAX_UART_NUM  3

enum {
    UART_ISR_TYPE_DATA_COME = 0,
    UART_ISR_TYPE_WRITE_OVER,
    UART_ISR_TYPE_TIMEOUT,
};

typedef struct uart_info{
	void (*callback_fun)(uint8_t  value,void *p,uint8_t ist_flag);
}__uart_info;

int32_t hal_uart_init(uart_dev_t *uart);
int log_puts(const char *out);
void put_u32hex(uint32_t a);
#endif
