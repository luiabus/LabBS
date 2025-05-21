#define AD1enable 1 // 1号AD初始化开关，为0时跳过AD1，避免因AD损坏导致卡初始化

int ad9361_init(void);

int ad9361_setatt(char command, char channel, char attenuation);