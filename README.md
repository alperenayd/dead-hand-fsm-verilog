# Dead Hand Protocol Simulation (Verilog)

This project implements a multi-level Finite State Machine (FSM) system in Verilog to simulate an automated strategic response system.

##  Overview

The system models a control mechanism that transitions between different operational states based on external conditions such as threat levels, communication loss, and system status.

It consists of:

* A **main FSM** representing global system states
* A **sub-FSM** handling engagement procedures

##  Main FSM States

* PEACE
* ALERT
* MOBILIZATION
* ENGAGEMENT

##  Sub-FSM (Engagement Phases)

* ARM
* TRACK
* AUTHORIZE
* ABORT

##  Features

* Multi-level FSM design (hierarchical state machines)
* State transitions based on multiple input conditions
* Integrated timing mechanism for state control
* Realistic system behavior simulation

##  Technologies

* Verilog HDL
* Digital Design Concepts
* FSM (Finite State Machines)

##  Simulation

The system can be tested using simulation tools (e.g., ModelSim, Vivado).
Test scenarios include:

* Threat detection
* Communication loss
* System fault conditions

##  Project Structure

```text
dead_hand.v
```

##  Future Improvements

* Add detailed testbench for automated testing
* Visualize waveforms for state transitions
* Extend FSM with additional safety conditions

##  Author

Alperen Aydın
