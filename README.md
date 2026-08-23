# AMBA AHB-Lite Single Master/Slave Implementation

This repository contains the complete implementation and verification of an AHB-Lite Master/Slave protocol, including hardware schematics in Logisim and RTL design in SystemVerilog.

## Directory Structure
- `src/`: Contains the SystemVerilog RTL files (`ahb_slave.sv`, `ahb_tb.sv`).
- `logisim/`: Contains the Logisim circuit file implementing AHB pipelining.
- `sim/`: Contains simulation logs and GTKWave `.vcd` waveform files.
- `docs/`: Contains screenshots of the block diagrams and waveforms.

---

## Task 1: Logisim AHB-Lite Design
Designed a simplified AHB-Lite bus interface in Logisim. The design accurately implements pipelining where the Address Phase (HADDR, HWRITE) is delayed by one clock cycle using D-Flip Flops before reaching the Data Phase. Wait states are successfully controlled via the HREADY signal linked to the register enable pins.

---

## Task 2: SystemVerilog Implementation & Bug Fixes
Simulated an AHB-Lite protocol covering 5 comprehensive test cases. 

**Debugging Analysis:**
The main issue with basic buggy AHB codes is that the address phase and data phase are not pipelined properly. The master needs to send the data exactly one cycle after sending the address. If the slave asserts a wait state (HREADY = 0), the master must hold the data and address. To fix this, I added an internal register in the slave to store the address (addr_reg). I also added a check for the HTRANS signal so the slave only accepts a new address when HTRANS is NONSEQ or SEQ.

---

## Task 3: AHB System Architecture (4 Slaves)
An AHB system with 4 slaves basically consists of a Master, a Decoder, a Multiplexer, and the Slaves. The Master initiates the transfer by sending out the address (HADDR) and control signals (HWRITE, HTRANS). The Decoder reads the address and generates a select signal (HSEL) for one of the 4 slaves based on the memory map. Once a slave is selected, it takes the address and data. Because multiple slaves are connected to the bus, a Multiplexer is used to route the read data (HRDATA) and response signals (HREADY, HRESP) from the active slave back to the Master. The mux uses the delayed HSEL signal from the decoder to choose the correct slave's output.

---

## Task 4: Peripherals in SoC Designs

### High-Speed Peripherals (Usually on AHB/AXI)
1. **DDR Memory Controller:** Used to interface with the main system RAM. It needs very high bandwidth (multiple GB/s) and uses burst transfers.
2. **Gigabit Ethernet MAC:** Used for high-speed networking and internet connection. It usually operates at 1 Gbps to 10 Gbps and uses a DMA to move data.
3. **PCIe Controller:** Connects external high-speed devices like graphics cards or NVMe SSDs. It transfers data at very high gigabit speeds.
4. **Display Controller (LCD/HDMI):** Sends video data to screens. It requires continuous, uninterrupted data flow (AXI-Stream) for high resolutions like 4K.
5. **USB 3.0 Controller:** Used to connect external drives and devices. It operates at 5 Gbps and needs high-speed access to memory.

### Low-Speed Peripherals (Usually on APB)
1. **UART:** Used for serial communication like a debug terminal. It runs at low speeds (like 115200 bps) and doesn't need pipelining.
2. **I2C:** A two-wire interface used to connect slow sensors, temperature monitors, or EEPROM memory. Speeds are usually around 100 kbps to 400 kbps.
3. **SPI:** A serial interface for SD cards or small flash memories. It is faster than I2C but still considered low speed compared to DDR.
4. **GPIO (General Purpose I/O):** Used to control simple things like turning on LEDs or reading push buttons. It has no fixed data rate.
5. **Watchdog Timer:** A simple timer that resets the system if the software crashes. It only has a few control registers and requires very little bus bandwidth.
