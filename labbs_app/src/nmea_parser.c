/*
 *
 * NMEA library
 * URL: http://nmea.sourceforge.net
 * Author: Tim (xtimor@gmail.com)
 * Licence: http://www.gnu.org/licenses/lgpl.html
 * $Id: parse.c 17 2008-03-11 11:56:11Z xtimor $
 *
 */

/**
 * \file parse.h
 * \brief Functions of a low level for analysis of
 * packages of NMEA stream.
 *
 * \code
 * ...
 * ptype = nmea_pack_type(
 *     (const char *)parser->buffer + nparsed + 1,
 *     parser->buff_use - nparsed - 1);
 *
 * if(0 == (node = XH_MALLOC(sizeof(nmeaParserNODE))))
 *     goto mem_fail;
 *
 * node->pack = 0;
 *
 * switch(ptype)
 * {
 * case GPGGA:
 *     if(0 == (node->pack = XH_MALLOC(sizeof(nmeaGPGGA))))
 *         goto mem_fail;
 *     node->packType = GPGGA;
 *     if(!nmea_parse_GPGGA(
 *         (const char *)parser->buffer + nparsed,
 *         sen_sz, (nmeaGPGGA *)node->pack))
 *     {
 *         XH_FREE(node);
 *         node = 0;
 *     }
 *     break;
 * case GPGSA:
 *     if(0 == (node->pack = XH_MALLOC(sizeof(nmeaGPGSA))))
 *         goto mem_fail;
 *     node->packType = GPGSA;
 *     if(!nmea_parse_GPGSA(
 *         (const char *)parser->buffer + nparsed,
 *         sen_sz, (nmeaGPGSA *)node->pack))
 *     {
 *         XH_FREE(node);
 *         node = 0;
 *     }
 *     break;
 * ...
 * \endcode
 */

#include "nmea_parser.h"

#include <string.h>
#include <stdio.h>
#define NMEA_TOKS_COMPARE (1)
#define NMEA_TOKS_PERCENT (2)
#define NMEA_TOKS_WIDTH (3)
#define NMEA_TOKS_TYPE (4)

nmeaPROPERTY *nmea_property(void)
{
    static nmeaPROPERTY prop = {
        0, 0, NMEA_DEF_PARSEBUFF};

    return &prop;
}

void nmea_trace_buff(const char *buff, int buff_size)
{
    nmeaTraceFunc func = nmea_property()->trace_func;
    if (func && buff_size)
        (*func)(buff, buff_size);
}

void nmea_error(const char *str, ...)
{
    int size;
    va_list arg_list;
    char buff[NMEA_DEF_PARSEBUFF];
    nmeaErrorFunc func = nmea_property()->error_func;

    if (func)
    {
        va_start(arg_list, str);
        size = NMEA_POSIX(vsnprintf)(&buff[0], NMEA_DEF_PARSEBUFF - 1, str, arg_list);
        va_end(arg_list);

        if (size > 0)
            (*func)(&buff[0], size);
    }
}

/**
 * \brief Convert string to number
 */
int nmea_atoi(const char *str, int str_sz, int radix)
{
    char *tmp_ptr;
    char buff[NMEA_CONVSTR_BUF];
    int res = 0;

    if (str_sz < NMEA_CONVSTR_BUF)
    {
        memcpy(&buff[0], str, str_sz);
        buff[str_sz] = '\0';
        res = strtol(&buff[0], &tmp_ptr, radix);
    }

    return res;
}

/**
 * \brief Convert string to fraction number
 */
double nmea_atof(const char *str, int str_sz)
{
    char *tmp_ptr;
    char buff[NMEA_CONVSTR_BUF];
    double res = 0;

    if (str_sz < NMEA_CONVSTR_BUF)
    {
        memcpy(&buff[0], str, str_sz);
        buff[str_sz] = '\0';
        res = strtod(&buff[0], &tmp_ptr);
    }

    return res;
}

/**
 * \brief Analyse string (specificate for NMEA sentences)
 */
int nmea_scanf(const char *buff, int buff_sz, const char *format, ...)
{
    const char *beg_tok;
    const char *end_buf = buff + buff_sz;

    va_list arg_ptr;
    int tok_type = NMEA_TOKS_COMPARE;
    int width = 0;
    const char *beg_fmt = 0;
    int snum = 0, unum = 0;

    int tok_count = 0;
    void *parg_target;

    va_start(arg_ptr, format);

    for (; *format && buff < end_buf; ++format)
    {
        switch (tok_type)
        {
        case NMEA_TOKS_COMPARE:
            if ('%' == *format)
                tok_type = NMEA_TOKS_PERCENT;
            else if (*buff++ != *format)
                goto fail;
            break;
        case NMEA_TOKS_PERCENT:
            width = 0;
            beg_fmt = format;
            tok_type = NMEA_TOKS_WIDTH;
        case NMEA_TOKS_WIDTH:
            if (isdigit(*format))
                break;
            {
                tok_type = NMEA_TOKS_TYPE;
                if (format > beg_fmt)
                    width = nmea_atoi(beg_fmt, (int)(format - beg_fmt), 10);
            }
        case NMEA_TOKS_TYPE:
            beg_tok = buff;

            if (!width && ('c' == *format || 'C' == *format) && *buff != format[1])
                width = 1;

            if (width)
            {
                if (buff + width <= end_buf)
                    buff += width;
                else
                    goto fail;
            }
            else
            {
                if (!format[1] || (0 == (buff = (char *)memchr(buff, format[1], end_buf - buff))))
                    buff = end_buf;
            }

            if (buff > end_buf)
                goto fail;

            tok_type = NMEA_TOKS_COMPARE;
            tok_count++;

            parg_target = 0;
            width = (int)(buff - beg_tok);

            switch (*format)
            {
            case 'c':
            case 'C':
                parg_target = (void *)va_arg(arg_ptr, char *);
                if (width && 0 != (parg_target))
                    *((char *)parg_target) = *beg_tok;
                break;
            case 's':
            case 'S':
                parg_target = (void *)va_arg(arg_ptr, char *);
                if (width && 0 != (parg_target))
                {
                    memcpy(parg_target, beg_tok, width);
                    ((char *)parg_target)[width] = '\0';
                }
                break;
            case 'f':
            case 'g':
            case 'G':
            case 'e':
            case 'E':
                parg_target = (void *)va_arg(arg_ptr, double *);
                if (width && 0 != (parg_target))
                    *((double *)parg_target) = nmea_atof(beg_tok, width);
                break;
            };

            if (parg_target)
                break;
            if (0 == (parg_target = (void *)va_arg(arg_ptr, int *)))
                break;
            if (!width)
                break;

            switch (*format)
            {
            case 'd':
            case 'i':
                snum = nmea_atoi(beg_tok, width, 10);
                memcpy(parg_target, &snum, sizeof(int));
                break;
            case 'u':
                unum = nmea_atoi(beg_tok, width, 10);
                memcpy(parg_target, &unum, sizeof(unsigned int));
                break;
            case 'x':
            case 'X':
                unum = nmea_atoi(beg_tok, width, 16);
                memcpy(parg_target, &unum, sizeof(unsigned int));
                break;
            case 'o':
                unum = nmea_atoi(beg_tok, width, 8);
                memcpy(parg_target, &unum, sizeof(unsigned int));
                break;
            default:
                goto fail;
            };

            break;
        };
    }

fail:

    va_end(arg_ptr);
    return tok_count;
}

int _nmea_parse_time(const char *buff, int buff_sz, nmeaTIME *res)
{
    int success = 0;

    switch (buff_sz)
    {
    case sizeof("hhmmss") - 1:
        success = (3 == nmea_scanf(buff, buff_sz,
                                   "%2d%2d%2d", &(res->hour), &(res->min), &(res->sec)));
        break;
    case sizeof("hhmmss.s") - 1:
    case sizeof("hhmmss.ss") - 1:
    case sizeof("hhmmss.sss") - 1:
        success = (4 == nmea_scanf(buff, buff_sz,
                                   "%2d%2d%2d.%d", &(res->hour), &(res->min), &(res->sec), &(res->hsec)));
        break;
    default:
        nmea_error("Parse of time error (format error)!");
        success = 0;
        break;
    }

    return (success ? 0 : -1);
}
int _nmea_parse_time2(const char *buff, int buff_sz, nmeaTIME *res)
{
    int success = 0;

    switch (buff_sz)
    {
    case sizeof("ddmmyy") - 1:
        success = (3 == nmea_scanf(buff, buff_sz,
                                   "%2d%2d%2d", &(res->day), &(res->mon), &(res->year)));
        break;
    default:
        printf("Parse of time error (format error)!");
        success = 0;
        break;
    }

    return (success ? 0 : -1);
}

/**
 * \brief Parse GGA packet from buffer.
 * @param buff a constant character pointer of packet buffer.
 * @param buff_sz buffer size.
 * @param pack a pointer of packet which will filled by function.
 * @return 1 (true) - if parsed successfully or 0 (false) - if fail.
 */
int nmea_parse_GPGGA(const char *buff, int buff_sz, nmeaGPGGA *pack)
{
    char time_buff[NMEA_TIMEPARSE_BUF];

    NMEA_ASSERT(buff && pack);

    memset(pack, 0, sizeof(nmeaGPGGA));

    nmea_trace_buff(buff, buff_sz);
    if (buff[2] == 'N')
    {
        if (14 != nmea_scanf(buff, buff_sz,
                             "$GNGGA,%s,%f,%C,%f,%C,%d,%d,%f,%f,%C,%f,%C,%f,%d*",
                             &(time_buff[0]),
                             &(pack->lat), &(pack->ns), &(pack->lon), &(pack->ew),
                             &(pack->sig), &(pack->satinuse), &(pack->HDOP), &(pack->elv), &(pack->elv_units),
                             &(pack->diff), &(pack->diff_units), &(pack->dgps_age), &(pack->dgps_sid)))
        {
            nmea_error("GNGGA parse error!");
            return 0;
        }
    }
    else
    {
        if (14 != nmea_scanf(buff, buff_sz,
                             "$GPGGA,%s,%f,%C,%f,%C,%d,%d,%f,%f,%C,%f,%C,%f,%d*",
                             &(time_buff[0]),
                             &(pack->lat), &(pack->ns), &(pack->lon), &(pack->ew),
                             &(pack->sig), &(pack->satinuse), &(pack->HDOP), &(pack->elv), &(pack->elv_units),
                             &(pack->diff), &(pack->diff_units), &(pack->dgps_age), &(pack->dgps_sid)))
        {
            nmea_error("GPGGA parse error!");
            return 0;
        }
    }
    // pack->lat=(int)(pack->lat/100)+(pack->lat-(int)(pack->lat/100)*100)/60.0;
    // pack->lon=(int)(pack->lon/100)+(pack->lon-(int)(pack->lon/100)*100)/60.0;
    pack->lat *= 100000;
    pack->lon *= 100000;
    // printf("%d\r\n",(int)strlen(&time_buff[0]));
    if (((int)strlen(&time_buff[0]) > 2) && 0 != _nmea_parse_time(&time_buff[0], (int)strlen(&time_buff[0]), &(pack->utc)))
    {
        nmea_error("time parse error!");
        return 0;
    }
    // printf(buff);

    return 1;
}

/**
 * \brief Parse GSA packet from buffer.
 * @param buff a constant character pointer of packet buffer.
 * @param buff_sz buffer size.
 * @param pack a pointer of packet which will filled by function.
 * @return 1 (true) - if parsed successfully or 0 (false) - if fail.
 */
int nmea_parse_GPGSA(const char *buff, int buff_sz, nmeaGPGSA *pack)
{
    NMEA_ASSERT(buff && pack);

    memset(pack, 0, sizeof(nmeaGPGSA));

    nmea_trace_buff(buff, buff_sz);

    if (17 != nmea_scanf(buff, buff_sz,
                         "$GPGSA,%C,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f*",
                         &(pack->fix_mode), &(pack->fix_type),
                         &(pack->sat_prn[0]), &(pack->sat_prn[1]), &(pack->sat_prn[2]), &(pack->sat_prn[3]), &(pack->sat_prn[4]), &(pack->sat_prn[5]),
                         &(pack->sat_prn[6]), &(pack->sat_prn[7]), &(pack->sat_prn[8]), &(pack->sat_prn[9]), &(pack->sat_prn[10]), &(pack->sat_prn[11]),
                         &(pack->PDOP), &(pack->HDOP), &(pack->VDOP)))
    {
        nmea_error("GPGSA parse error!");
        return 0;
    }

    return 1;
}

/**
 * \brief Parse GSV packet from buffer.
 * @param buff a constant character pointer of packet buffer.
 * @param buff_sz buffer size.
 * @param pack a pointer of packet which will filled by function.
 * @return 1 (true) - if parsed successfully or 0 (false) - if fail.
 */
int nmea_parse_GPGSV(const char *buff, int buff_sz, nmeaGPGSV *pack)
{
    int nsen, nsat;

    NMEA_ASSERT(buff && pack);

    memset(pack, 0, sizeof(nmeaGPGSV));

    nmea_trace_buff(buff, buff_sz);

    if (buff[2] == 'L')
    {

        nsen = nmea_scanf(buff, buff_sz,
                          "$GLGSV,%d,%d,%d,"
                          "%d,%d,%d,%d,"
                          "%d,%d,%d,%d,"
                          "%d,%d,%d,%d,"
                          "%d,%d,%d,%d*",
                          &(pack->pack_count), &(pack->pack_index), &(pack->sat_count),
                          &(pack->sat_data[0].id), &(pack->sat_data[0].elv), &(pack->sat_data[0].azimuth), &(pack->sat_data[0].sig),
                          &(pack->sat_data[1].id), &(pack->sat_data[1].elv), &(pack->sat_data[1].azimuth), &(pack->sat_data[1].sig),
                          &(pack->sat_data[2].id), &(pack->sat_data[2].elv), &(pack->sat_data[2].azimuth), &(pack->sat_data[2].sig),
                          &(pack->sat_data[3].id), &(pack->sat_data[3].elv), &(pack->sat_data[3].azimuth), &(pack->sat_data[3].sig));

        nsat = (pack->pack_index - 1) * NMEA_SATINPACK;
        nsat = (nsat + NMEA_SATINPACK > pack->sat_count) ? pack->sat_count - nsat : NMEA_SATINPACK;
        nsat = nsat * 4 + 3 /* first three sentence`s */;

        if (nsen < nsat || nsen > (NMEA_SATINPACK * 4 + 3))
        {
            printf("GPGSV parse error!");
            return 0;
        }
#if 0		
		printf("GSV,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\r\n",
				(pack->pack_count), (pack->pack_index), (pack->sat_count),
				(pack->sat_data[0].id), (pack->sat_data[0].elv), (pack->sat_data[0].azimuth), (pack->sat_data[0].sig),
				(pack->sat_data[1].id), (pack->sat_data[1].elv), (pack->sat_data[1].azimuth), (pack->sat_data[1].sig),
				(pack->sat_data[2].id), (pack->sat_data[2].elv), (pack->sat_data[2].azimuth), (pack->sat_data[2].sig),
				(pack->sat_data[3].id), (pack->sat_data[3].elv), (pack->sat_data[3].azimuth), (pack->sat_data[3].sig));
#endif
    }
    else
    {
        nsen = nmea_scanf(buff, buff_sz,
                          "$GPGSV,%d,%d,%d,"
                          "%d,%d,%d,%d,"
                          "%d,%d,%d,%d,"
                          "%d,%d,%d,%d,"
                          "%d,%d,%d,%d*",
                          &(pack->pack_count), &(pack->pack_index), &(pack->sat_count),
                          &(pack->sat_data[0].id), &(pack->sat_data[0].elv), &(pack->sat_data[0].azimuth), &(pack->sat_data[0].sig),
                          &(pack->sat_data[1].id), &(pack->sat_data[1].elv), &(pack->sat_data[1].azimuth), &(pack->sat_data[1].sig),
                          &(pack->sat_data[2].id), &(pack->sat_data[2].elv), &(pack->sat_data[2].azimuth), &(pack->sat_data[2].sig),
                          &(pack->sat_data[3].id), &(pack->sat_data[3].elv), &(pack->sat_data[3].azimuth), &(pack->sat_data[3].sig));

        nsat = (pack->pack_index - 1) * NMEA_SATINPACK;
        nsat = (nsat + NMEA_SATINPACK > pack->sat_count) ? pack->sat_count - nsat : NMEA_SATINPACK;
        nsat = nsat * 4 + 3 /* first three sentence`s */;

        if (nsen < nsat || nsen > (NMEA_SATINPACK * 4 + 3))
        {
            nmea_error("GPGSV parse error!");
            return 0;
        }
#if 0
		printf("GSV,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\r\n",
				(pack->pack_count), (pack->pack_index), (pack->sat_count),
				(pack->sat_data[0].id), (pack->sat_data[0].elv), (pack->sat_data[0].azimuth), (pack->sat_data[0].sig),
				(pack->sat_data[1].id), (pack->sat_data[1].elv), (pack->sat_data[1].azimuth), (pack->sat_data[1].sig),
				(pack->sat_data[2].id), (pack->sat_data[2].elv), (pack->sat_data[2].azimuth), (pack->sat_data[2].sig),
				(pack->sat_data[3].id), (pack->sat_data[3].elv), (pack->sat_data[3].azimuth), (pack->sat_data[3].sig));
#endif
    }

    // printf(buff);

    return 1;
}

/**
 * \brief Parse RMC packet from buffer.
 * @param buff a constant character pointer of packet buffer.
 * @param buff_sz buffer size.
 * @param pack a pointer of packet which will filled by function.
 * @return 1 (true) - if parsed successfully or 0 (false) - if fail.
 */
int nmea_parse_GPRMC(const char *buff, int buff_sz, nmeaGPRMC *pack)
{
    int nsen;
    char time_buff[NMEA_TIMEPARSE_BUF] = {0};
    char time_buff2[NMEA_TIMEPARSE_BUF] = {0};

    NMEA_ASSERT(buff && pack);

    memset(pack, 0, sizeof(nmeaGPRMC));

    nmea_trace_buff(buff, buff_sz);
    //$GNRMC,,V,,,,,,,,,,N*4D
    if (buff[2] == 'N')
    {
        nsen = nmea_scanf(buff, buff_sz,
                          "$GNRMC,%s,%C,%f,%C,%f,%C,%f,%f,%s,%f,%C,%C*",
                          &(time_buff[0]),
                          &(pack->status), &(pack->lat), &(pack->ns), &(pack->lon), &(pack->ew),
                          &(pack->speed), &(pack->direction),
                          &time_buff2[0],
                          &(pack->declination), &(pack->declin_ew), &(pack->mode));

        if (nsen != 11 && nsen != 12)
        {
            printf("GPRMC parse error!");
            return 0;
        }
    }
    else
    {
        nsen = nmea_scanf(buff, buff_sz,
                          "$GPRMC,%s,%C,%f,%C,%f,%C,%f,%f,%s,%f,%C,%C*",
                          &(time_buff[0]),
                          &(pack->status), &(pack->lat), &(pack->ns), &(pack->lon), &(pack->ew),
                          &(pack->speed), &(pack->direction),
                          &time_buff2[0],
                          &(pack->declination), &(pack->declin_ew), &(pack->mode));

        if (nsen != 11 && nsen != 12)
        {
            printf("GPRMC parse error!");
            return 0;
        }
    }
    // pack->lat=(int)(pack->lat/100)+(pack->lat-(int)(pack->lat/100)*100)/60.0;
    // pack->lon=(int)(pack->lon/100)+(pack->lon-(int)(pack->lon/100)*100)/60.0;
    pack->lat *= 100000;
    pack->lon *= 100000;
    if (((int)strlen(&time_buff[0]) > 2) && 0 != _nmea_parse_time(&time_buff[0], (int)strlen(&time_buff[0]), &(pack->utc)))
    {
        printf("GPRMC time parse error!");
        return 0;
    }
    if (((int)strlen(&time_buff2[0]) > 2) && 0 != _nmea_parse_time2(&time_buff2[0], (int)strlen(&time_buff2[0]), &(pack->utc)))
    {
        printf("GPRMC time parse error!");
        return 0;
    }
    // printf(buff);
    return 1;
}
