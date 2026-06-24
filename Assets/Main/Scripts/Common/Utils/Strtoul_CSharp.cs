using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 这个代码从https://opensource.apple.com/source/Libc/Libc-166/stdlib.subproj/strtoul.c.auto.html
// 翻译而来
public class Strtoul_CSharp
{
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
    public static ulong strtoul(string str)
    {
        return strtoul(str.AsSpan());
    }

    /*
     * Convert a string to an unsigned long integer.
     *
     * Ignores `locale' stuff.  Assumes that the upper and lower case
     * alphabets and digits are each contiguous.
     */

    public static ulong strtoul(ReadOnlySpan<char> str)
    {
        // register const char *s = nptr;
        int base_ = 0;
        ulong acc;
        char c;
        ulong cutoff;
        int neg = 0, any, cutlim;
        int p = 0;

        /*
         * See strtol for comments as to the logic used.
         */
        do {
            c = CH(str, p++);
        } while (Char.IsWhiteSpace(c));
        if (c == '-') {
            neg = 1;
            c = CH(str, p++);
        } else if (c == '+') {
            c = CH(str, p++);
        }
        
        if ((base_ == 0 || base_ == 16) &&
            c == '0' && (CH(str, p) == 'x' || CH(str, p) == 'X'))
        {
            c = CH(str, p + 1);
            p += 2;
            base_ = 16;
        }
        if (base_ == 0)
            base_ = c == '0' ? 8 : 10;
        cutoff = (ulong)ulong.MaxValue / (ulong)base_;
        cutlim = (int)(ulong.MaxValue % (ulong)base_);
        for (acc = 0, any = 0;; c = CH(str, p++)) {
            if (char.IsDigit(c))
                c -= '0';
            else if (char.IsLetter(c))
                c = (char)(c - (char.IsUpper(c) ? 'A' - 10 : 'a' - 10));
            else
                break;
            if (c >= base_)
                break;
            if (any < 0 || acc > cutoff || acc == cutoff && c > cutlim)
                any = -1;
            else {
                any = 1;
                acc *= (ulong)base_;
                acc += c;
            }
        }
        if (any < 0) {
            acc = ulong.MaxValue;
            errno = -2;
        } 
        // else if (neg == 1)
        //     acc = -acc;
        // if (endptr != 0)
        //     *endptr = (char *)(any ? s - 1 : nptr);
        return (acc);
    }
}





