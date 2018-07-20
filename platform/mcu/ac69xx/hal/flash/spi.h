#ifndef	_SPI_INTERFACE_H_
#define _SPI_INTERFACE_H_

#include "common/typedef.h"

enum {
    SET_2BIT_MODE = 0,
    SET_WIRE_MODE,
};

#define SPI_PARM_VALID_MASK	  0x5a5a0000
#define SPI_MODE_MASK         (0x00000c00|SPI_PARM_VALID_MASK)
#define SPI_CLK_MASK    	  0x000000ff

enum {
    SPI_2WIRE_MODE = 0x0 | SPI_PARM_VALID_MASK,
    SPI_ODD_MODE   = 0x00000400 | SPI_PARM_VALID_MASK,
    SPI_DUAL_MODE  = 0x00000800 | SPI_PARM_VALID_MASK,
    SPI_QUAD_MODE  = 0x00000c00 | SPI_PARM_VALID_MASK,
};

struct spi_driver {
    void (*wait_ok)();
    void (*cs)(u8);

    void (*write_byte)(u8);
    u8(*read_byte)();

    s32(*read)(u8 *, u16);
    s32(*write)(u8 *, u16);

    void (*suspend)(void);
    void (*resume)(void);

    void (*ioctrl)(int, ...);
};

// #define REGISTER_SPI_DRIVER(drv) \
// const struct spi_driver *__spi0_drv \
// __attribute__((section(".spi0_drv"))) = &drv
#define REGISTER_SPI_DRIVER(drv) \
    const struct spi_driver *__spi0_drv \
            sec(.vm) = &drv

extern const struct spi_driver *__spi0_drv;

#endif
