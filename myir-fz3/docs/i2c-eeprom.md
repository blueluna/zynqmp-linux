# I2C eeprom

CAT24C256W

32 kb

```shell
dd if=/sys/bus/i2c/devices/i2c-1/1-0051/eeprom of=/home/erik/eeprom.bin bs=1 count=32768
```

```shell
xxd /home/erik/eeprom.bin
```
