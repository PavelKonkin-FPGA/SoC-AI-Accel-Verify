#include "system.h"
#include "altera_avalon_pio_regs.h"
#include <stdint.h>

int main() {
    while (1) {
        uint32_t status = IORD_ALTERA_AVALON_PIO_DATA(PIO_STATUS_BASE);
        uint16_t header = IORD_ALTERA_AVALON_PIO_DATA(PIO_DATA_PEEK_BASE);

        if (status > 0) {
            if (header < 0x1000) {
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_BASE, 4);
            } else if (header < 0x2000) {
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_BASE, 8);
            } else if (header < 0x4000) {
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_BASE, 16);
            } else if (header < 0x8000) {
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_BASE, 32);
            } else if (header < 0xC000) {
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_BASE, 64);
            } else {
                IOWR_ALTERA_AVALON_PIO_DATA(PIO_MODE_BASE, 128);
            }
        }
    }
    return 0;
}