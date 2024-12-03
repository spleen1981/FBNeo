void sc01_init(INT32 clock, void (*ar_cb)(INT32), INT32 reva);
void sc01_exit();
void sc01_set_buffered(INT32 (*pCPUCyclesCB)(), INT32 nCPUMhz);
void sc01_reset();
void sc01_write(UINT8 data);
void sc01_inflection_write(UINT8 data);
INT32 sc01_read_request();
void sc01_set_clock(INT32 newclock);
void sc01_scan(INT32 nAction, INT32 *pnMin);
void sc01_update(INT16 *output, INT32 samples_len);
