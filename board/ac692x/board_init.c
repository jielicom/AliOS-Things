#include <hal/soc/soc.h>

extern unsigned __flash_kv_start__;
extern unsigned __flash_kv_size__;

hal_logic_partition_t hal_partitions[] =
{
    [0] = {
        .partition_owner        = HAL_FLASH_EMBEDDED,
        .partition_description  = "KV Region",
        .partition_start_addr   = (size_t)&__flash_kv_start__,
        .partition_length       = (size_t)&__flash_kv_size__, // 64K
        .partition_options      = PAR_OPT_READ_EN | PAR_OPT_WRITE_EN,
    },
};
