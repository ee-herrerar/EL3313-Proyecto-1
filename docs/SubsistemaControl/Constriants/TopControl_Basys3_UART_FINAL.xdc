###############################################################################
# TopControl - Basys 3
#
# clk              -> Clock 100 MHz
# RESET            -> BTNC
# SW0              -> Habilita UART simulada / inicia el juego
# BotonesRaw[7:0]  -> Pmod JA
# LlamadaTopoOut   -> JB1
# UART_RX          -> JB2
# LED_Activo       -> LD0
# LED_GameOver     -> LD1
# LED_Topo[7:0]    -> LD8-LD15
# seg/an/dp        -> Display 7 segmentos
###############################################################################


###############################################################################
# CLOCK - 100 MHz
###############################################################################

set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -add -name sys_clk_pin \
    -period 10.00 \
    -waveform {0 5} \
    [get_ports clk]


###############################################################################
# RESET - BTNC
###############################################################################

set_property PACKAGE_PIN U18 [get_ports RESET]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]


###############################################################################
# SW0 - HABILITAR UART SIMULADA
#
# SW0 = 0 -> el juego espera una respuesta UART
# SW0 = 1 -> se simula automáticamente UARTValid cada vez que
#            GameFSM solicita un nuevo topo
###############################################################################

set_property PACKAGE_PIN V17 [get_ports SW0]
set_property IOSTANDARD LVCMOS33 [get_ports SW0]


###############################################################################
# BOTONES EXTERNOS - PMOD JA
#
# ORDEN INVERTIDO
#
# BotonesRaw[0] -> JA10
# BotonesRaw[1] -> JA9
# BotonesRaw[2] -> JA8
# BotonesRaw[3] -> JA7
# BotonesRaw[4] -> JA4
# BotonesRaw[5] -> JA3
# BotonesRaw[6] -> JA2
# BotonesRaw[7] -> JA1
#
# Los botones físicos son activos en LOW.
# La inversión lógica se realiza dentro de TopControl.
###############################################################################

# Botón 0 - JA10
set_property PACKAGE_PIN G3 [get_ports {BotonesRaw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[0]}]

# Botón 1 - JA9
set_property PACKAGE_PIN H2 [get_ports {BotonesRaw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[1]}]

# Botón 2 - JA8
set_property PACKAGE_PIN K2 [get_ports {BotonesRaw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[2]}]

# Botón 3 - JA7
set_property PACKAGE_PIN H1 [get_ports {BotonesRaw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[3]}]

# Botón 4 - JA4
set_property PACKAGE_PIN G2 [get_ports {BotonesRaw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[4]}]

# Botón 5 - JA3
set_property PACKAGE_PIN J2 [get_ports {BotonesRaw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[5]}]

# Botón 6 - JA2
set_property PACKAGE_PIN L2 [get_ports {BotonesRaw[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[6]}]

# Botón 7 - JA1
set_property PACKAGE_PIN J1 [get_ports {BotonesRaw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {BotonesRaw[7]}]


###############################################################################
# PMOD JB
###############################################################################

# JB1 - Solicitud de nuevo topo hacia el circuito discreto
set_property PACKAGE_PIN A14 [get_ports LlamadaTopoOut]
set_property IOSTANDARD LVCMOS33 [get_ports LlamadaTopoOut]

# JB2 - UART RX física
# Se conserva aunque actualmente USAR_UART_SIMULADA = 1
set_property PACKAGE_PIN A16 [get_ports UART_RX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RX]


###############################################################################
# LEDs DE ESTADO
###############################################################################

# LD0 - Topo activo
set_property PACKAGE_PIN U16 [get_ports LED_Activo]
set_property IOSTANDARD LVCMOS33 [get_ports LED_Activo]

# LD1 - Game Over
set_property PACKAGE_PIN E19 [get_ports LED_GameOver]
set_property IOSTANDARD LVCMOS33 [get_ports LED_GameOver]


###############################################################################
# LEDs DE LOS TOPOS - LD8 A LD15
#
# LED_Topo[0] -> LD8
# LED_Topo[1] -> LD9
# LED_Topo[2] -> LD10
# LED_Topo[3] -> LD11
# LED_Topo[4] -> LD12
# LED_Topo[5] -> LD13
# LED_Topo[6] -> LD14
# LED_Topo[7] -> LD15
###############################################################################

# LD8
set_property PACKAGE_PIN V13 [get_ports {LED_Topo[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[0]}]

# LD9
set_property PACKAGE_PIN V3 [get_ports {LED_Topo[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[1]}]

# LD10
set_property PACKAGE_PIN W3 [get_ports {LED_Topo[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[2]}]

# LD11
set_property PACKAGE_PIN U3 [get_ports {LED_Topo[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[3]}]

# LD12
set_property PACKAGE_PIN P3 [get_ports {LED_Topo[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[4]}]

# LD13
set_property PACKAGE_PIN N3 [get_ports {LED_Topo[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[5]}]

# LD14
set_property PACKAGE_PIN P1 [get_ports {LED_Topo[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[6]}]

# LD15
set_property PACKAGE_PIN L1 [get_ports {LED_Topo[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_Topo[7]}]


###############################################################################
# DISPLAY DE 7 SEGMENTOS
#
# El módulo Display7Seg utiliza:
#
# seg = {a,b,c,d,e,f,g}
#
# seg[6] = A
# seg[5] = B
# seg[4] = C
# seg[3] = D
# seg[2] = E
# seg[1] = F
# seg[0] = G
###############################################################################

# Segmento A
set_property PACKAGE_PIN W7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

# Segmento B
set_property PACKAGE_PIN W6 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

# Segmento C
set_property PACKAGE_PIN U8 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

# Segmento D
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

# Segmento E
set_property PACKAGE_PIN U5 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

# Segmento F
set_property PACKAGE_PIN V5 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

# Segmento G
set_property PACKAGE_PIN U7 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]


###############################################################################
# PUNTO DECIMAL
###############################################################################

set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]


###############################################################################
# ÁNODOS DEL DISPLAY
###############################################################################

set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


###############################################################################
# CONFIGURACIÓN FPGA
###############################################################################

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]