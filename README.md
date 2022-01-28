Mainline Linux on (First Generation) Kindle Fire
================================================

Maintained by Hansem Ro (`hansemro@outlook.com`).

This repo contains documentation for bringing up mainline Linux on First Generation Kindle Fire tablet (also known as Otter or KC1).

Status
======

With some patches to mainline kernel, the device can boot into userspace with several devices working.

### Device Tree Status Table

| Hardware           | Status  | Comments |
| ------------------ | ------- | -------- |
| CPU                | Works   | TI OMAP4430 GP |
| Remote Processor   | &cross; | Ducati Sub System; Dual Core Cortex-M3; DSP; IPU |
| GPU                | &cross; | PowerVR SGX540 |
| LPDDR2             | Works   | 512MB |
| eMMC               | Works   | 8GB; currently mapped to `/dev/mmcblk0` |
| UART               | Works   | UART3 = `/dev/ttyO2` |
| DSS/Framebuffer    | Works   | omapdrm successfully registers framebuffer |
| LCD Panel          | Works   | [MIPI DPI] 1024x600 32 bits/pixel |
| LCD Backlight      | Partial | GPTimer10 PWM driven; simple on/off support only |
| Touchscreen        | Works   | [i2c] Ilitek 2107; requires additional kernel patches |
| PMIC               | Partial | TI TWL6030 |
| Green LED          | Works   | TWL6030 PWM led |
| Orange LED         | Works   | TWL6030 PWM led |
| Power Button       | Works   | TI TWL6030 |
| RTC                | Works   | TI TWL6030 |
| Battery            | Works   | 3V3 4400mAh Li-Ion Battery |
| Fuel Gauge         | Works   | [i2c] TI BQ27541 |
| Charger Controller | Works   | [i2c] Sumit SMB347 |
| USB Gadget/OTG     | Works   | CDC/ACM gadget works; OTG works |
| WLAN               | Works   | [MMC/SDIO] TI WL1271 |
| Accelerometer      | Works   | [i2c] Bosch BMA250 |
| Audio              | &cross; | TI TWL6040 |
| Audio Codec        | &cross; | [i2c] TI AIC3110 |
| Temperature Sensor | Works   | [i2c] National Semiconductor/TI LM75 ~ TI TMP105 |
| Light Sensor       | &cross; | [i2c] Sensortek STK22x7 |
| SmartReflex        | &cross; | dmesg reports errors |

Guide
=====

Clone this repo and checkout a branch that matches Linux kernel version.

Credits
=======

- Michael John Sakellaropoulos (brought up panel + drm support among other helpful work)
- Paul Kocialkowski (initial work on device tree for Kindle Fire)
- Andrew Litt (modified omap4boot/usbboot for Kindle Fire)
- Hashcode (U-Boot work for Kindle Fire)
- Linus Torvalds (Linux)
- Others who were also important in making this possible
