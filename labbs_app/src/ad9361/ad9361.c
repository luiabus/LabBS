#include "ad9361.h"
#include "xparameters.h" /* EDK generated parameters */
#include "xspips.h"		 /* SPI device driver */
#include "xscugic.h"	 /* Interrupt controller device driver */
#include "xil_exception.h"
#include "xil_printf.h"
#include "unistd.h"
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "xgpiops.h"
#include "Regfig.h"

/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define SPI_DEVICE_ID XPAR_XSPIPS_0_DEVICE_ID
#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID
#define SPI_INTR_ID XPAR_XSPIPS_0_INTR
/*
 * The following constants define the offsets within a Ad9361Buffer data
 * type for each kind of data.  Note that the read data offset is not the
 * same as the write data because the SPI driver is designed to allow full
 * duplex transfers such that the number of bytes received is the number
 * sent and received.
 */
#define COMMAND_MSB_OFFSET 0
#define COMMAND_LSB_OFFSET 1
#define DATA_OFFSET 2
#define WRITE_DATA_OFFSET 2
#define READ_DATA_OFFSET 4
#define OVERHEAD_SIZE 2

#define ad0_SPI_SELECT 0x00
#define ad1_SPI_SELECT 0x01

/**************************** Type Definitions *******************************/

/*
 * The following data type is used to send and receive data to the serial
 * ad9361 device connected to the SPI interface.  It is an array of bytes
 * rather than a structure for portability avoiding packing issues.  The
 * application must setup the data to be written in this buffer and retrieve
 * the data read from it.
 */
typedef u8 EepromBuffer[100];

/***************** Macros (Inline Functions) Definitions *********************/
/*********************9361澶嶄綅淇″彿****************************/
static void ad9361_rest();
static void FMC_rest(int AD);

static void ad9361_sync();
/************************/
/************************** Function Prototypes ******************************/
static int SpiSetupIntrSystem(XScuGic *IntcInstancePtr,
							  XSpiPs *SpiInstancePtr, u16 SpiIntrId);

static void SpiDisableIntrSystem(XScuGic *IntcInstancePtr, u16 SpiIntrId);

void SpiHandler(void *CallBackRef, u32 StatusEvent, unsigned int ByteCount);

void Ad9361Read(XSpiPs *SpiPtr, u16 Address, int ByteCount,
				EepromBuffer Buffer);

void Ad9361Write(XSpiPs *SpiPtr, u16 Address, u8 ByteCount,
				 EepromBuffer Buffer);

int SpiPsAd9361Initialize(XScuGic *IntcInstancePtr, XSpiPs *SpiInstancePtr,
						  u16 SpiDeviceId, u16 SpiIntrId);
int Ad9361RegConfig(XSpiPs *SpiInstancePtr, RegConfig *RegPtr, u16 RegNum, int FMC);

/*
 * The instances to support the device drivers are global such that the
 * are initialized to zero each time the program runs.  They could be local
 * but should at least be static so they are zeroed.
 */
static XScuGic IntcInstance;
static XSpiPs SpiInstance;
/*
 * The following variables are shared between non-interrupt processing and
 * interrupt processing such that they must be global.
 */
volatile int TransferInProgress;

int Error;

/*
 * The following variables are used to read and write to the eeprom and they
 * are global to avoid having large buffers on the stack
 */
EepromBuffer ReadBuffer;
EepromBuffer WriteBuffer;

/*****************************************************************************/
/**
 *
 * Main function to call the Spi Ad9361 example.
 *
 * @param	None
 *
 * @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
 *
 * @note		None
 *
 ******************************************************************************/
// XGpio ad;
int ad9361_init(void)
{
	int Status; // 妫�娴嬪悇鍑芥暟鐨勮皟鐢ㄧ粨鏋�

	/*==========================閰嶇疆AD9361=================================*/
	xil_printf("SPI AD9361 Interrupt Configuration Start\r\n");

	/*
	 * Run the Spi Interrupt example.
	 */
	Status = SpiPsAd9361Initialize(&IntcInstance, &SpiInstance,
								   SPI_DEVICE_ID, SPI_INTR_ID);

	if (Status != XST_SUCCESS)
	{
		xil_printf("SPI AD9361 Interrupt Configuration Failed\r\n");
		return XST_FAILURE;
	}

	/*=========================杈撳嚭AD9361閰嶇疆瀹屾垚淇″彿=============================*/
	xil_printf("Successfully AD9361  Configuration\r\n");
	return XST_SUCCESS;
}

static RegConfig ad9361_ensm_enable[1] = {
	{1, 0x014, 0x23},
};

/*************************Ad9361 Register Initialize*********************************/
int SpiPsAd9361Initialize(XScuGic *IntcInstancePtr, XSpiPs *SpiInstancePtr,
						  u16 SpiDeviceId, u16 SpiIntrId)
{
	static XGpioPs psGpioInstancePtr; // 杩欐槸涓�涓寚閽堝疄渚嬶紝鎸囧悜娣诲姞鐨� GPIO 绔彛
	XGpioPs_Config *GpioConfigPtr;	  // 姝ょ粨鏋勪綋瀛樻斁鐨勬槸 GPIO 鐨勮澶囧湴鍧�鍜屽熀鍦板潃
	int sync = 56;
	int ad0 = 57;		   // EMIO鐨勭3浣�
	int ad1 = 58;		   // EMIO鐨勭4浣�
	int ad_finish = 59;	   // EMIO鐨勭5浣�
	int io_rst = 60;	   // EMIO鐨勭6浣�
	int tx_ready = 61;	   // EMIO鐨勭7浣�
	int tx_finish = 62;	   // EMIO鐨勭8浣�
	u32 uPinDirection = 1; // 1琛ㄧず杈撳嚭
	int xStatus;
	GpioConfigPtr = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	if (GpioConfigPtr == NULL)
		return;
	xStatus = XGpioPs_CfgInitialize(&psGpioInstancePtr, GpioConfigPtr, GpioConfigPtr->BaseAddr);
	if (XST_SUCCESS != xStatus)
		print(" PS GPIO INIT FAILED \n\r");

	XGpioPs_SetDirectionPin(&psGpioInstancePtr, ad0, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, sync, 1);
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, ad0, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, ad0, 1);
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, ad1, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, ad1, 1);
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, ad_finish, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, ad_finish, 1);
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, io_rst, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, io_rst, 1);
	XGpioPs_WritePin(&psGpioInstancePtr, sync, 0);
	XGpioPs_WritePin(&psGpioInstancePtr, ad0, 1);
	XGpioPs_WritePin(&psGpioInstancePtr, ad1, 1);
	XGpioPs_WritePin(&psGpioInstancePtr, ad_finish, 0);
	XGpioPs_WritePin(&psGpioInstancePtr, io_rst, 0);
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, tx_ready, 0);			   // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, tx_finish, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, tx_finish, 1);
	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 1);

	ad9361_sync();
	ad9361_rest(); // 澶嶄綅9361鑺墖

	///////////////////

	int Status;

	XSpiPs_Config *SpiConfig;

	/*
	 * Initialize the SPI driver so that it's ready to use
	 */
	SpiConfig = XSpiPs_LookupConfig(SpiDeviceId);
	if (NULL == SpiConfig)
	{
		return XST_FAILURE;
	}

	Status = XSpiPs_CfgInitialize(SpiInstancePtr, SpiConfig,
								  SpiConfig->BaseAddress);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to check hardware build
	 */
	Status = XSpiPs_SelfTest(SpiInstancePtr);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	/*
	 * Connect the Spi device to the interrupt subsystem such that
	 * interrupts can occur. This function is application specific
	 */
	Status = SpiSetupIntrSystem(IntcInstancePtr, SpiInstancePtr, SpiIntrId);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	/*
	 * Setup the handler for the SPI that will be called from the
	 * interrupt context when an SPI Status occurs, specify a pointer to
	 * the SPI driver instance as the callback reference so the handler is
	 * able to access the instance data
	 */
	XSpiPs_SetStatusHandler(SpiInstancePtr, SpiInstancePtr,
							(XSpiPs_StatusHandler)SpiHandler);

	/*
	 * Set the Spi device as a master. External loopback is required.
	 */
	XSpiPs_SetOptions(SpiInstancePtr, XSPIPS_MASTER_OPTION | XSPIPS_FORCE_SSELECT_OPTION | XSPIPS_CLK_PHASE_1_OPTION);

	XSpiPs_SetClkPrescaler(SpiInstancePtr, XSPIPS_CLK_PRESCALE_128);

	Status = XSpiPs_SetSlaveSelect(SpiInstancePtr, 0);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	// FMC1
	printf("AD9361_0 \r\n");
	XGpioPs_WritePin(&psGpioInstancePtr, ad0, 0);
	do
	{
		Status = Ad9361RegConfig(SpiInstancePtr, SetRef0, REG_AMOUNT, 0);
	} while (Status != XST_SUCCESS);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}
	Ad9361RegConfig(SpiInstancePtr, ad9361_ensm_enable, 1, 0);
	XGpioPs_WritePin(&psGpioInstancePtr, ad0, 1);

	if (AD1enable)
	{
		// FMC2
		XGpioPs_WritePin(&psGpioInstancePtr, ad1, 0);
		printf("AD9361_1 \r\n");
		do
		{
			Status = Ad9361RegConfig(SpiInstancePtr, SetRef1, REG_AMOUNT, 1);
		} while (Status != XST_SUCCESS);
		if (Status != XST_SUCCESS)
		{
			return XST_FAILURE;
		}
		Ad9361RegConfig(SpiInstancePtr, ad9361_ensm_enable, 1, 1);
		XGpioPs_WritePin(&psGpioInstancePtr, ad1, 1);
	}

	XGpioPs_WritePin(&psGpioInstancePtr, ad0, 0);
	XGpioPs_WritePin(&psGpioInstancePtr, ad1, 0);

	//	int fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 1)
	//	{
	//		printf("waiting 0 %d\r\n",fff); //tx ready
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	while(fff == 0)
	//	{
	//		printf("waiting 1 %d\r\n",fff); //tx ready
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	while(fff == 1)//$1
	//	{
	//		printf("waiting 1 %d\r\n",fff); //tx ready
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	usleep(1000);
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 0);//#1
	//	fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 0)//$2
	//	{
	//		printf("waiting 1 %d\r\n",fff); //tx ready
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 1);//#2

	WriteBuffer[WRITE_DATA_OFFSET] = 0x05;
	Ad9361Write(SpiInstancePtr, 0x001, 1, WriteBuffer);
	WriteBuffer[WRITE_DATA_OFFSET] = 0x80;
	Ad9361Write(SpiInstancePtr, 0x047, 1, WriteBuffer);

	//	fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 1)//$3
	//	{
	//		printf("waiting 2 %d\r\n",fff); //tx sync spi finish
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 0);//#3
	//	fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 0)//$4
	//	{
	//		printf("waiting 2 %d\r\n",fff); //tx sync spi finish
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 1);

	ad9361_sync();

	//	fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 1)//$5
	//	{
	//		printf("waiting 3\r\n");
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 0);
	//	while(fff == 0)//6
	//	{
	//		printf("waiting 3 %d\r\n",fff); //tx sync spi finish
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 1);

	WriteBuffer[WRITE_DATA_OFFSET] = 0x03;
	Ad9361Write(SpiInstancePtr, 0x001, 1, WriteBuffer);

	//	fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 1)//7
	//	{
	//		printf("waiting 4 %d\r\n",fff);
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 0);
	//
	//	usleep(1000);
	//	fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 0)//8
	//	{
	//		printf("waiting 4 %d\r\n",fff); //tx sync spi finish
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 1);

	ad9361_sync();

	//	fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	while(fff == 1)//9
	//	{
	//		printf("waiting 5 %d\r\n",fff);
	//		fff = XGpioPs_ReadPin(&psGpioInstancePtr, tx_ready);
	//	}
	//	XGpioPs_WritePin(&psGpioInstancePtr, tx_finish, 0);

	WriteBuffer[WRITE_DATA_OFFSET] = 0x00;
	Ad9361Write(SpiInstancePtr, 0x001, 1, WriteBuffer);

	//	WriteBuffer[WRITE_DATA_OFFSET] = 0x23;
	//	Ad9361Write(SpiInstancePtr, 0x014, 1, WriteBuffer);

	XGpioPs_WritePin(&psGpioInstancePtr, ad0, 1);
	XGpioPs_WritePin(&psGpioInstancePtr, ad1, 1);

	XGpioPs_WritePin(&psGpioInstancePtr, io_rst, 1);
	sleep(0.001);
	XGpioPs_WritePin(&psGpioInstancePtr, io_rst, 0);

	SpiDisableIntrSystem(IntcInstancePtr, SpiIntrId);
	XGpioPs_WritePin(&psGpioInstancePtr, ad_finish, 1);

	return XST_SUCCESS;
}

/******************************************************************************
 *
 * This function is the handler which performs processing for the SPI driver.
 * It is called from an interrupt context such that the amount of processing
 * performed should be minimized.  It is called when a transfer of SPI data
 * completes or an error occurs.
 *
 * This handler provides an example of how to handle SPI interrupts
 * but is application specific.
 *
 *
 * @param	CallBackRef is a reference passed to the handler.
 * @param	StatusEvent is the Status of the SPI .
 * @param	ByteCount is the number of bytes transferred.
 *
 * @return	None
 *
 * @note		None.
 *
 ******************************************************************************/
void SpiHandler(void *CallBackRef, u32 StatusEvent, unsigned int ByteCount)
{
	/*
	 * Indicate the transfer on the SPI bus is no longer in progress
	 * regardless of the Status event
	 */
	TransferInProgress = FALSE;

	/*
	 * If the event was not transfer done, then track it as an error
	 */
	if (StatusEvent != XST_SPI_TRANSFER_DONE)
	{
		Error++;
	}
}

/******************************************************************************
 *
 * This function reads from the serial ad9361 connected to the SPI interface.
 *
 * @param	SpiPtr is a pointer to the SPI driver instance to use.
 * @param	Address contains the address to read data from in the EEPROM.
 * @param	ByteCount contains the number of bytes to read.
 * @param	Buffer is a buffer to read the data into.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
void Ad9361Read(XSpiPs *SpiPtr, u16 Address, int ByteCount,
				EepromBuffer Buffer)
{
	/*
	 * Setup the write command with the specified address and data for the
	 * ad9361
	 */
	u16 CommandByte = 0x0000;
	CommandByte = (u16)(CommandByte | ((ByteCount - 1) << 12));
	CommandByte = (u16)(CommandByte | Address);

	Buffer[COMMAND_MSB_OFFSET] = (u8)((CommandByte & 0xFF00) >> 8);
	Buffer[COMMAND_LSB_OFFSET] = (u8)(CommandByte & 0x00FF);

	/*
	 * Send the read command to the EEPROM to read the specified number
	 * of bytes from the EEPROM, send the read command and address and
	 * receive the specified number of bytes of data in the data buffer
	 */
	TransferInProgress = TRUE;

	XSpiPs_Transfer(SpiPtr, Buffer, &Buffer[DATA_OFFSET],
					ByteCount + OVERHEAD_SIZE);

	/*
	 * Wait for the transfer on the SPI bus to be complete before proceeding
	 */
	while (TransferInProgress)
		;
}

/******************************************************************************
 *
 *
 * This function writes to the serial Ad9361 connected to the SPI interface.
 *
 * @param	SpiPtr is a pointer to the SPI driver instance to use.
 * @param	Address contains the address to write data to in the Ad9361.
 * @param	ByteCount contains the number of bytes to write.
 * @param	Buffer is a buffer of data to write from.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
void Ad9361Write(XSpiPs *SpiPtr, u16 Address, u8 ByteCount,
				 EepromBuffer Buffer)
{
	int DelayCount = 0;
	/*
	 * Setup the write command with the specified address and data for the
	 * Ad9361
	 */
	u16 CommandByte = 0x8000;
	CommandByte = (u16)(CommandByte | ((ByteCount - 1) << 12));
	CommandByte = (u16)(CommandByte | Address);

	Buffer[COMMAND_MSB_OFFSET] = (u8)((CommandByte & 0xFF00) >> 8);
	Buffer[COMMAND_LSB_OFFSET] = (u8)(CommandByte & 0x00FF);
	/*
	 * Send the write command, address, and data to the Ad9361 to be
	 * written, no receive buffer is specified since there is nothing to
	 * receive
	 */
	TransferInProgress = TRUE;
	XSpiPs_Transfer(SpiPtr, Buffer, NULL, ByteCount + OVERHEAD_SIZE);

	while (TransferInProgress)
		;

	/*
	 * Wait for a bit of time to allow the programming to occur as reading
	 * the Status while programming causes it to fail because of noisy power
	 * on the board containing the Ad9361, this loop does not need to be
	 * very long but is longer to hopefully work for a faster processor
	 */
	while (DelayCount++ < 30000)
	{
	}
}

static int SpiSetupIntrSystem(XScuGic *IntcInstancePtr,
							  XSpiPs *SpiInstancePtr, u16 SpiIntrId)
{
	int Status;

#ifndef TESTAPP_GEN
	XScuGic_Config *IntcConfig; /* Instance of the interrupt controller */

	Xil_ExceptionInit();

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig)
	{
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
								   IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
								 (Xil_ExceptionHandler)XScuGic_InterruptHandler,
								 IntcInstancePtr);
#endif

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(IntcInstancePtr, SpiIntrId,
							 (Xil_ExceptionHandler)XSpiPs_InterruptHandler,
							 (void *)SpiInstancePtr);
	if (Status != XST_SUCCESS)
	{
		return Status;
	}

	/*
	 * Enable the interrupt for the Spi device.
	 */
	XScuGic_Enable(IntcInstancePtr, SpiIntrId);

#ifndef TESTAPP_GEN
	/*
	 * Enable interrupts in the Processor.
	 */
	Xil_ExceptionEnable();
#endif

	return XST_SUCCESS;
}

static void SpiDisableIntrSystem(XScuGic *IntcInstancePtr, u16 SpiIntrId)
{
	/*
	 * Disable the interrupt for the SPI device.
	 */
	XScuGic_Disable(IntcInstancePtr, SpiIntrId);

	/*
	 * Disconnect and disable the interrupt for the Spi device.
	 */
	XScuGic_Disconnect(IntcInstancePtr, SpiIntrId);
}

int Ad9361RegConfig(XSpiPs *SpiInstancePtr, RegConfig *RegPtr, u16 RegNum, int FMC)
{
	int i;
	u8 *BufferPtr;
	int BitOffset;
	int ReadFlag;
	int DemandFlag;
	int read_cnt = 0;
	for (i = 0; i < RegNum; i++)
	{
		//		xil_printf("%d %d Address = 0x%x, value = 0x%x \r\n",i,(RegPtr + i)->WRStatus, (RegPtr + i) -> Address, (RegPtr + i)->Vlaue);
		if ((RegPtr + i)->WRStatus == 0)
		{
			Ad9361Read(SpiInstancePtr, (RegPtr + i)->Address, 1, ReadBuffer);
			BufferPtr = &ReadBuffer[READ_DATA_OFFSET];
			//			xil_printf("Address = 0x%x, value = 0x%x \r\n", (RegPtr + i) -> Address, *BufferPtr);
		}
		else if ((RegPtr + i)->WRStatus == 1)
		{
			WriteBuffer[WRITE_DATA_OFFSET] = (RegPtr + i)->Vlaue;
			Ad9361Write(SpiInstancePtr, (RegPtr + i)->Address, 1, WriteBuffer);
			Ad9361Read(SpiInstancePtr, (RegPtr + i)->Address, 1, ReadBuffer);
			BufferPtr = &ReadBuffer[READ_DATA_OFFSET];
			//			xil_printf("WRStatus3 Address = 0x%x, value = 0x%x \r\n", (RegPtr + i) -> Address, *BufferPtr);
		}
		else if ((RegPtr + i)->WRStatus == 2)
		{
			usleep(((RegPtr + i)->Vlaue) * 1000);
		}
		else if ((RegPtr + i)->WRStatus == 3)
		{
			BitOffset = ((RegPtr + i)->Vlaue) >> 4;
			DemandFlag = ((RegPtr + i)->Vlaue) & 0x01;
			do
			{
				Ad9361Read(SpiInstancePtr, (RegPtr + i)->Address, 1, ReadBuffer);
				BufferPtr = &ReadBuffer[READ_DATA_OFFSET];
				ReadFlag = ((*BufferPtr) >> BitOffset) & 0x01;
				//				xil_printf("WRStatus3 Address = 0x%x, value = 0x%x expect = 0x%x %d \r\n", (RegPtr + i) -> Address, ReadFlag, DemandFlag, read_cnt);
				//				read_cnt++;
				//				if(read_cnt >= 100000)
				//				{
				//					return XST_FAILURE;
				//				}
			} while (ReadFlag != DemandFlag);
			//			read_cnt = 0;
			//			FMC_rest(FMC);
		}
	}
	for (i = 0; i < RegNum; i++)
	{
		if ((RegPtr + i)->WRStatus == 1)
		{
			Ad9361Read(SpiInstancePtr, (RegPtr + i)->Address, 1, ReadBuffer);
			BufferPtr = &ReadBuffer[READ_DATA_OFFSET];
			//			xil_printf("Address = 0x%x, value = 0x%x \r\n", (RegPtr + i) -> Address, *BufferPtr);
		}
	}
	return XST_SUCCESS;
}

static void ad9361_rest()
{
	static XGpioPs psGpioInstancePtr; // 杩欐槸涓�涓寚閽堝疄渚嬶紝鎸囧悜娣诲姞鐨� GPIO 绔彛
	XGpioPs_Config *GpioConfigPtr;	  // 姝ょ粨鏋勪綋瀛樻斁鐨勬槸 GPIO 鐨勮澶囧湴鍧�鍜屽熀鍦板潃
	int iPinNumber0 = 54;			  // EMIO鐨勭0浣�
	int iPinNumber1 = 55;
	int iPinNumber2 = 60;
	u32 uPinDirection = 1; // 1琛ㄧず杈撳嚭
	int xStatus;
	GpioConfigPtr = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	if (GpioConfigPtr == NULL)
		return;
	xStatus = XGpioPs_CfgInitialize(&psGpioInstancePtr, GpioConfigPtr, GpioConfigPtr->BaseAddr);
	if (XST_SUCCESS != xStatus)
		print(" PS GPIO INIT FAILED \n\r");

	XGpioPs_SetDirectionPin(&psGpioInstancePtr, iPinNumber0, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, iPinNumber0, 1);			 // 浣胯兘EMIO杈撳嚭
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, iPinNumber1, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, iPinNumber1, 1);			 // 浣胯兘EMIO杈撳嚭
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, iPinNumber2, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, iPinNumber2, 1);			 // 浣胯兘EMIO杈撳嚭
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber0, 1);					 // EMIO鐨勭0浣嶈緭鍑�1
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber1, 1);					 // EMIO鐨勭1浣嶈緭鍑�1
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber2, 0);					 // EMIO鐨勭1浣嶈緭鍑�0

	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber0, 0); // EMIO鐨勭0浣嶈緭鍑�0
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber1, 0); // EMIO鐨勭1浣嶈緭鍑�0
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber2, 1); // EMIO鐨勭1浣嶈緭鍑�1
	sleep(0.001);										  // 寤舵椂
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber0, 1); // EMIO鐨勭0浣嶈緭鍑�1
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber1, 1); // EMIO鐨勭1浣嶈緭鍑�1
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber2, 0); // EMIO鐨勭1浣嶈緭鍑�0

	xil_printf("AD9361 reset finish!\r\n");
	return;
}

static void FMC_rest(int FMC)
{
	static XGpioPs psGpioInstancePtr; // 杩欐槸涓�涓寚閽堝疄渚嬶紝鎸囧悜娣诲姞鐨� GPIO 绔彛
	XGpioPs_Config *GpioConfigPtr;	  // 姝ょ粨鏋勪綋瀛樻斁鐨勬槸 GPIO 鐨勮澶囧湴鍧�鍜屽熀鍦板潃
	int iPinNumber0 = 54;			  // EMIO鐨勭0浣�
	int iPinNumber1 = 55;
	u32 uPinDirection = 1; // 1琛ㄧず杈撳嚭
	int xStatus;
	GpioConfigPtr = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	if (GpioConfigPtr == NULL)
		return;
	xStatus = XGpioPs_CfgInitialize(&psGpioInstancePtr, GpioConfigPtr, GpioConfigPtr->BaseAddr);
	if (XST_SUCCESS != xStatus)
		print(" PS GPIO INIT FAILED \n\r");

	XGpioPs_SetDirectionPin(&psGpioInstancePtr, iPinNumber0, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, iPinNumber0, 1);			 // 浣胯兘EMIO杈撳嚭
	XGpioPs_SetDirectionPin(&psGpioInstancePtr, iPinNumber1, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, iPinNumber1, 1);			 // 浣胯兘EMIO杈撳嚭

	switch (FMC)
	{
	case 0:
	{
		XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber0, 1); // EMIO鐨勭0浣嶈緭鍑�1
		XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber0, 0); // EMIO鐨勭0浣嶈緭鍑�0
		sleep(0.001);										  // 寤舵椂
		XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber0, 1); // EMIO鐨勭0浣嶈緭鍑�1
		//			xil_printf("FMC0 reset finish!\r\n");
		break;
	}
	case 1:
	{
		XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber1, 1); // EMIO鐨勭0浣嶈緭鍑�1
		XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber1, 0); // EMIO鐨勭0浣嶈緭鍑�0
		sleep(0.001);										  // 寤舵椂
		XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber1, 1); // EMIO鐨勭0浣嶈緭鍑�1
		//			xil_printf("FMC1 reset finish!\r\n");
		break;
	}
	}
	return;
}

static void ad9361_sync()
{
	static XGpioPs psGpioInstancePtr; // 杩欐槸涓�涓寚閽堝疄渚嬶紝鎸囧悜娣诲姞鐨� GPIO 绔彛
	XGpioPs_Config *GpioConfigPtr;	  // 姝ょ粨鏋勪綋瀛樻斁鐨勬槸 GPIO 鐨勮澶囧湴鍧�鍜屽熀鍦板潃
	int iPinNumber = 56;			  // EMIO鐨勭0浣�
	u32 uPinDirection = 1;			  // 1琛ㄧず杈撳嚭
	int xStatus;
	GpioConfigPtr = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	if (GpioConfigPtr == NULL)
		return;
	xStatus = XGpioPs_CfgInitialize(&psGpioInstancePtr, GpioConfigPtr, GpioConfigPtr->BaseAddr);
	if (XST_SUCCESS != xStatus)
		print(" PS GPIO INIT FAILED \n\r");

	XGpioPs_SetDirectionPin(&psGpioInstancePtr, iPinNumber, uPinDirection); // 璁剧疆EMIO涓鸿緭鍑�
	XGpioPs_SetOutputEnablePin(&psGpioInstancePtr, iPinNumber, 1);			// 浣胯兘EMIO杈撳嚭

	usleep(1000);
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber, 1); // EMIO鐨勭3浣嶈緭鍑�1
	usleep(1000);
	XGpioPs_WritePin(&psGpioInstancePtr, iPinNumber, 0); // EMIO鐨勭3浣嶈緭鍑�0
	usleep(1000);
	return;
}
