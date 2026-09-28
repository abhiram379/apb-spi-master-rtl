# APB-Based SPI Master RTL Design

## Overview

This project implements an APB-based SPI Master using Verilog HDL.

The design combines an APB slave interface with SPI control and data-transfer logic. APB transactions are used to configure and control the SPI Master, while the SPI interface handles serial data communication.

## Design Features

* APB slave interface
* SPI Master functionality
* Programmable baud-rate generation
* SPI slave-select control
* SPI shift-register based data transfer
* APB-controlled SPI operation
* Modular RTL architecture

## RTL Modules

| Module                   | Description                                                          |
| ------------------------ | -------------------------------------------------------------------- |
| `apbslaveproject.v`      | Implements the APB slave-side interface and APB transaction handling |
| `baudgeneratorproject.v` | Generates the SPI clock/baud timing                                  |
| `shiftregisterproject.v` | Handles serial-to-parallel and parallel-to-serial data shifting      |
| `slaveselectproject.v`   | Generates/controls the SPI slave-select signal                       |
| `topmoduleproject.v`     | Top-level module integrating the APB and SPI-related blocks          |

## Architecture

The design is organized into multiple RTL blocks:

```text
                    APB Interface
                         |
                         v
                 +---------------+
                 | APB Slave     |
                 | Interface     |
                 +-------+-------+
                         |
                         v
                +------------------+
                | Control / Data   |
                | Registers        |
                +--------+---------+
                         |
             +-----------+-----------+
             |                       |
             v                       v
      Baud Generator          Shift Register
             |                       |
             v                       v
           SCLK                  MOSI / MISO
                                     |
                                     v
                               Slave Select
```

## RTL Design

The design is divided into separate modules for easier development and verification.

### APB Slave

The APB slave block handles APB transactions and provides the interface between the APB bus and the SPI functionality.

### Baud Generator

The baud generator produces the timing required for SPI communication.

### Shift Register

The shift register performs the serial data transfer between the SPI Master and SPI slave.

### Slave Select

The slave-select block controls the SPI slave selection during communication.

### Top-Level Module

The top-level module integrates the individual RTL blocks into the complete APB-based SPI Master.

## Verification

The design was simulated and verified using a Verilog/SystemVerilog testbench.

Verification focuses on:

* APB transactions
* Register access
* SPI data transfer
* SPI clock generation
* Slave-select operation
* Shift-register operation
* Integration of the individual RTL blocks

## Simulation Tool

* QuestaSim / ModelSim

## HDL

* Verilog HDL
* SystemVerilog for verification

## Repository Structure

```text
apb-spi-master-rtl/
│
├── rtl/
│   ├── apbslaveproject.v
│   ├── baudgeneratorproject.v
│   ├── shiftregisterproject.v
│   ├── slaveselectproject.v
│   └── topmoduleproject.v
│
├── tb/
│   └── Testbench files
│
├── docs/
│   ├── architecture.png
│   └── waveform.png
│
├── .gitignore
└── README.md
```

## Tools Used

* Verilog HDL
* SystemVerilog
* QuestaSim / ModelSim
* Visual Studio Code
* Git
* GitHub

## Author

Abhiram V
