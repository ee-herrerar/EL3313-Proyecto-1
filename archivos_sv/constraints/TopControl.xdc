## ============================================================
## TopControl - Basys 3 Constraints
## Proyecto Whack-a-Mole - Subsistema de Control FPGA
## ============================================================

## ============================================================
## Clock de 100 MHz
## ============================================================
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ============================================================
## RESET - Botón central de la placa
## ============================================================
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports RESET]

## ============================================================
## Recepción UART Externa (Pmod JA)
## ============================================================
## rx -> Pmod JA, Pin 1 
## De la UART TX a este pin.
## GND a Pmod JA Pin 5
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports rx]

## ============================================================
## Solicitud hacia la lógica discreta (Pmod JB)
## ============================================================
## LlamadaTopoOut -> Pmod JB, Pin 1
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports LlamadaTopoOut]

## ============================================================
## 8 Botones Externos (Pmod JC)
## ============================================================
## Se utiliza PULLDOWN true para evitar que el pin quede "flotando" 
## cuando el botón no está presionado. Al presionar, envía 3.3V al pin.

## Top Row of Pmod JC (Pins 1, 2, 3, 4)
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[0]}] ;# JC1
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[1]}] ;# JC2
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[2]}] ;# JC3
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[3]}] ;# JC4

## Bottom Row of Pmod JC (Pins 7, 8, 9, 10)
set_property -dict { PACKAGE_PIN L17 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[4]}] ;# JC7
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[5]}] ;# JC8
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[6]}] ;# JC9
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {BotonesRaw[7]}] ;# JC10

## ============================================================
## LEDs de estado
## ============================================================
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports LED_Activo]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports LED_GameOver]

## ============================================================
## Display de 7 segmentos
## seg[6:0] = {a,b,c,d,e,f,g}
## ============================================================
set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]
set_property -dict { PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN U8 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN V8 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]

set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports dp]

set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN U4 IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN V4 IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN W4 IOSTANDARD LVCMOS33 } [get_ports {an[3]}]

## ============================================================
## Configuración de Voltaje del dispositivo
## ============================================================
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
