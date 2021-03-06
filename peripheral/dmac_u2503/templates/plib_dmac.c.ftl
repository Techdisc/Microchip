/*******************************************************************************
  Direct Memory Access Controller (DMAC) PLIB

  Company
    Microchip Technology Inc.

  File Name
    plib_${DMA_INSTANCE_NAME?lower_case}.c

  Summary
    Source for ${DMA_INSTANCE_NAME} peripheral library interface Implementation.

  Description
    This file defines the interface to the DMAC peripheral library. This
    library provides access to and control of the DMAC controller.

  Remarks:
    None.

*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

#include "plib_${DMA_INSTANCE_NAME?lower_case}.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

#define DMAC_CHANNELS_NUMBER        ${DMAC_HIGHEST_CHANNEL+1}

/* DMAC channels object configuration structure */
typedef struct
{
    uint8_t                inUse;
    DMAC_CHANNEL_CALLBACK  callback;
    uintptr_t              context;
    uint8_t                busyStatus;
} DMAC_CH_OBJECT ;

/* Initial write back memory section for DMAC */
static  dmac_descriptor_registers_t _write_back_section[DMAC_CHANNELS_NUMBER]    __ALIGNED(16);

/* Descriptor section for DMAC */
static  dmac_descriptor_registers_t  descriptor_section[DMAC_CHANNELS_NUMBER]    __ALIGNED(16);

/* DMAC Channels object information structure */
DMAC_CH_OBJECT dmacChannelObj[DMAC_CHANNELS_NUMBER];

// *****************************************************************************
// *****************************************************************************
// Section: DMAC PLib Interface Implementations
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
This function initializes the DMAC controller of the device.
********************************************************************************/

void ${DMA_INSTANCE_NAME}_Initialize( void )
{
    DMAC_CH_OBJECT *dmacChObj = (DMAC_CH_OBJECT *)&dmacChannelObj[0];
    uint32_t channel = 0;

    /* Initialize DMAC Channel objects */
    for(channel = 0; channel < DMAC_CHANNELS_NUMBER; channel++)
    {
        dmacChObj->inUse = 0;
        dmacChObj->callback = NULL;
        dmacChObj->context = 0;
        dmacChObj->busyStatus = false;

        /* Point to next channel object */
        dmacChObj += 1;
    }

    /* Update the Base address and Write Back address register */
    ${DMA_INSTANCE_NAME}_REGS->DMAC_BASEADDR = (uint32_t) descriptor_section;
    ${DMA_INSTANCE_NAME}_REGS->DMAC_WRBADDR  = (uint32_t)_write_back_section;

    /* Update the Priority Control register */
    <@compress single_line=true>${DMA_INSTANCE_NAME}_REGS->DMAC_PRICTRL0 = DMAC_PRICTRL0_LVLPRI0(${DMAC_LVLXPRIO_0}) | <#if DMAC_LVLXPRIO_0 == "1">DMAC_PRICTRL0_RRLVLEN0_Msk |</#if>
                                                                           DMAC_PRICTRL0_LVLPRI1(${DMAC_LVLXPRIO_1}) | <#if DMAC_LVLXPRIO_1 == "1">DMAC_PRICTRL0_RRLVLEN1_Msk |</#if>
                                                                           DMAC_PRICTRL0_LVLPRI2(${DMAC_LVLXPRIO_2}) | <#if DMAC_LVLXPRIO_2 == "1">DMAC_PRICTRL0_RRLVLEN2_Msk |</#if>
                                                                           DMAC_PRICTRL0_LVLPRI3(${DMAC_LVLXPRIO_3})<#if DMAC_LVLXPRIO_3 == "1"> | DMAC_PRICTRL0_RRLVLEN3_Msk</#if>;</@compress>
    <#list 0..DMAC_HIGHEST_CHANNEL as i>
        <#assign DMAC_CHCTRLA_ENABLE    = "DMAC_ENABLE_CH_"           + i>
        <#assign DMAC_CHCTRLA_RUNSTDBY  = "DMAC_CHCTRLA_RUNSTDBY_CH_" + i>
        <#assign DMAC_CHCTRLA_TRIGACT   = "DMAC_CHCTRLA_TRIGACT_CH_"  + i>
        <#assign DMAC_CHCTRLA_LVL       = "DMAC_CHCTRLA_LVL_CH_"      + i>
        <#assign DMAC_BTCTRL_SRCINC     = "DMAC_BTCTRL_SRCINC_CH_"    + i>
        <#assign DMAC_BTCTRL_DSTINC     = "DMAC_BTCTRL_DSTINC_CH_"    + i>
        <#assign DMAC_BTCTRL_BEATSIZE   = "DMAC_BTCTRL_BEATSIZE_CH_"  + i>
        <#assign DMAC_TRIGSRC_PERID_VAL = "DMAC_CHCTRLA_TRIGSRC_CH_" + i + "_PERID_VAL">
        <#assign DMAC_BURSTLEN = "DMAC_CHCTRLA_BURSTLEN_CH_" + i>
        <#assign DMAC_THRESH = "DMAC_CHCTRLA_THRESH_CH_" + i>
        <#if i < DMA_EVSYS_GENERATOR_COUNT>
            <#assign DMAC_EVSYS_OUT = "DMAC_ENABLE_EVSYS_OUT_" + i >
            <#assign DMAC_EVSYS_EVOSEL = "DMAC_BTCTRL_EVSYS_EVOSEL_" + i >
            <#assign DMAC_EVSYS_EVOMODE = "DMAC_BTCTRL_EVSYS_EVOMODE_" + i >
        </#if>
        <#if i < DMA_EVSYS_USER_COUNT>
            <#assign DMAC_EVSYS_IN = "DMAC_ENABLE_EVSYS_IN_" + i >
            <#assign DMAC_EVSYS_EVACT = "DMAC_CHEVCTRL_EVACT_" + i >
        </#if>

        <#if (.vars[DMAC_CHCTRLA_ENABLE] == true)>
        <#lt>   /***************** Configure DMA channel ${i} ********************/
        <#lt>   <@compress single_line=true>${DMA_INSTANCE_NAME}_REGS->CHANNEL[${i}].DMAC_CHCTRLA = DMAC_CHCTRLA_TRIGACT(${.vars[DMAC_CHCTRLA_TRIGACT]})
        <#lt>                                                       | DMAC_CHCTRLA_TRIGSRC(${.vars[DMAC_TRIGSRC_PERID_VAL]})
        <#lt>                                                       | DMAC_CHCTRLA_THRESHOLD(${.vars[DMAC_THRESH]})
        <#lt>                                                       | DMAC_CHCTRLA_BURSTLEN(${.vars[DMAC_BURSTLEN]})
        <#lt>                                                       ${(.vars[DMAC_CHCTRLA_RUNSTDBY])?then('| DMAC_CHCTRLA_RUNSTDBY_Msk','')}
        <#lt>                                                       ;
        <#lt>   </@compress>
        <#lt>

        <#lt>   <@compress single_line=true>descriptor_section[${i}].DMAC_BTCTRL = DMAC_BTCTRL_BLOCKACT_INT
        <#lt>                                                                       | DMAC_BTCTRL_BEATSIZE_${.vars[DMAC_BTCTRL_BEATSIZE]}
        <#lt>                                                                       | DMAC_BTCTRL_VALID_Msk
        <#lt>                                                                       ${(.vars[DMAC_BTCTRL_SRCINC] == "INCREMENTED_AM")?then('| DMAC_BTCTRL_SRCINC_Msk','')}
        <#lt>                                                                       ${(.vars[DMAC_BTCTRL_DSTINC] == "INCREMENTED_AM")?then('| DMAC_BTCTRL_DSTINC_Msk','')}
        <#lt>                                                                       <#if i < DMA_EVSYS_GENERATOR_COUNT>
        <#lt>                                                                       ${(.vars[DMAC_EVSYS_OUT])?then('| DMAC_BTCTRL_EVOSEL(${.vars[DMAC_EVSYS_EVOSEL]})','')}
        <#lt>                                                                       </#if>
        <#lt>                                                                       ;
        <#lt>   </@compress>

        <#lt>   ${DMA_INSTANCE_NAME}_REGS->CHANNEL[${i}].DMAC_CHPRILVL = DMAC_CHPRILVL_PRILVL(${.vars[DMAC_CHCTRLA_LVL]});

        <#lt>   dmacChannelObj[${i}].inUse = 1;

        <#lt>   ${DMA_INSTANCE_NAME}_REGS->CHANNEL[${i}].DMAC_CHINTENSET = (DMAC_CHINTENSET_TERR_Msk | DMAC_CHINTENSET_TCMPL_Msk);

        <#if i < DMA_EVSYS_USER_COUNT>
        <#if (.vars[DMAC_EVSYS_OUT] == true) || (.vars[DMAC_EVSYS_IN] == true)>
        <#lt>   <@compress single_line=true>${DMA_INSTANCE_NAME}_REGS->CHANNEL[${i}].DMAC_CHEVCTRL = DMAC_CHEVCTRL_EVACT(${.vars[DMAC_EVSYS_EVACT]})
                                                                                            <#if i < DMA_EVSYS_GENERATOR_COUNT>
        <#lt>                                                                                ${(.vars[DMAC_EVSYS_OUT])?then('| DMAC_CHEVCTRL_EVOE_Msk | DMAC_CHEVCTRL_EVOMODE(${.vars[DMAC_EVSYS_EVOMODE]})','')}
                                                                                            </#if>
        <#lt>                                                                                ${(.vars[DMAC_EVSYS_IN])?then('| DMAC_CHEVCTRL_EVIE_Msk','')}
        <#lt>
        <#lt>;</@compress>
        </#if>
        </#if>
        </#if>
    </#list>
    /* Enable the DMAC module & Priority Level x Enable */
    ${DMA_INSTANCE_NAME}_REGS->DMAC_CTRL = DMAC_CTRL_DMAENABLE_Msk | DMAC_CTRL_LVLEN0_Msk | DMAC_CTRL_LVLEN1_Msk | DMAC_CTRL_LVLEN2_Msk | DMAC_CTRL_LVLEN3_Msk;
}

/*******************************************************************************
    This function schedules a DMA transfer on the specified DMA channel.
********************************************************************************/

bool ${DMA_INSTANCE_NAME}_ChannelTransfer( DMAC_CHANNEL channel, const void *srcAddr, const void *destAddr, size_t blockSize )
{
    uint8_t beat_size = 0;
    bool returnStatus = false;

    if (dmacChannelObj[channel].busyStatus == false)
    {
        /* Get a pointer to the module hardware instance */
        dmac_descriptor_registers_t *const dmacDescReg = &descriptor_section[channel];

        dmacChannelObj[channel].busyStatus = true;

       /*Set source address */
        if ( dmacDescReg->DMAC_BTCTRL & DMAC_BTCTRL_SRCINC_Msk)
        {
            dmacDescReg->DMAC_SRCADDR = (uint32_t) ((intptr_t)srcAddr + blockSize);
        }
        else
        {
            dmacDescReg->DMAC_SRCADDR = (uint32_t) (srcAddr);
        }

        /* Set destination address */
        if ( dmacDescReg->DMAC_BTCTRL & DMAC_BTCTRL_DSTINC_Msk)
        {
            dmacDescReg->DMAC_DSTADDR = (uint32_t) ((intptr_t)destAddr + blockSize);
        }
        else
        {
            dmacDescReg->DMAC_DSTADDR = (uint32_t) (destAddr);
        }

        /*Calculate the beat size and then set the BTCNT value */
        beat_size = (dmacDescReg->DMAC_BTCTRL & DMAC_BTCTRL_BEATSIZE_Msk) >> DMAC_BTCTRL_BEATSIZE_Pos;

        /* Set Block Transfer Count */
        dmacDescReg->DMAC_BTCNT = blockSize / (1 << beat_size);

        /* Enable the channel */
        ${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHCTRLA |= DMAC_CHCTRLA_ENABLE_Msk;

        /* Verify if Trigger source is Software Trigger */
        if ((((${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHCTRLA & DMAC_CHCTRLA_TRIGSRC_Msk) >> DMAC_CHCTRLA_TRIGSRC_Pos) == 0x00)
                                                && (((${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHEVCTRL & DMAC_CHEVCTRL_EVIE_Msk)) != DMAC_CHEVCTRL_EVIE_Msk))
        {
            /* Trigger the DMA transfer */
            ${DMA_INSTANCE_NAME}_REGS->DMAC_SWTRIGCTRL |= (1 << channel);
        }
        returnStatus = true;
    }

    return returnStatus;
}

/*******************************************************************************
    This function returns the status of the channel.
********************************************************************************/

bool ${DMA_INSTANCE_NAME}_ChannelIsBusy ( DMAC_CHANNEL channel )
{
    return (bool)dmacChannelObj[channel].busyStatus;
}

/*******************************************************************************
    This function disables the specified DMAC channel.
********************************************************************************/

void ${DMA_INSTANCE_NAME}_ChannelDisable ( DMAC_CHANNEL channel )
{
    /* Disable the DMA channel */
    ${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHCTRLA &= (~DMAC_CHCTRLA_ENABLE_Pos);

    while((${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHCTRLA & DMAC_CHCTRLA_ENABLE_Msk) != 0);

    dmacChannelObj[channel].busyStatus=false;

}

uint16_t ${DMA_INSTANCE_NAME}_ChannelGetTransferredCount( DMAC_CHANNEL channel )
{
    return(descriptor_section[channel].DMAC_BTCNT - _write_back_section[channel].DMAC_BTCNT);
}

<#if DMAC_LL_ENABLE = true>
/*******************************************************************************
    This function submit a list of DMA transfers.
********************************************************************************/

bool ${DMA_INSTANCE_NAME}_ChannelLinkedListTransfer (DMAC_CHANNEL channel, dmac_descriptor_registers_t* channelDesc)
{
    bool returnStatus = false;

    if (dmacChannelObj[channel].busyStatus == false)
    {
        dmacChannelObj[channel].busyStatus = true;

        memcpy(&descriptor_section[channel], channelDesc, sizeof(dmac_descriptor_registers_t));

        /* Enable the channel */
        ${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHCTRLA |= DMAC_CHCTRLA_ENABLE_Msk;

        /* Verify if Trigger source is Software Trigger */
        if (((${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHCTRLA & DMAC_CHCTRLA_TRIGSRC_Msk) >> DMAC_CHCTRLA_TRIGSRC_Pos) == 0x00)
        {
            /* Trigger the DMA transfer */
            ${DMA_INSTANCE_NAME}_REGS->DMAC_SWTRIGCTRL |= (1 << channel);
        }
        returnStatus = true;
    }

    return returnStatus;
}
</#if>

/*******************************************************************************
    This function function allows a DMAC PLIB client to set an event handler.
********************************************************************************/

void ${DMA_INSTANCE_NAME}_ChannelCallbackRegister( DMAC_CHANNEL channel, const DMAC_CHANNEL_CALLBACK callback, const uintptr_t context )
{
    dmacChannelObj[channel].callback = callback;
    dmacChannelObj[channel].context  = context;
}

/*******************************************************************************
    This function returns the current channel settings for the specified DMAC Channel
********************************************************************************/

DMAC_CHANNEL_CONFIG ${DMA_INSTANCE_NAME}_ChannelSettingsGet (DMAC_CHANNEL channel)
{
    /* Get a pointer to the module hardware instance */
    dmac_descriptor_registers_t *const dmacDescReg = &descriptor_section[0];

    return (dmacDescReg[channel].DMAC_BTCTRL);
}

/*******************************************************************************
    This function changes the current settings of the specified DMAC channel.
********************************************************************************/

bool ${DMA_INSTANCE_NAME}_ChannelSettingsSet (DMAC_CHANNEL channel, DMAC_CHANNEL_CONFIG setting)
{
    /* Get a pointer to the module hardware instance */
    dmac_descriptor_registers_t *const dmacDescReg = &descriptor_section[0];

    /* Disable the channel */
    /* Disable the DMA channel */
    ${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHCTRLA &= (~DMAC_CHCTRLA_ENABLE_Pos);

    /* Set the new settings */
    dmacDescReg[channel].DMAC_BTCTRL = setting;

    return true;
}

//*******************************************************************************
//    Functions to handle DMA interrupt events.
//*******************************************************************************
void _DMAC_interruptHandler(uint8_t channel)
{
    DMAC_CH_OBJECT  *dmacChObj = NULL;
    volatile uint32_t chanIntFlagStatus = 0;
    DMAC_TRANSFER_EVENT event   = DMAC_TRANSFER_EVENT_ERROR;

    dmacChObj = (DMAC_CH_OBJECT *)&dmacChannelObj[channel];

    /* Get the DMAC channel interrupt status */
    chanIntFlagStatus = ${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHINTFLAG;

    /* Verify if DMAC Channel Transfer complete flag is set */
    if (chanIntFlagStatus & DMAC_CHINTENCLR_TCMPL_Msk)
    {
        /* Clear the transfer complete flag */
        ${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHINTFLAG = DMAC_CHINTENCLR_TCMPL_Msk;

        event = DMAC_TRANSFER_EVENT_COMPLETE;
        dmacChObj->busyStatus = false;
    }

    /* Verify if DMAC Channel Error flag is set */
    if (chanIntFlagStatus & DMAC_CHINTENCLR_TERR_Msk)
    {
        /* Clear transfer error flag */
        ${DMA_INSTANCE_NAME}_REGS->CHANNEL[channel].DMAC_CHINTFLAG = DMAC_CHINTENCLR_TERR_Msk;

        event = DMAC_TRANSFER_EVENT_ERROR;
        dmacChObj->busyStatus = false;
    }

    /* Execute the callback function */
    if (dmacChObj->callback != NULL)
    {
        dmacChObj->callback (event, dmacChObj->context);
    }
}

<#list 0..DMA_INT_LINES-1 as x>
<#assign DMAC_INT_NAME  = "DMA_INT_NAME_"  + x>
<#assign res =.vars[DMAC_INT_NAME]?matches(r"(\d+)")>

<#if (res) && ((res?groups[1])?number <= DMAC_HIGHEST_CHANNEL)>
void ${DMA_INSTANCE_NAME}_${res?groups[1]}_InterruptHandler( void )
{
	_DMAC_interruptHandler(${res?groups[1]});
}

<#elseif (.vars[DMAC_INT_NAME] == "OTHER") &&  (4 <= DMAC_HIGHEST_CHANNEL) >
void ${DMA_INSTANCE_NAME}_${.vars[DMAC_INT_NAME]}_InterruptHandler( void )
{
    uint8_t channel = 0;

    for(channel = 4; channel <= ${DMAC_HIGHEST_CHANNEL}; channel++)
    {
        if ((${DMA_INSTANCE_NAME}_REGS->DMAC_INTSTATUS >> channel) & 0x1)
        {
            _DMAC_interruptHandler(channel);
        }
    }
}
</#if>
</#list>