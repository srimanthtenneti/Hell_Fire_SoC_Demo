
# Hell Fire SoC Documentation

Version: 1.0 
Issues: 
1. Array IP HRESP Width Mismatch - Severity - Minor - Level - IP
2. Array IP Reset Remap - Severity - Minor - Level - SoC Top
   
Implementation Status :
1. FPGA - Done
2. ASIC - Done

Note 
1. This implementation requires the ARM Cortex M0 Design Start IP which can be downloaded from the following link https://www.arm.com/resources/designstart.
2. This implementation would need the Cortex M0 integration and logic files.
   

# **Introduction**

This documentation provides an in-depth overview of a custom System-on-Chip (SoC) design centered around the ARM Cortex-M0 processor architecture. This SoC is engineered to deliver efficient processing for embedded systems and microcontroller applications while incorporating a range of components and features designed to optimize performance. In this document, we will explore the key components, peripherals, and protocols employed in this SoC design.

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2Ff2dac598-582d-4583-94a2-16fc05f327d3.png?alt=media&token=f3a24127-b6d3-481f-a898-f028bb1335b6" style="width:'100%'"/></div>

<br/>

## **ARM Cortex-M0 Processor**

### **Overview**

The heart of this SoC is the ARM Cortex-M0 processor. This 32-bit processor core is renowned for its low power consumption and is specifically tailored for embedded systems and microcontroller applications where energy efficiency is paramount. The Cortex-M0 processor offers a balance between processing power and power efficiency, making it a suitable choice for a wide range of applications.

### **Key Features**

*   **32-Bit Architecture**: The Cortex-M0 processor employs a 32-bit architecture, which enables it to process data and instructions in 32-bit chunks, facilitating efficient data handling.

*   **Energy Efficiency**: Designed with power efficiency in mind, the Cortex-M0 consumes minimal power, making it ideal for battery-powered and energy-sensitive applications.

*   **Instruction Set**: It utilizes the ARMv6-M instruction set architecture, which includes a comprehensive set of instructions for various operations, ensuring efficient execution of tasks.

## **Memory Interface**

### **Byte-Addressable Nature**

The memory interface in this SoC is byte-addressable, offering granular access to data stored in memory. Byte-addressability means that individual bytes within the memory can be read from or written directly, providing flexibility and precision in data manipulation.

### **Decoding and Data Transfer**

The memory interface utilizes the HSIZE and HADDR\[1:0\] signals to decode and transfer data effectively. These signals play crucial roles in managing data requests and addressing them within the memory subsystem.

*   **HSIZE (Size of Data Transfer)**: The HSIZE signal specifies the size of the data transfer. It determines whether the data transfer is in bytes, half-words (16 bits), or words (32 bits). This flexibility allows the processor to select the appropriate data size for the task at hand, optimizing memory usage and performance.

*   **HADDR\[1:0\] (Address Offset)**: The HADDR\[1:0\] signals provide an address offset within the selected data size. They help the processor pinpoint the exact location of the data within the memory. By using these signals, the processor can access specific bytes, half-words, or words within memory, ensuring precise data manipulation.

    <br/>

## **IO Interface**

### **Overview**

To facilitate interactions with the external world, the SoC integrates an IO (Input/Output) interface. The IO pins can be used to drive data to the external world and the state of these pins can be monitored by the processor.

### **Key Features**

*   **Peripheral Interfacing**: It enables the SoC to connect with a wide range of external devices, including sensors, displays, and actuators, making it suitable for diverse applications.

## **Systolic Array for Matrix Multiplication**

### **Overview**

One of the standout features of this SoC is the inclusion of a 4x4 Systolic Array, designed to accelerate matrix multiplications. This hardware accelerator enhances the SoC's computational capabilities, particularly in applications that involve intensive matrix operations.

This IP uses INT8 quantized data for maximizing throughput and efficiency.

### **Key Features**

*   **Matrix Acceleration**: The Systolic Array is optimized for matrix multiplication, offering a significant performance boost for tasks like signal processing, machine learning, and image processing.

*   **Parallel Processing**: It leverages parallel processing to simultaneously perform multiple matrix multiplications, reducing processing time and energy consumption.

    <br/>

## **AMBA AHB-Lite Protocol**

### **Overview**

The peripherals within the SoC are interconnected using the AMBA AHB-Lite protocol. This protocol ensures efficient and standardized communication between different components, enhancing system reliability and performance.

### **Key Features**

*   **Standardization**: The AMBA AHB-Lite protocol adheres to industry standards, promoting compatibility and ease of integration with various components.

*   **Efficiency**: It optimizes data transfer and communication between peripherals and the processor, reducing latency and enhancing overall system efficiency.

## **AHB Decoder and Multiplexer**

### **Overview**

To seamlessly integrate peripherals with the Cortex-M0 processor, this SoC employs an AHB Decoder and Multiplexer. These components play a pivotal role in routing and managing data and control signals between the processor and peripherals.

### **Key Features**

*   **Peripheral Integration**: The AHB Decoder and Multiplexer provide a single master design, enabling the Cortex-M0 processor to efficiently access and control connected peripherals.

*   **Control Logic**: They handle address decoding and data multiplexing, ensuring that data flows smoothly between the processor and peripherals without conflicts.

# SoC Architecture

<br/>

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2Fd80ef378-a60f-484c-9563-6bdc29e5eb06.png?alt=media&token=f82fd3db-93f0-4ade-a4f1-6d194177285d" style="width:'100%'"/></div>

<br/>

The diagram above depicts the peripheral integration strategy used for this SoC. This strategy plays a crucial role in facilitating efficient communication between the processor and peripherals.

<br/>

## Memory Map

The table below depicts the memory map used for the SoC.

<br/>

|Peripheral    |Address   |
|--------------|----------|
|Memory        |0x50000000|
|IO            |0x51000000|
|Systolic Array|0x52000000|

<br/>

<br/>

## **Command Execution**

*   The processor executes commands from the .hex program file, initiating transactions with various peripherals within the SoC.

## **Decoder and Response Selection**

*   The decoder, a critical component in the integration strategy, selects the appropriate peripheral required by the transaction. It interprets the command from the processor and routes it to the relevant peripheral.

*   Simultaneously, the decoder generates a response select signal, which is transmitted to the multiplexer (mux). This signal serves as a directive for the multiplexer, indicating which peripheral's response should be sent back to the master, which is the Cortex-M0 processor.

*   This response select signal ensures that the processor receives responses from the specific peripheral involved in the transaction, streamlining the communication process and reducing latency.

## Memory Interface

The memory interface implemented in this SoC supports non-Seq transfers and cannot facilitate burst transactions. The interface handles a memory space of 16KB.

When the HREADY signal is asserted the control signals are loaded into the registers. Then the transaction validity is checked as follows :

> tx\_transaction = `HSELq && HWRITEq && HTRANSq[1]`

Once this is done we now decode the size of the transfer. This interface is byte addressable which means byte, half-word, and word are the supported sizes.

<br/>

|Transfer Size                    |HSIZE\[1\]         |HSIZE\[0\]         |
|---------------------------------|-------------------|-------------------|
|Byte<br><br>Half Word<br><br>Word|0<br><br>0<br><br>1|0<br><br>1<br><br>0|

<br/>

Now to decode the byte lane we use the HADDR signal. As we have 4 lanes we use the first two bits.

<br/>

|Byte Lane                                   |HADDR\[1\]                  |HADDR\[0\]                  |
|--------------------------------------------|----------------------------|----------------------------|
|Lane0<br><br>Lane1<br><br>Lane2<br><br>Lane3|0<br><br>0<br><br>1<br><br>1|0<br><br>1<br><br>0<br><br>1|

<br/>

Now if the size is a half-word we use HADDR\[1\] to decode the lane, this is done as follows :

<br/>

|Half Word Lane    |HADDR\[1\]|
|------------------|----------|
|Lane0<br><br>Lane1|0<br><br>1|

<br/>

As the maximum width supported is a word the decoding is quite simple as we just check transaction validity and size being a word.

Now using the above data we generate the Byte Lane enable signals for the supported sizes. This is done by checking if any transaction accesses the said lane.

For example, if we were to design the lane0 enable signal we could do it as follows :

<br/>

> `byte = ~HSIZEq[1] && ~HSIZEq[0]`
> 
> `half_word = ~HSIZEq[1] && HSIZEq[0]`
> 
> `word = HSIZEq[1] && ~HSIZEq[0]`

> `byte0 = tx_transaction && byte && ~HADDR[1] && ~HADDR[0]`
> 
> `halfw0 = tx_transaction && half_word && ~HADDR[1]`
> 
> `word0 = tx_transaction && word`
> 
> `lane0_enable = byte0 | halfw0 | word0`

<br/>

We implement the remaining lane controls using a similar approach as described above.

When we write data to the peripheral we should not use the HADDR\[1\] and HADDR\[0\] bits for the address. The remaining bits are to be used. This peripheral is always ready and has no error state.

<br/>

## IO Interface

When the peripheral is selected the address and control signals are loaded into the interface. Then the transaction validity and type are checked using the HTRANSq, HSELq, & HWRITEq.

The current implementation only has 4 bits for the IO. Hence only the lower 4 bits transfer the data to the IO. The data can be read via a simple read transaction.

This peripheral too is always ready and has no error state.

<br/>

## Array IP Interface

This interface links the Array IP Core and the AHB Lite bus.

<br/>

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2Ffa0f34aa-9c59-4b84-9b58-26d617fb3933.png?alt=media&token=0ff5efa1-8f2b-49d1-882b-ccd649c43cfb" style="width:'100%'"/></div>

<br/>

<br/>

The above diagram represents the Hell Fire Array IP which is responsible for accelerating matrix multiplications. The key components of this IP are :

*   AHB Interface

*   Channel Buffer

*   Master Interface FIFO (MIF)

*   Data Delivery Subsystem (Data Switch + Sequencers + Alignment FIFOs)

*   Systolic Array (SA - 4x4)

*   Data serializer

*   Output Streaming FIFO (OSF)

*   MISC Controller Logic

The interface supports only non-seq transfers and a valid read transfer is only possible once 8x non-seq transfers are delivered to the IP. The timing diagram below depicts a series of write transfers to the interface.

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F25bed62c-e000-4cf8-ba74-1f3ad3aa72fa.png?alt=media&token=03e91933-286c-4ff4-a3b5-a27ca091d523" style="width:'100%'"/></div>

<br/>

The channel buffer in the design acts as a skid buffer and ensures proper data transfer between the AHB Interface and the MIF. If the MIF is unable to accept data the skid buffer holds the data and disables the AHB Interface which reduces the risk of data loss.

The Master Interface FIFO or MIF stores the data packets required for the SA's operation. The MIF has a capacity of 256 bits (32x8) and can support only a Flush read i.e. once the MIF is full the AHB interface is disabled by the channel buffer and the read transaction starts.

Based on the MIF read pointer the Data Switch delivers the payload to the appropriate Sequencer Unit (SU). The SU sequences the data and delivers it to an Alignment FIFO. The operation of the Data Switch can be understood from the timing diagram below.

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2Fa876b1ab-f5f5-4734-922c-ac1d9edceb06.png?alt=media&token=c9ae51b9-5cdb-4d87-847c-0b7b9d256f6e" style="width:'100%'"/></div>

<br/>

Here the FIFO statuses of the alignment FIFOs are used to write and read data from the FIFOs. The write region would be from FIFO Empty to FIFO Full and the read would be vice versa. Once the alignment FIFO is full a pointer update signal is released which updates the MIF read pointer delivering the next payload.

To further understand the data alignment requirement we would have to take a closer look at the operation of a 4x4 array.

<br/>

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F2d1376c2-9e30-447f-a37a-13ec6169f853.png?alt=media&token=30354eff-4077-4ffd-91a1-f0cf157dbde7" style="width:'100%'"/></div>

<br/>

The diagram above depicts the data alignment required for the proper functioning of the SA. To achieve this we divide the sequence into 4 base classes. The West0 & North0, West1 & North1, West2 & North2 and the West3 & North3. As these lanes have a common alignment pattern use end up using the same sequencers for the above-mentioned pairs.

A sequencer would take in data and generate the pattern needed for said lane. To understand the workings of the SU we consider the West0 & North0 sequencer. The timing diagram below depicts it's working.

<br/>

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F41473846-8dfc-420e-84d4-9dace8027319.png?alt=media&token=d7d466af-902c-4c7b-9cf9-6479e9dd8e99" style="width:'100%'"/></div>

<br/>

When the SU is selected by the Data Switch a 32-bit payload is delivered to the unit. This data is then split into 4 bytes which are padded with the required data and are sent out to the alignment FIFO along with the control signals.

Once all the alignment FIFOs are populated the global read enable (GRE) signal starts the SA's operation.

The Data Serializer monitors the GRE signal and collects the SA response only after stable data is available. As the SA's outputs are 16-bit wide two outputs are combined into a single packet generating 8 packets in total.

These packets along are streamed out of the data serializer into the OSF along with a signal to indicate data validity. The timing diagram below depicts the working of the data serializer.

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F7e071b69-b93a-4f1c-adaf-6568b34a4ce2.png?alt=media&token=10771db6-2f15-4c95-924a-c27e24a38fce" style="width:'100%'"/></div>

<br/>

Once the operation is complete and the data is ready the HREADYOUT signal is asserted by the peripheral. Now the master performs a sequence of read transfers to collect the result from the peripheral.

<br/>

# SoC Implementation & Validation

To validate this SoC we first use the Keil u Vision 5 IDE to generate a .hex file to load into the memory. This hex file along with the RTL is input to the Vivado 2022.2 tool and the design is implemented for the Zybo Z7010 development board.

To test the array operation we use a test plan named unity which involves multiplying to matrices with all the elements as 1. The resultant matrix should have all the elements as the order of the input matrices which in our case is 4.

As we package two outputs into a single packet we should see the result of the read transfer as 00040004 for the unity test. This is validated by the simulation below.

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F075a62a9-4e4c-404a-91fe-36ed1ae95d62.png?alt=media&token=30ea0753-c4fa-47ab-8577-de815440ebe1" style="width:'100%'"/></div>

<br/>

To test simultaneously validates our Memory and Array peripherals. Now to validate the IO peripheral we write 0x6 to the unit. The IO unit's output being 4 bits wide should generate 0110 at its output. The diagram below validates this write transfer.

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F318e3d5c-bf23-42c7-bdc6-daa591493ea9.jpeg?alt=media&token=aaab7522-b0fe-40be-90e0-5481d83a3e13" style="width:'100%'"/></div>

<br/>

# Team

## Srimanth Tenneti

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F3375961f-3679-48b5-9eb6-dec4fcadf8e4.jpg?alt=media&token=1552695e-dea2-43af-9de2-46ccc13d53e8" style="width:'100%'"/></div>

<br/>

> **Role: Chief Architect, RTL Design &, Physical Implementation**
> 
> **LinkedIn:** [https://www.linkedin.com/in/srimanth-tenneti-662b7117b/](https://www.linkedin.com/in/srimanth-tenneti-662b7117b/)
> 
> **Github:** [https://github.com/srimanthtenneti](https://github.com/srimanthtenneti)
> 
> **Email ID**: [tennetshmail.uc.edu](https://tennetsh@mail.uc.edu)
> 
> **Department: ECE - University of Cincinnati**

<br/>

## Sindhura Maddineni

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F8dbf7c25-d0ac-49f5-8e72-94f5130d8040.jpeg?alt=media&token=392cc996-ebf9-440f-a864-3eb9df7cc29c" style="width:'100%'"/></div>

<br/>

> **Role: RTL Design**
> 
> **LinkedIn:** [https://www.linkedin.com/in/sindhura-m/](https://www.linkedin.com/in/sindhura-m/)
> 
> **Email ID**: [maddinsrmail.uc.edu](mailto:maddinsr@mail.uc.edu)
> 
> **Department: ECE - University of Cincinnati**

<br/>

## Sai Sumanth Reddy Chinnasani

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F5e9c32c2-f2d4-4b77-9669-79e33890a496.jpeg?alt=media&token=f72f6de7-bc66-45a8-94e4-c6c72dac21bb" style="width:'100%'"/></div>

<br/>

> **Role: RTL Design**
> 
> **LinkedIn:** [https://www.linkedin.com/in/sai-sumanth-reddy-chinnasani/](https://www.linkedin.com/in/sai-sumanth-reddy-chinnasani/)
> 
> **Email ID**: [chinnasymail.uc.edu](mailto:chinnasy@mail.uc.edu)
> 
> **Department: ECE - University of Cincinnati**

<br/>

## Sindhuja Gangapuram

<br/>

<div align="center"><img src="https://firebasestorage.googleapis.com/v0/b/swimmio-content/o/repositories%2Fdummy-repo%2F928cb87f-029f-4873-b394-bd22f98c4b72.jpeg?alt=media&token=4ffa77a8-6859-4cfd-bec2-d10edb2ce596" style="width:'100%'"/></div>

<br/>

> **Role: FPGA Implementation**
> 
> **LinkedIn:** [https://www.linkedin.com/in/sindhujareddy0428/](https://www.linkedin.com/in/sindhujareddy0428/)
> 
> **Email ID**: [gangapsamail.uc.edu](mailto:gangapsa@mail.uc.edu)
> 
> **Department: ECE - University of Cincinnati**

<br/>
