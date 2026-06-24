using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 这个代码从https://opensource.apple.com/source/tcl/tcl-10/tcl/compat/strtod.c
// 翻译而来
public class Strtod_CSharp
{
	static int maxExponent = 511;   /* Largest possible base 10 exponent.  Any
					 * exponent larger than this will already
					 * produce underflow or overflow, so there's
					 * no need to worry about additional digits.
					 */
	static double[] powersOf10 = new double[] {	/* Table giving binary powers of 10.  Entry */
		10.0,			/* is 10^2^i.  Used to convert decimal */
		100.0,			/* exponents into floating-point numbers. */
		1.0e4,
		1.0e8,
		1.0e16,
		1.0e32,
		1.0e64,
		1.0e128,
		1.0e256
	};

    public static int errno = 0;

    // 用来模仿c中的*p
	public static char CH(ReadOnlySpan<char> buffer, int p)
	{
		if (p >= 0 && p < buffer.Length)
        {
			return buffer[p];
        }

		return '\0';
	}

    // 这个效率理论上比string.ToSingle更高
    // 最好能持续完善
    public static double strtod(string str)
    {
        return strtod(str.AsSpan());
    }

    /*
	 *----------------------------------------------------------------------
	 *
	 * strtod --
	 *
	 *	This procedure converts a floating-point number from an ASCII
	 *	decimal representation to internal double-precision format.
	 *
	 * Results:
	 *	The return value is the double-precision floating-point
	 *	representation of the characters in string.  If endPtr isn't
	 *	NULL, then *endPtr is filled in with the address of the
	 *	next character after the last one that was part of the
	 *	floating-point number.
	 *
	 * Side effects:
	 *	None.
	 *
	 *----------------------------------------------------------------------
	 */

    public static double strtod(ReadOnlySpan<char> str)
    {
        int sign, expSign = 0;
        double fraction, dblExp;//, *d;
                                //CONST char* p;
        char c;
        int exp = 0;        /* Exponent read from "EX" field. */
        int fracExp = 0;        /* Exponent that derives from the fractional
				 * part.  Under normal circumstatnces, it is
				 * the negative of the number of digits in F.
				 * However, if I is very long, the last digits
				 * of I get dropped (otherwise a long I with a
				 * large negative exponent could cause an
				 * unnecessary overflow on I alone).  In this
				 * case, fracExp is incremented one for each
				 * dropped digit. */
        int mantSize;       /* Number of digits in mantissa. */
        int decPt;          /* Number of mantissa digits BEFORE decimal
				 * point. */
        int pExp;       /* Temporarily holds location of exponent
				 * in string. */

        /*
         * Strip off leading blanks and check for a sign.
         */

        //p = string;
        int p = 0;
        while (char.IsWhiteSpace(CH(str, p)))
        {
            p += 1;
        }
        if (CH(str, p) == '-')
        {
            sign = 1;
            p += 1;
        }
        else
        {
            if (CH(str, p) == '+')
            {
                p += 1;
            }
            sign = 0;
        }

        /*
         * Count the number of digits in the mantissa (including the decimal
         * point), and also locate the decimal point.
         */

        decPt = -1;
        for (mantSize = 0; ; mantSize += 1)
        {
            c = CH(str, p);
            if (!char.IsDigit(c))
            {
                if ((c != '.') || (decPt >= 0))
                {
                    break;
                }
                decPt = mantSize;
            }
            p += 1;
        }

        /*
         * Now suck up the digits in the mantissa.  Use two integers to
         * collect 9 digits each (this is faster than using floating-point).
         * If the mantissa has more than 18 digits, ignore the extras, since
         * they can't affect the value anyway.
         */

        pExp = p;
        p -= mantSize;
        if (decPt < 0)
        {
            decPt = mantSize;
        }
        else
        {
            mantSize -= 1;          /* One of the digits was the point. */
        }
        if (mantSize > 18)
        {
            fracExp = decPt - 18;
            mantSize = 18;
        }
        else
        {
            fracExp = decPt - mantSize;
        }
        if (mantSize == 0)
        {
            fraction = 0.0;
            p = 0;
            goto done;
        }
        else
        {
            int frac1, frac2;
            frac1 = 0;
            for (; mantSize > 9; mantSize -= 1)
            {
                c = CH(str, p);
                p += 1;
                if (c == '.')
                {
                    c = CH(str, p);
                    p += 1;
                }
                frac1 = 10 * frac1 + (c - '0');
            }
            frac2 = 0;
            for (; mantSize > 0; mantSize -= 1)
            {
                c = CH(str, p);
                p += 1;
                if (c == '.')
                {
                    c = CH(str, p);
                    p += 1;
                }
                frac2 = 10 * frac2 + (c - '0');
            }
            fraction = (1.0e9 * frac1) + frac2;
        }

        /*
         * Skim off the exponent.
         */

        p = pExp;
        if ((CH(str, p) == 'E') || (CH(str, p) == 'e'))
        {
            p += 1;
            if (CH(str, p) == '-')
            {
                expSign = 1;
                p += 1;
            }
            else
            {
                if (CH(str, p) == '+')
                {
                    p += 1;
                }
                expSign = 0;
            }
            if (!char.IsDigit(CH(str, p)))
            {
                p = pExp;
                goto done;
            }
            while (char.IsDigit(CH(str, p)))
            {
                exp = exp * 10 + (CH(str, p) - '0');
                p += 1;
            }
        }
        if (Convert.ToBoolean(expSign))
        {
            exp = fracExp - exp;
        }
        else
        {
            exp = fracExp + exp;
        }

        /*
         * Generate a floating-point number that represents the exponent.
         * Do this by processing the exponent one bit at a time to combine
         * many powers of 2 of 10. Then combine the exponent with the
         * fraction.
         */

        if (exp < 0)
        {
            expSign = 1;
            exp = -exp;
        }
        else
        {
            expSign = 0;
        }
        if (exp > maxExponent)
        {
            exp = maxExponent;
            errno = -1;
        }
        dblExp = 1.0;
        for (int d = 0; exp != 0; exp >>= 1, d += 1)
        {
            if (Convert.ToBoolean(exp & 01))
            {
                dblExp *= powersOf10[d];
            }

            if (d >= powersOf10.Length)
            {
                errno = -2;
                break;
            }            
        }
        if (Convert.ToBoolean(expSign))
        {
            fraction /= dblExp;
        }
        else
        {
            fraction *= dblExp;
        }

    done:
        //if (endPtr != NULL)
        //{
        //	*endPtr = (char*)p;
        //}

        if (Convert.ToBoolean(sign))
        {
            return -fraction;
        }
        return fraction;
    }
}





