NAME = ac69xx

# Host architecture is PI32
HOST_ARCH := pi32

# Host MCU alias for OpenOCD
HOST_OPENOCD := ac69xx

$(NAME)_TYPE := kernel
$(NAME)_COMPONENTS += platform/arch/pi32
$(NAME)_COMPONENTS += libc rhino hal framework.common cli

GLOBAL_INCLUDES += include

GLOBAL_DEFINES += CONFIG_NO_TCPIP		\
				  CONFIG_AOS_KV_PTN=0

$(NAME)_SOURCES := startup/startup_ac69xx.S	\
					aos/aos.c				\
					aos/soc_impl.c			\
					common/syscall.c		\
					common/libs_printf.c

$(NAME)_INCLUDES += .

$(NAME)_PREBUILT_LIBRARY = ac69xx_hardware.a

GLOBAL_LDS_FILES += platform/mcu/ac69xx/memory.ld.S

ifeq ($(APP),bootloader)
####################################################
# Building bootloader
####################################################

GLOBAL_INCLUDES	+=

else
######################################################
# Building standard application to run with bootloader
######################################################

PRE_APP_BUILDS += bootloader

endif # APP=bootloader

GLOBAL_DEFINES += CONFIG_PI32
