#ifndef _AC69XX_FLASH_H_
#define _AC69XX_FLASH_H_

enum {
    SET_READ_CMD_MODE = 0,
};

enum {
    //1bit mode
    WINBOND_READ_DATA_MODE = (1 << 0),
    WINBOND_FAST_READ_MODE = (1 << 1),
    //2bit mode
    WINBOND_FAST_READ_DUAL_IO_NORMAL_READ_MODE  = (1 << 2),
    WINBOND_FAST_READ_DUAL_IO_CONTINUOUS_READ_MODE = (1 << 3),
    WINBOND_FAST_READ_DUAL_OUTPUT_MODE     = (1 << 4),
    //4bit mode
    WINBOND_FAST_READ_QUAD_IO_NORMAL_READ_MODE   = (1 << 5),
    WINBOND_FAST_READ_QUAD_IO_CONTINUOUS_READ_MODE = (1 << 6),
    WINBOND_FAST_READ_QUAD_OUTPUT_MODE     = (1 << 7),

};

void flash_ioctrl(int ctrl, ...);

#endif