/*******************************************************************************
  SERCOM Universal Synchronous/Asynchrnous Receiver/Transmitter PLIB

  Company
    Microchip Technology Inc.

  File Name
    plib_${SERCOM_INSTANCE_NAME?lower_case}_usart.c

  Summary
    USART peripheral library interface.

  Description
    This file defines the interface to the USART peripheral library. This
    library provides access to and control of the associated peripheral
    instance.

  Remarks:
    None.
*******************************************************************************/

/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "plib_${SERCOM_INSTANCE_NAME?lower_case}_usart.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

<#assign USART_PLIB = "SERCOM_INSTANCE_NAME">
<#assign USART_PLIB_CLOCK_FREQUENCY = "core." + USART_PLIB?eval + "_CORE_CLOCK_FREQUENCY">

/* ${SERCOM_INSTANCE_NAME} USART baud value for ${USART_BAUD_RATE} Hz baud rate */
#define ${SERCOM_INSTANCE_NAME}_USART_INT_BAUD_VALUE            (${USART_BAUD_VALUE}U)

<#if USART_INTERRUPT_MODE = true>
SERCOM_USART_RING_BUFFER_OBJECT ${SERCOM_INSTANCE_NAME?lower_case}USARTObj;
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: ${SERCOM_INSTANCE_NAME} USART Interface Routines
// *****************************************************************************
// *****************************************************************************

<#if USART_RX_ENABLE = true>
#define ${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE      ${USART_RX_RING_BUFFER_SIZE}
#define ${SERCOM_INSTANCE_NAME}_USART_RX_INT_DISABLE()      ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENCLR = SERCOM_USART_INT_INTENCLR_RXC_Msk
#define ${SERCOM_INSTANCE_NAME}_USART_RX_INT_ENABLE()       ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET = SERCOM_USART_INT_INTENSET_RXC_Msk

static uint8_t ${SERCOM_INSTANCE_NAME}_USART_ReadBuffer[${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE];
</#if>

<#if USART_TX_ENABLE = true>
#define ${SERCOM_INSTANCE_NAME}_USART_WRITE_BUFFER_SIZE     ${USART_TX_RING_BUFFER_SIZE}
#define ${SERCOM_INSTANCE_NAME}_USART_TX_INT_DISABLE()      ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENCLR = SERCOM_USART_INT_INTENCLR_DRE_Msk
#define ${SERCOM_INSTANCE_NAME}_USART_TX_INT_ENABLE()       ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET = SERCOM_USART_INT_INTENSET_DRE_Msk

static uint8_t ${SERCOM_INSTANCE_NAME}_USART_WriteBuffer[${SERCOM_INSTANCE_NAME}_USART_WRITE_BUFFER_SIZE];
</#if>

void ${SERCOM_INSTANCE_NAME}_USART_Initialize( void )
{
    /*
     * Configures USART Clock Mode
     * Configures TXPO and RXPO
     * Configures Data Order
     * Configures Standby Mode
     * Configures Sampling rate
     * Configures IBON
     */
    <@compress single_line=true>${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLA = SERCOM_USART_INT_CTRLA_MODE_USART_INT_CLK |
                                                                                       SERCOM_USART_INT_CTRLA_RXPO(${USART_RXPO}) |
                                                                                       SERCOM_USART_INT_CTRLA_TXPO(${USART_TXPO}) |
                                                                                       SERCOM_USART_INT_CTRLA_DORD_Msk |
                                                                                       SERCOM_USART_INT_CTRLA_IBON_Msk |
                                                                                       SERCOM_USART_INT_CTRLA_FORM(${(USART_PARITY_MODE == "NONE")?then('0x0', '0x1')})
                                                                                       <#if USART_SAMPLE_RATE??>| SERCOM_USART_INT_CTRLA_SAMPR(${USART_SAMPLE_RATE})</#if>
                                                                                       ${USART_RUNSTDBY?then('| SERCOM_USART_INT_CTRLA_RUNSTDBY_Msk', '')};</@compress>

    /* Configure Baud Rate */
    ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_BAUD = SERCOM_USART_INT_BAUD_BAUD(${SERCOM_INSTANCE_NAME}_USART_INT_BAUD_VALUE);

    /*
     * Configures RXEN
     * Configures TXEN
     * Configures CHSIZE
     * Configures Parity
     * Configures Stop bits
     */
    <@compress single_line=true>${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLB = SERCOM_USART_INT_CTRLB_CHSIZE_${USART_CHARSIZE_BITS} |
                                                                                       SERCOM_USART_INT_CTRLB_SBMODE_${USART_STOP_BIT}
                                                                                       ${(USART_PARITY_MODE == "ODD")?then('| SERCOM_USART_INT_CTRLB_PMODE_Msk', '')}
                                                                                       ${USART_RX_ENABLE?then('| SERCOM_USART_INT_CTRLB_RXEN_Msk', '')}
                                                                                       ${USART_TX_ENABLE?then('| SERCOM_USART_INT_CTRLB_TXEN_Msk', '')};</@compress>

    /* Wait for sync */
<#if SERCOM_SYNCBUSY = false>
    while((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk) & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk);
<#else>
    while(${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_SYNCBUSY);
</#if>

    /* Enable the UART after the configurations */
    ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLA |= SERCOM_USART_INT_CTRLA_ENABLE_Msk;

    /* Wait for sync */
<#if SERCOM_SYNCBUSY = false>
    while((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk) & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk);
<#else>
    while(${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_SYNCBUSY);
</#if>

<#if USART_INTERRUPT_MODE = true>
<#if USART_RX_ENABLE = true>
    /* Initialize instance object */
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback = NULL;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdInIndex = 0;
	${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex = 0;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isRdNotificationEnabled = false;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isRdNotifyPersistently = false;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdThreshold = 0;
</#if>
<#if USART_TX_ENABLE = true>
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrCallback = NULL;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrInIndex = 0;
	${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrOutIndex = 0;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isWrNotificationEnabled = false;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isWrNotifyPersistently = false;
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrThreshold = 0;
</#if>
<#if USART_RX_ENABLE = true>
<#if USART_INTENSET_ERROR = true>
	/* Enable error interrupt */
	${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET = SERCOM_USART_INT_INTENSET_ERROR_Msk;

</#if>

    /* Enable Receive Complete interrupt */
    ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET = SERCOM_USART_INT_INTENSET_RXC_Msk;
</#if>
</#if>
}

uint32_t ${SERCOM_INSTANCE_NAME}_USART_FrequencyGet( void )
{
<#if USART_PLIB_CLOCK_FREQUENCY?eval??>
    return (uint32_t) (${USART_PLIB_CLOCK_FREQUENCY?eval}UL);
<#else>
    return 0;
</#if>
}

bool ${SERCOM_INSTANCE_NAME}_USART_SerialSetup( USART_SERIAL_SETUP * serialSetup, uint32_t clkFrequency )
{
    bool setupStatus       = false;
    uint32_t baudValue     = 0;
<#if USART_SAMPLE_RATE??>
    uint32_t sampleRate    = 0;
</#if>

    if((serialSetup != NULL) & (serialSetup->baudRate != 0))
    {
        if(clkFrequency == 0)
        {
            clkFrequency = ${SERCOM_INSTANCE_NAME}_USART_FrequencyGet();
        }

        <#if USART_SAMPLE_RATE??>
        if(clkFrequency >= (16 * serialSetup->baudRate))
        {
            baudValue = 65536 - ((uint64_t)65536 * 16 * serialSetup->baudRate) / clkFrequency;
            sampleRate = 0;
        }
        else if(clkFrequency >= (8 * serialSetup->baudRate))
        {
            baudValue = 65536 - ((uint64_t)65536 * 8 * serialSetup->baudRate) / clkFrequency;
            sampleRate = 2;
        }
        else if(clkFrequency >= (3 * serialSetup->baudRate))
        {
            baudValue = 65536 - ((uint64_t)65536 * 3 * serialSetup->baudRate) / clkFrequency;
            sampleRate = 4;
        }
        <#else>
        if(clkFrequency >= (16 * serialSetup->baudRate))
        {
            baudValue = 65536 - ((uint64_t)65536 * 16 * serialSetup->baudRate) / clkFrequency;
        }
        </#if>

        if(baudValue != 0)
        {
            /* Disable the USART before configurations */
            ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLA &= ~SERCOM_USART_INT_CTRLA_ENABLE_Msk;

            /* Wait for sync */
            <#if SERCOM_SYNCBUSY = false>
            while((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk) & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk);
            <#else>
            while(${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_SYNCBUSY);
            </#if>

            /* Configure Baud Rate */
            ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_BAUD = SERCOM_USART_INT_BAUD_BAUD(baudValue);

            /* Configure Parity Options */
            if(serialSetup->parity == USART_PARITY_NONE)
            {
                ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLA |= SERCOM_USART_INT_CTRLA_FORM(0x0) <#if USART_SAMPLE_RATE??>| SERCOM_USART_INT_CTRLA_SAMPR(sampleRate)</#if>;

                ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLB |= serialSetup->dataWidth | serialSetup->stopBits;
            }
            else
            {
                ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLA |= SERCOM_USART_INT_CTRLA_FORM(0x1) <#if USART_SAMPLE_RATE??>| SERCOM_USART_INT_CTRLA_SAMPR(sampleRate)</#if>;

                ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLB |= serialSetup->dataWidth | serialSetup->parity | serialSetup->stopBits;
            }

            /* Wait for sync */
            <#if SERCOM_SYNCBUSY = false>
            while((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk) & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk);
            <#else>
            while(${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_SYNCBUSY);
            </#if>

            /* Enable the USART after the configurations */
            ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_CTRLA |= SERCOM_USART_INT_CTRLA_ENABLE_Msk;

            /* Wait for sync */
            <#if SERCOM_SYNCBUSY = false>
            while((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk) & SERCOM_USART_INT_STATUS_SYNCBUSY_Msk);
            <#else>
            while(${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_SYNCBUSY);
            </#if>

            setupStatus = true;
        }
    }

    return setupStatus;
}

void static ${SERCOM_INSTANCE_NAME}_USART_ErrorClear( void )
{
    uint8_t  u8dummyData = 0;

<#if USART_INTENSET_ERROR = true>
    /* Clear error flag */
    ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTFLAG = SERCOM_USART_INT_INTFLAG_ERROR_Msk;

</#if>
    /* Clear all errors */
    ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS = SERCOM_USART_INT_STATUS_PERR_Msk | SERCOM_USART_INT_STATUS_FERR_Msk | SERCOM_USART_INT_STATUS_BUFOVF_Msk;

    /* Flush existing error bytes from the RX FIFO */
    while((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTFLAG & SERCOM_USART_INT_INTFLAG_RXC_Msk) == SERCOM_USART_INT_INTFLAG_RXC_Msk)
    {
        u8dummyData = ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_DATA;
    }

    /* Ignore the warning */
    (void)u8dummyData;
}

USART_ERROR ${SERCOM_INSTANCE_NAME}_USART_ErrorGet( void )
{
    USART_ERROR errorStatus = USART_ERROR_NONE;

    errorStatus = ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS & (SERCOM_USART_INT_STATUS_PERR_Msk | SERCOM_USART_INT_STATUS_FERR_Msk | SERCOM_USART_INT_STATUS_BUFOVF_Msk);

    if(errorStatus != USART_ERROR_NONE)
    {
        ${SERCOM_INSTANCE_NAME}_USART_ErrorClear();
    }

    return errorStatus;
}

<#if USART_RX_ENABLE = true>

/* This routine is only called from ISR. Hence do not disable/enable USART interrupts. */
static inline bool ${SERCOM_INSTANCE_NAME}_USART_RxPushByte(uint8_t rdByte)
{
    uint32_t tempInIndex;
    bool isSuccess = false;

    tempInIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdInIndex + 1;

    if (tempInIndex >= ${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE)
    {
        tempInIndex = 0;
    }

    if (tempInIndex == ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex)
    {
        /* Queue is full - Report it to the application. Application gets a chance to free up space by reading data out from the RX ring buffer */
        if(${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback != NULL)
        {
            ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback(SERCOM_USART_EVENT_READ_BUFFER_FULL, ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdContext);

            /* Read the indices again in case application has freed up space in RX ring buffer */
            tempInIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdInIndex + 1;

            if (tempInIndex >= ${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE)
            {
                tempInIndex = 0;
            }
        }
    }

    /* Attempt to push the data into the ring buffer */
    if (tempInIndex != ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex)
    {
        ${SERCOM_INSTANCE_NAME}_USART_ReadBuffer[${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdInIndex] = rdByte;
        ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdInIndex = tempInIndex;
        isSuccess = true;
    }
    else
    {
        /* Queue is full. Data will be lost. */
    }

    return isSuccess;
}

/* This routine is only called from ISR. Hence do not disable/enable USART interrupts. */
static void ${SERCOM_INSTANCE_NAME}_USART_ReadNotificationSend(void)
{
    uint32_t nUnreadBytesAvailable;

    if (${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isRdNotificationEnabled == true)
    {
        nUnreadBytesAvailable = ${SERCOM_INSTANCE_NAME}_USART_ReadCountGet();

        if(${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback != NULL)
        {
            if (${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isRdNotifyPersistently == true)
            {
                if (nUnreadBytesAvailable >= ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdThreshold)
                {
                    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback(SERCOM_USART_EVENT_READ_THRESHOLD_REACHED, ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdContext);
                }
            }
            else
            {
                if (nUnreadBytesAvailable == ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdThreshold)
                {
                    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback(SERCOM_USART_EVENT_READ_THRESHOLD_REACHED, ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdContext);
                }
            }
        }
    }
}

size_t ${SERCOM_INSTANCE_NAME}_USART_Read(uint8_t* pRdBuffer, const size_t size)
{
    size_t nBytesRead = 0;
	uint32_t rdOutIndex;
	uint32_t rdInIndex;

    while (nBytesRead < size)
    {
        ${SERCOM_INSTANCE_NAME}_USART_RX_INT_DISABLE();
		
		rdOutIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex;
		rdInIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdInIndex;

        if (rdOutIndex != rdInIndex)
        {
            pRdBuffer[nBytesRead++] = ${SERCOM_INSTANCE_NAME}_USART_ReadBuffer[${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex++];

            if (${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex >= ${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE)
            {
                ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex = 0;
            }
            ${SERCOM_INSTANCE_NAME}_USART_RX_INT_ENABLE();
        }
        else
        {
            ${SERCOM_INSTANCE_NAME}_USART_RX_INT_ENABLE();
            break;
        }
    }

    return nBytesRead;
}

size_t ${SERCOM_INSTANCE_NAME}_USART_ReadCountGet(void)
{
    size_t nUnreadBytesAvailable;
	uint32_t rdOutIndex;
	uint32_t rdInIndex;
	
	/* Take a snapshot of indices to avoid creation of critical section */
	rdOutIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdOutIndex;
	rdInIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdInIndex;

    if ( rdInIndex >=  rdOutIndex)
    {
        nUnreadBytesAvailable =  rdInIndex - rdOutIndex;
    }
    else
    {
        nUnreadBytesAvailable =  (${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE -  rdOutIndex) + rdInIndex;
    }

    return nUnreadBytesAvailable;
}

size_t ${SERCOM_INSTANCE_NAME}_USART_ReadFreeBufferCountGet(void)
{
    return (${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE - 1) - ${SERCOM_INSTANCE_NAME}_USART_ReadCountGet();
}

size_t ${SERCOM_INSTANCE_NAME}_USART_ReadBufferSizeGet(void)
{
    return (${SERCOM_INSTANCE_NAME}_USART_READ_BUFFER_SIZE - 1);
}

bool ${SERCOM_INSTANCE_NAME}_USART_ReadNotificationEnable(bool isEnabled, bool isPersistent)
{
    bool previousStatus = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isRdNotificationEnabled;

    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isRdNotificationEnabled = isEnabled;

    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isRdNotifyPersistently = isPersistent;

    return previousStatus;
}

void ${SERCOM_INSTANCE_NAME}_USART_ReadThresholdSet(uint32_t nBytesThreshold)
{
    if (nBytesThreshold > 0)
    {
        ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdThreshold = nBytesThreshold;
    }
}

void ${SERCOM_INSTANCE_NAME}_USART_ReadCallbackRegister( SERCOM_USART_RING_BUFFER_CALLBACK callback, uintptr_t context)
{
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback = callback;

    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdContext = context;
}
</#if>

<#if USART_TX_ENABLE = true>

/* This routine is only called from ISR. Hence do not disable/enable USART interrupts. */
static bool ${SERCOM_INSTANCE_NAME}_USART_TxPullByte(uint8_t* pWrByte)
{
    bool isSuccess = false;
	uint32_t wrInIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrInIndex;
	uint32_t wrOutIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrOutIndex;

    if (wrOutIndex != wrInIndex)
    {
        *pWrByte = ${SERCOM_INSTANCE_NAME}_USART_WriteBuffer[${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrOutIndex++];

        if (${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrOutIndex >= ${SERCOM_INSTANCE_NAME}_USART_WRITE_BUFFER_SIZE)
        {
            ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrOutIndex = 0;
        }
        isSuccess = true;
    }

    return isSuccess;
}

static inline bool ${SERCOM_INSTANCE_NAME}_USART_TxPushByte(uint8_t wrByte)
{
    uint32_t tempInIndex;
    bool isSuccess = false;

    tempInIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrInIndex + 1;

    if (tempInIndex >= ${SERCOM_INSTANCE_NAME}_USART_WRITE_BUFFER_SIZE)
    {
        tempInIndex = 0;
    }
    if (tempInIndex != ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrOutIndex)
    {
        ${SERCOM_INSTANCE_NAME}_USART_WriteBuffer[${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrInIndex] = wrByte;
        ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrInIndex = tempInIndex;
        isSuccess = true;
    }
    else
    {
        /* Queue is full. Report Error. */
    }

    return isSuccess;
}

/* This routine is only called from ISR. Hence do not disable/enable USART interrupts. */
static void ${SERCOM_INSTANCE_NAME}_USART_WriteNotificationSend(void)
{
    uint32_t nFreeWrBufferCount;

    if (${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isWrNotificationEnabled == true)
    {
        nFreeWrBufferCount = ${SERCOM_INSTANCE_NAME}_USART_WriteFreeBufferCountGet();

        if(${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrCallback != NULL)
        {
            if (${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isWrNotifyPersistently == true)
            {
                if (nFreeWrBufferCount >= ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrThreshold)
                {
                    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrCallback(SERCOM_USART_EVENT_WRITE_THRESHOLD_REACHED, ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrContext);
                }
            }
            else
            {
                if (nFreeWrBufferCount == ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrThreshold)
                {
                    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrCallback(SERCOM_USART_EVENT_WRITE_THRESHOLD_REACHED, ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrContext);
                }
            }
        }
    }
}

static size_t ${SERCOM_INSTANCE_NAME}_USART_WritePendingBytesGet(void)
{
    size_t nPendingTxBytes;
	
	/* Take a snapshot of indices to avoid creation of critical section */
	uint32_t wrInIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrInIndex;
	uint32_t wrOutIndex = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrOutIndex;

    if ( wrInIndex >= wrOutIndex)
    {
        nPendingTxBytes =  wrInIndex - wrOutIndex;
    }
    else
    {
        nPendingTxBytes =  (${SERCOM_INSTANCE_NAME}_USART_WRITE_BUFFER_SIZE -  wrOutIndex) + wrInIndex;
    }

    return nPendingTxBytes;
}

size_t ${SERCOM_INSTANCE_NAME}_USART_WriteCountGet(void)
{
    size_t nPendingTxBytes;

    nPendingTxBytes = ${SERCOM_INSTANCE_NAME}_USART_WritePendingBytesGet();
    
    return nPendingTxBytes;
}

size_t ${SERCOM_INSTANCE_NAME}_USART_Write(uint8_t* pWrBuffer, const size_t size )
{
    size_t nBytesWritten  = 0;

    ${SERCOM_INSTANCE_NAME}_USART_TX_INT_DISABLE();

    while (nBytesWritten < size)
    {
        if (${SERCOM_INSTANCE_NAME}_USART_TxPushByte(pWrBuffer[nBytesWritten]) == true)
        {
            nBytesWritten++;
        }
        else
        {
            /* Queue is full, exit the loop */
            break;
        }
    }

    /* Check if any data is pending for transmission */
    if (${SERCOM_INSTANCE_NAME}_USART_WritePendingBytesGet() > 0)
    {
        /* Enable TX interrupt as data is pending for transmission */
        ${SERCOM_INSTANCE_NAME}_USART_TX_INT_ENABLE();
    }

    return nBytesWritten;
}

size_t ${SERCOM_INSTANCE_NAME}_USART_WriteFreeBufferCountGet(void)
{
    return (${SERCOM_INSTANCE_NAME}_USART_WRITE_BUFFER_SIZE - 1) - ${SERCOM_INSTANCE_NAME}_USART_WriteCountGet();
}

size_t ${SERCOM_INSTANCE_NAME}_USART_WriteBufferSizeGet(void)
{
    return (${SERCOM_INSTANCE_NAME}_USART_WRITE_BUFFER_SIZE - 1);
}

bool ${SERCOM_INSTANCE_NAME}_USART_WriteNotificationEnable(bool isEnabled, bool isPersistent)
{
    bool previousStatus = ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isWrNotificationEnabled;

    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isWrNotificationEnabled = isEnabled;

    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.isWrNotifyPersistently = isPersistent;

    return previousStatus;
}

void ${SERCOM_INSTANCE_NAME}_USART_WriteThresholdSet(uint32_t nBytesThreshold)
{
    if (nBytesThreshold > 0)
    {
        ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrThreshold = nBytesThreshold;
    }
}

void ${SERCOM_INSTANCE_NAME}_USART_WriteCallbackRegister( SERCOM_USART_RING_BUFFER_CALLBACK callback, uintptr_t context)
{
    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrCallback = callback;

    ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.wrContext = context;
}

</#if>

<#if USART_INTENSET_ERROR = true>
void static ${SERCOM_INSTANCE_NAME}_USART_ISR_ERR_Handler( void )
{
    USART_ERROR errorStatus = USART_ERROR_NONE;

    errorStatus = (${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_STATUS &
                  (SERCOM_USART_INT_STATUS_PERR_Msk |
                  SERCOM_USART_INT_STATUS_FERR_Msk |
                  SERCOM_USART_INT_STATUS_BUFOVF_Msk));

    if(errorStatus != USART_ERROR_NONE)
    {
        ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENCLR = SERCOM_USART_INT_INTENCLR_ERROR_Msk;

        if(${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback != NULL)
        {
            ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdCallback(SERCOM_USART_EVENT_READ_ERROR, ${SERCOM_INSTANCE_NAME?lower_case}USARTObj.rdContext);
        }

        /* In case of errors are not cleared by client using ErrorGet API */
        ${SERCOM_INSTANCE_NAME}_USART_ErrorClear();
    }
}
</#if>

<#if USART_RX_ENABLE = true>
void static ${SERCOM_INSTANCE_NAME}_USART_ISR_RX_Handler( void )
{
    if (${SERCOM_INSTANCE_NAME}_USART_RxPushByte( ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_DATA) == true)
    {
        ${SERCOM_INSTANCE_NAME}_USART_ReadNotificationSend();
    }
    else
    {
        /* UART RX buffer is full */
    }
}
</#if>

<#if USART_TX_ENABLE = true>
void static ${SERCOM_INSTANCE_NAME}_USART_ISR_TX_Handler( void )
{
    uint8_t wrByte;

    if (${SERCOM_INSTANCE_NAME}_USART_TxPullByte(&wrByte) == true)
    {
        ${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_DATA = wrByte;
    }
    else
    {
        /* Nothing to transmit. Disable the data register empty interrupt. */
        ${SERCOM_INSTANCE_NAME}_USART_TX_INT_DISABLE();
    }

    ${SERCOM_INSTANCE_NAME}_USART_WriteNotificationSend();
}
</#if>

void ${SERCOM_INSTANCE_NAME}_USART_InterruptHandler( void )
{
    if(${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET != 0)
    {
        <#if USART_TX_ENABLE = true>
        /* Checks for data register empty flag */
        if((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET & SERCOM_USART_INT_INTENSET_DRE_Msk) && (${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTFLAG & SERCOM_USART_INT_INTFLAG_DRE_Msk))
        {
            ${SERCOM_INSTANCE_NAME}_USART_ISR_TX_Handler();
        }

        </#if>
        <#if USART_RX_ENABLE = true>
        /* Checks for receive complete empty flag */
        if((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET & SERCOM_USART_INT_INTENSET_RXC_Msk) && (${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTFLAG & SERCOM_USART_INT_INTFLAG_RXC_Msk))
        {
            ${SERCOM_INSTANCE_NAME}_USART_ISR_RX_Handler();
        }

        </#if>
        <#if USART_INTENSET_ERROR = true>
        /* Checks for error flag */
        if((${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTENSET & SERCOM_USART_INT_INTENSET_ERROR_Msk) && (${SERCOM_INSTANCE_NAME}_REGS->USART_INT.SERCOM_INTFLAG & SERCOM_USART_INT_INTFLAG_ERROR_Msk))
        {
            ${SERCOM_INSTANCE_NAME}_USART_ISR_ERR_Handler();
        }
        </#if>
    }
}