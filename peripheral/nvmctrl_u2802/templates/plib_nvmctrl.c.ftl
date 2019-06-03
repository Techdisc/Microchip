/*******************************************************************************
  Non-Volatile Memory Controller(${NVMCTRL_INSTANCE_NAME}) PLIB.

  Company:
    Microchip Technology Inc.

  File Name:
    plib_${NVMCTRL_INSTANCE_NAME?lower_case}.c

  Summary:
    Interface definition of ${NVMCTRL_INSTANCE_NAME} Plib.

  Description:
    This file defines the interface for the ${NVMCTRL_INSTANCE_NAME} Plib.
    It allows user to Program, Erase and lock the on-chip Non Volatile Flash
    Memory.
*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <string.h>
#include "plib_${NVMCTRL_INSTANCE_NAME?lower_case}.h"


// *****************************************************************************
// *****************************************************************************
// Section: ${NVMCTRL_INSTANCE_NAME} Implementation
// *****************************************************************************
// *****************************************************************************

<#if INTERRUPT_ENABLE == true>
    <#lt>NVMCTRL_CALLBACK ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackFunc;

    <#lt>uintptr_t ${NVMCTRL_INSTANCE_NAME?lower_case}Context;

    <#lt>void ${NVMCTRL_INSTANCE_NAME}_CallbackRegister( NVMCTRL_CALLBACK callback, uintptr_t context )
    <#lt>{
    <#lt>    /* Register callback function */
    <#lt>    ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackFunc = callback;
    <#lt>    ${NVMCTRL_INSTANCE_NAME?lower_case}Context = context;
    <#lt>}

    <#lt>void ${NVMCTRL_INSTANCE_NAME}_InterruptHandler(void)
    <#lt>{
    <#lt>    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENCLR = NVMCTRL_INTENCLR_DONE_Msk;

    <#lt>    if(${NVMCTRL_INSTANCE_NAME?lower_case}CallbackFunc != NULL)
    <#lt>    {
    <#lt>        ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackFunc(${NVMCTRL_INSTANCE_NAME?lower_case}Context);
    <#lt>    }
    <#lt>}
</#if>

void ${NVMCTRL_INSTANCE_NAME}_Initialize(void)
{
    <@compress single_line=true>${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = ${NVMCTRL_CACHE_ENABLE?then('', 'NVMCTRL_CTRLB_CACHEDIS_Msk |')}
    <#lt>                       NVMCTRL_CTRLB_READMODE_${NVMCTRL_CTRLB_READMODE_SELECTION} |
    <#lt>                       NVMCTRL_CTRLB_SLEEPPRM_${NVMCTRL_CTRLB_POWER_REDUCTION_MODE} | NVMCTRL_CTRLB_RWS(${NVM_RWS})${FAST_WAKEUP_ENABLE?then(' | NVMCTRL_CTRLB_FWUP_Msk', '')}
    <#lt>                       ;</@compress>
    <#if (NVMCTRL_WRITE_POLICY == "MANUAL")>
    <#lt>    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLC = NVMCTRL_CTRLC_MANW_Msk;
    </#if>
    <#if (TAMPER_DETECTION_ENABLE || SILENT_ACCESS_ENABLE || EXECUTE_DATA_FLASH) >
    <#lt>    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_SECCTRL = NVMCTRL_SECCTRL_KEY_KEY | NVMCTRL_SECCTRL_TEROW(${TAMPER_ROW})${TAMPER_DETECTION_ENABLE?then(' | NVMCTRL_SECCTRL_TAMPEEN_Msk', '')}${SILENT_ACCESS_ENABLE?then(' | NVMCTRL_SECCTRL_SILACC_Msk', '')}${EXECUTE_DATA_FLASH?then(' | NVMCTRL_SECCTRL_DXN_Msk', '')};
    </#if>
    <#if AUTOWEI_ENABLE>
    <#lt>    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_EVCTRL = NVMCTRL_EVCTRL_AUTOWEI_Msk${AUTOWINV_ENABLE?then(' | NVMCTRL_EVCTRL_AUTOWINV_Msk', '')};
    </#if>
}

<#if NVMCTRL_CACHE_ENABLE == true>
    <#lt>void ${NVMCTRL_INSTANCE_NAME}_CacheInvalidate(void)
    <#lt>{
    <#lt>    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLA = NVMCTRL_CTRLA_CMD_INVALL | NVMCTRL_CTRLA_CMDEX_KEY;
    <#lt>}
</#if>

bool ${NVMCTRL_INSTANCE_NAME}_Read( uint32_t *data, uint32_t length, const uint32_t address )
{
    memcpy((void *)data, (void *)address, length);
    return true;
}

bool ${NVMCTRL_INSTANCE_NAME}_PageWrite( uint32_t *data, const uint32_t address )
{
    uint32_t i = 0;
    uint32_t * paddress = (uint32_t *)address;
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = 0;
    if((address & DATAFLASH_ADDR) == DATAFLASH_ADDR)
    {
        ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = NVMCTRL_ADDR_ARRAY_DATAFLASH;
    }

    /* writing 32-bit data into the given address */
    for (i = 0; i < (${NVMCTRL_INSTANCE_NAME}_FLASH_PAGESIZE/4); i++)
    {
        *paddress++ = data[i];
    }

<#if NVMCTRL_WRITE_POLICY == "MANUAL">
     /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR |= address;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLA = NVMCTRL_CTRLA_CMD_WP_Val | NVMCTRL_CTRLA_CMDEX_KEY;
</#if>

<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_DONE_Msk;
</#if>
    return true;
}

bool ${NVMCTRL_INSTANCE_NAME}_RowErase( uint32_t address )
{
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = 0;
    if((address & DATAFLASH_ADDR) == DATAFLASH_ADDR)
    {
        ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = NVMCTRL_ADDR_ARRAY_DATAFLASH;
    }
    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR |= address;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLA = NVMCTRL_CTRLA_CMD_ER_Val | NVMCTRL_CTRLA_CMDEX_KEY;

<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_DONE_Msk;
</#if>
    return true;
}

NVMCTRL_ERROR ${NVMCTRL_INSTANCE_NAME}_ErrorGet( void )
{
    return ((uint32_t) (${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTFLAG));
}

bool ${NVMCTRL_INSTANCE_NAME}_IsBusy(void)
{
    return (bool)(!(NVMCTRL_REGS->NVMCTRL_STATUS & NVMCTRL_STATUS_READY_Msk));
}

void ${NVMCTRL_INSTANCE_NAME}_RegionLock(NVMCTRL_MEMORY_REGION region)
{
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_NSULCK = NVMCTRL_NSULCK_NSLKEY_KEY | region;
}

void ${NVMCTRL_INSTANCE_NAME}_RegionUnlock(NVMCTRL_MEMORY_REGION region)
{
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLA = (${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLA & ~(region)) | NVMCTRL_NSULCK_NSLKEY_KEY;
}
