/*******************************************************************************
  RTC Peripheral Library

  Company:
    Microchip Technology Inc.

  File Name:
    plib_${RTC_INSTANCE_NAME?lower_case}.c

  Summary:
    RTC Source File

  Description:
    None

*******************************************************************************/

/*******************************************************************************
* © 2018 Microchip Technology Inc. and its subsidiaries.
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

#include "device.h"
#include "plib_${RTC_INSTANCE_NAME?lower_case}.h"

#define decimaltobcd(x)					(((x/10)<<4)+((x - ((x/10)*10))))
#define bcdtodecimal(x)					((x & 0xF0) >> 4) * 10 + (x & 0x0F)

<#if rtcEnableInterrupt == true>
	<#lt>RTC_OBJECT rtc;
</#if>

void ${RTC_INSTANCE_NAME}_Initialize( void )
{
	${RTC_INSTANCE_NAME}_REGS->RTC_MR = RTC_MR_OUT0_${RTC_MR_OUT0} | RTC_MR_OUT1_${RTC_MR_OUT1} | RTC_MR_THIGH_${RTC_MR_THIGH} | RTC_MR_TPERIOD_${RTC_MR_TPERIOD};
	${RTC_INSTANCE_NAME}_REGS->RTC_CR = RTC_CR_TIMEVSEL_${RTC_CR_TIMEVSEL} | RTC_CR_CALEVSEL_${RTC_CR_CALEVSEL};
}

bool ${RTC_INSTANCE_NAME}_TimeSet( struct tm *Time )
{
	Time->tm_year += 1900;
	uint32_t data_cal =  (decimaltobcd(Time->tm_year / 100)) | \
			 (decimaltobcd((Time->tm_year - ((Time->tm_year/100)*100)))<< RTC_CALR_YEAR_Pos) | \
			   (decimaltobcd((Time->tm_mon + 1))<<RTC_CALR_MONTH_Pos)| \
			 (decimaltobcd(Time->tm_mday)<<RTC_CALR_DATE_Pos) | \
			 ((Time->tm_wday + 1) << RTC_CALR_DAY_Pos);
	uint32_t data_time = (decimaltobcd(Time->tm_sec)) | (decimaltobcd(Time->tm_min) << RTC_TIMR_MIN_Pos) | (decimaltobcd(Time->tm_hour)<< RTC_TIMR_HOUR_Pos);
	${RTC_INSTANCE_NAME}_REGS->RTC_CR&= ~(RTC_CR_UPDCAL_Msk|RTC_CR_UPDTIM_Msk);
	${RTC_INSTANCE_NAME}_REGS->RTC_SCCR = (1<<2) ;
	while ((${RTC_INSTANCE_NAME}_REGS->RTC_SR& RTC_SR_SEC_Msk) != RTC_SR_SEC_Msk );
		    /* - request RTC Configuration */
	${RTC_INSTANCE_NAME}_REGS->RTC_CR|= (RTC_CR_UPDCAL_Msk) | RTC_CR_UPDTIM_Msk;
		    /* - Wait for ack */
	while (!((${RTC_INSTANCE_NAME}_REGS->RTC_SR) & (RTC_SR_ACKUPD_Msk)));
		    /* - Clear ACK flag */
	${RTC_INSTANCE_NAME}_REGS->RTC_SCCR|= RTC_SCCR_ACKCLR_Msk | RTC_SCCR_ALRCLR_Msk | RTC_SCCR_TIMCLR_Msk;
	${RTC_INSTANCE_NAME}_REGS->RTC_CALR = data_cal;
	${RTC_INSTANCE_NAME}_REGS->RTC_TIMR = data_time;
	${RTC_INSTANCE_NAME}_REGS->RTC_CR&= ~(RTC_CR_UPDCAL_Msk|RTC_CR_UPDTIM_Msk);
	if(${RTC_INSTANCE_NAME}_REGS->RTC_VER& 0x3)
	{
		return false;
	}
	
	return true;
}

void ${RTC_INSTANCE_NAME}_TimeGet( struct tm *Time )
{
	uint32_t data_time = ${RTC_INSTANCE_NAME}_REGS->RTC_TIMR;
	while (data_time != ${RTC_INSTANCE_NAME}_REGS->RTC_TIMR) 
	{
		data_time = ${RTC_INSTANCE_NAME}_REGS->RTC_TIMR;
	}
	uint32_t data_cal  = ${RTC_INSTANCE_NAME}_REGS->RTC_CALR;
	while (data_cal != ${RTC_INSTANCE_NAME}_REGS->RTC_CALR) 
	{
		data_cal = ${RTC_INSTANCE_NAME}_REGS->RTC_CALR;
	}
	
	Time->tm_hour = bcdtodecimal((data_time & RTC_TIMR_HOUR_Msk) >> RTC_TIMR_HOUR_Pos);
	Time->tm_sec = bcdtodecimal(data_time & RTC_TIMR_SEC_Msk);
	Time->tm_min = bcdtodecimal((data_time & RTC_TIMR_MIN_Msk)>>RTC_TIMR_MIN_Pos);
	Time->tm_mday = bcdtodecimal((data_cal & RTC_CALR_DATE_Msk)>>RTC_CALR_DATE_Pos);
	Time->tm_wday = (bcdtodecimal((data_cal & RTC_CALR_DAY_Msk)>>RTC_CALR_DAY_Pos)) - 1;
	Time->tm_mon =  (bcdtodecimal((data_cal & RTC_CALR_MONTH_Msk)>>RTC_CALR_MONTH_Pos)) - 1;
	Time->tm_year = (100 * (bcdtodecimal((data_cal & RTC_CALR_CENT_Msk))) \
            + bcdtodecimal((data_cal & RTC_CALR_YEAR_Msk)>>RTC_CALR_YEAR_Pos)) - 1900;	
}

<#if rtcEnableInterrupt == true>
	<#lt>bool ${RTC_INSTANCE_NAME}_AlarmSet( struct tm *Time, RTC_ALARM_MASK mask )
	<#lt>{
	<#lt>	uint32_t alarm_cal;
	<#lt>	uint32_t alarm_tmr;	
	<#lt>	uint32_t data_cal =		(decimaltobcd(Time->tm_mon + 1)<<16)| \
	<#lt>									(decimaltobcd(Time->tm_mday)<<24) ;
	<#lt>	uint32_t data_time = (decimaltobcd(Time->tm_sec)) | (decimaltobcd(Time->tm_min) << 8) \
	<#lt>								| (decimaltobcd(Time->tm_hour)<< 16);
	<#lt>	alarm_tmr = ${RTC_INSTANCE_NAME}_REGS->RTC_TIMALR;
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_TIMALR = data_time;
	<#lt>	alarm_cal = ${RTC_INSTANCE_NAME}_REGS->RTC_CALALR;
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_CALALR = data_cal;
	<#lt>
	<#lt>	alarm_cal = (mask & 0x10) << 19 | (mask & 0x08) << 28;
	<#lt>	alarm_tmr = (mask & 0x04) << 21 | (mask & 0x02) << 14 | (mask & 0x01) << 7;
	<#lt>  
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_TIMALR|= alarm_tmr;
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_CALALR|= alarm_cal;
	<#lt>
	<#lt>	if(${RTC_INSTANCE_NAME}_REGS->RTC_VER& 0xC)
	<#lt>	{
	<#lt>		return false;
	<#lt>	}
	<#lt>
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_IER = RTC_IER_ALREN_Msk;
	<#lt>
	<#lt>	return true;
	<#lt>}
		
	<#lt>void ${RTC_INSTANCE_NAME}_InterruptEnable(RTC_INT_MASK interrupt)
	<#lt>{
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_IER = interrupt;
	<#lt>}

	<#lt>void ${RTC_INSTANCE_NAME}_InterruptDisable(RTC_INT_MASK interrupt)
	<#lt>{
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_IDR = interrupt;
	<#lt>}

	<#lt>void ${RTC_INSTANCE_NAME}_CallbackRegister( RTC_CALLBACK callback, uintptr_t context )
	<#lt>{
	<#lt>	rtc.callback = callback;
	<#lt>	rtc.context = context;
	<#lt>}
</#if>

<#if rtcEnableInterrupt == true>
	<#lt>void ${RTC_INSTANCE_NAME}_InterruptHandler( void )
	<#lt>{
	<#lt>	volatile uint32_t status = ${RTC_INSTANCE_NAME}_REGS->RTC_SR;
	<#lt>	${RTC_INSTANCE_NAME}_REGS->RTC_SCCR|= RTC_SCCR_ALRCLR_Msk | RTC_SCCR_TIMCLR_Msk |  RTC_SCCR_CALCLR_Msk;
	<#lt>	if(rtc.callback != NULL)
    <#lt>   {
    <#lt>   	rtc.callback(rtc.context, status);
    <#lt>   }
	<#lt>}
</#if>	
