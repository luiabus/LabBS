# Specification

- 码速率：10.23MHz
- 码片长度：10230
- 每1bit电文码片伪码周期数：10
- 码速率：10.23MHz
- 电文速率：100 bit/s (10 ms/bit)
- 电文长度：100 bit

- 电文内容（最低位先发）：

```
bit 0-5:   second (6 bits)
bit 6-11:  minute (6 bits)
bit 12-16: hour (5 bits)
bit 17-21: day (5 bits)
bit 22-25: month (4 bits)
bit 26-33: year (8 bits)
bit 34-67: reserved (34 bits)
bit 68-75: 0xff (8 bits)
bit 76-83: 0x00 (8 bits)
bit 84-91: 0xff (8 bits)
bit 92-99: 0x55 (8 bits)
```
