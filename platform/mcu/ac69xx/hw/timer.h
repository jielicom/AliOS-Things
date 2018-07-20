#ifndef _AC69XX_HW_TIMER_H_
#define _AC69XX_HW_TIMER_H_

#include "common/typedef.h"
#include "hal/clock_driver.h"

void timer_init(void);

enum {
    TIMER_CLK_SRC_SYSCLK          = 0,
    TIMER_CLK_SRC_IOSIGN,
    TIMER_CLK_SRC_OSC,
    TIMER_CLK_SRC_RC,
};

#endif /* defined _AC69XX_HW_TIMER_H_ */