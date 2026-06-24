using System;
using System.Text;
using LuaAPI = XLua.LuaDLL.Lua;

// 字符串格式化的C#翻译
// 此类从lua的堆栈上获取可变参数，然后进行C格式化。主要是简单优化一下lua和C#通讯字符串带来的GC。
// 这里写个简单的C#处理吧。支持部分控制长度字符的，全支持的话处理的就会比较复杂，意义也不大。
// 不支持qualifier
// %@ 表示是一个loopup的id
// %# 表示是一个dialog的id
// %s 字符串
// %d 数字
// %f 浮点数
// *** 最终注意事项，此类仅适用于lua中大量频繁的格式化字符串给C#的时候。
// 或者适用于固定格式的处理，譬如"name_" .. number 这种简单的两端式，除此之外不要使用。

public class StringFormat
{
	const int ZEROPAD = 1;		/* pad with zero 填补0*/
	const int SIGN = 2;		/* unsigned/signed long */
	const int PLUS = 4;		/* show plus 显示+*/
	const int SPACE = 8;		/* space if plus 加上空格*/
	const int LEFT = 16;		/* left justified 左对齐*/
	const int SPECIAL = 32;		/* 0x /0*/
	const int LARGE = 64;		/* 用 'ABCDEF'/'abcdef' */
	
	//获得字段转化为整数，例如%12d中的字母12提出来变成整型12.
	int skip_atoi(string fmt, ref int startpos)
	{
		int i, c;

		for (i = 0; '0' <= (c = CH(fmt, startpos)) && c <= '9'; ++startpos)
			i = i*10 + c - '0';
		return i;
	}

	// 因为我们不考虑多线程，这里就使用
	static private StringBuilder _sb = new StringBuilder(160);
	static private char[] _chBuffer = new char[80];
	static private char[] _cvtbuf = new char[80];
	static private char[] _temp = new char[80];
	
	// 返回参数的值
	private int cur_arg = 0;
	private object[] var;

	long va_arg_long()
	{
		IntPtr L = GameEntry.Lua.Env.L;
		int this_arg = cur_arg++;
		
		if (LuaAPI.lua_isinteger(L, this_arg))
		{
			long n = LuaAPI.xlua_tointeger(L, this_arg);
			return n;
		}

		return 0;
	}

	double va_arg_double()
	{
		IntPtr L = GameEntry.Lua.Env.L;
		int this_arg = cur_arg++;
		
		if (LuaAPI.lua_isnumber(L, this_arg))
		{
			double n = LuaAPI.lua_tonumber(L, this_arg);
			return n;
		}

		return 0;
	}
	
	char va_arg_char()
	{
		int n = (int)va_arg_long();
		return (char) n;
	}
	
	string va_arg_string()
	{
		IntPtr L = GameEntry.Lua.Env.L;
		int this_arg = cur_arg++;
		
		string s = LuaAPI.lua_tostring(L, this_arg);
		return s;
	}
	
	string va_arg_local()
	{
		IntPtr L = GameEntry.Lua.Env.L;
		int this_arg = cur_arg++;

		string s;
		if (LuaAPI.lua_isinteger(L, this_arg))
		{
			int n = LuaAPI.xlua_tointeger(L, this_arg);
			s = GameEntry.Localization.GetString(n);
		}
		else
		{
			s = "";
		}

		return s;
	}

	string va_arg_cache()
	{
		IntPtr L = GameEntry.Lua.Env.L;
		int this_arg = cur_arg++;

		string s;
		if (LuaAPI.lua_isinteger(L, this_arg))
		{
			int n = LuaAPI.xlua_tointeger(L, this_arg);
			s = LuaStringLookupTable.Get(n);
		}
		else
		{
			s = "";
		}

		return s;
	}
	
	// T va_arg<T>(char ch)
	// {
	// 	IntPtr L = GameEntry.Lua.Env.L;
	//
	// 	// top上至少有2个参数，即obj和dialogId
	// 	int gen_param_count = LuaAPI.lua_gettop(L);
	// 	
	// 	if (ch == 'l')
	// 	{
	// 		return (T)LuaAPI.xlua_tointeger(L, cur_arg);
	// 	}
	// 	else if (LuaAPI.lua_isnumber(L, index))
	// 	{
	// 		arrParam[i] = LuaAPI.lua_tonumber(L, cur_arg);
	// 	}
	// 	else
	// 	{
	// 		arrParam[i] = LuaAPI.lua_tostring(L, cur_arg);
	// 	}
	// 	
	//
	// 	// Type t = typeof(T);
	// 	// int i = cur_arg;
	// 	// cur_arg++;
	// 	//
	// 	// if (t == typeof(string))
	// 	// {
	// 	// 	return (T)var[i];	
	// 	// }
	// 	//
	// 	// if (t == typeof(long))
	// 	// {
	// 	// 	return (T)(object)Convert.ToInt64((int)var[i]);
	// 	// }
	// 	//
	// 	// if (t == typeof(double))
	// 	// {
	// 	// 	return (T)(object)Convert.ToDouble((float)var[i]);
	// 	// }
	// 	//
	// 	// return (T)var[i];
	// 	// // IntPtr L = GameEntry.Lua.Env.L;
	// 	// // var translator = GameEntry.Lua.Env.translator;
	// 	// //
	// 	// // T ret;
	// 	// // translator.Get<T>(L, cur_arg, out ret);
	// 	// // return ret;
	// }
	
	// 代表了*fmt
    static char CH(string fmt, int i)
    {
    	if (i >= 0 && i < fmt.Length)
    	{
    		return fmt[i];
    	}

    	return (char)0;
    }
    
    char Append(char t)
    {
    	_sb.Append(t);
    	return t;
    }

    string Append(string t)
    {
	    _sb.Append(t);
	    return t;
    }

    //进制之间的相应转换
	int do_div(ref long n, int base_i)
	{
		int __base = (base_i);
		int __rem;
		
		__rem = (int)((n) % __base); //对应的base进制位
		(n) = (n) / __base;

		return __rem;
	}
	
	//统计字符串中字符个数(不包括\0)，如果个数大于count，则返回count，否则返回字符个数
	int strnlen(string s, int count)//size_t是unsigned long long的宏
	{
		int t = s.Length;
		if (count < t)
		{
			return t;
		}

		return count;
	}

	
	private const double DOUBLE_ZERO = 1E-307;

	static bool IS_DOUBLE_ZERO(double D)
	{
		return D <= DOUBLE_ZERO && D >= -DOUBLE_ZERO;
	}
	
	static int itoa(int n, char[] chBuffer, int start)
	{
		int i = 1;
		int pch = start;
		
		while ((n / i) != 0) i *= 10;

		if (n < 0)
		{
			n = -n;
			chBuffer[pch++] = '-';
		}
		if (0 == n) i = 10;

		while ((i /= 10) != 0)
		{
			chBuffer[pch++] = (char)((n / i) + (int)'0');
			n %= i;
		}
		chBuffer[pch] = '\0';
		return pch - start;
	}
	
	static int strlen(char[] str, int start)
	{
		int c = 0;
		for (int i = start; i < str.Length; ++i)
		{
			if (str[i] == '\0')
				break;
			++c;
		}

		return c;
	}
	
	private const int MAX_DIGITS = 15;
	static int ftoa(double dValue, char[] chBuffer)
	{
		int pch = 0;
		if (!IS_DOUBLE_ZERO(dValue))
		{
			double dRound = 5;
			if (dValue < 0)
			{
				chBuffer[pch++] = '-';
				dValue = -dValue;
			}
			else
			{
				chBuffer[pch++] = '+';
			}
			itoa((int)dValue, chBuffer, pch);
			int ucLen = strlen(chBuffer, pch);
			pch += ucLen;
			chBuffer[pch++] = '.';
			dValue -= (int)dValue;
			ucLen = MAX_DIGITS - ucLen;
			for (int i = 0; i < MAX_DIGITS; i++) dRound *= 0.1;

			for (int i = 0; i < ucLen; i++)
			{
				dValue = (dValue + dRound) * 10;
				itoa((int)dValue, chBuffer, pch);
				pch += strlen(chBuffer, pch);
				dValue -= (int)dValue;
			}
		}
		else
		{
			chBuffer[pch++] = '0';
			chBuffer[pch] = '\0';
		}

		return pch;
	}

	int strchr(char[] buffer, int chLen, char c)
	{
		for (int i = 0; i < chLen; ++i)
		{
			if (buffer[i] == c)
				return i;
		}

		return chLen;
	}

	// 因为要4舍5入。这里通过字符串来处理精度。
	void __ecvround(char[] numbuf, int last_digit, char after_last, ref int decpt)
	{
		/* Do we have at all to round the last digit?  */
		if (after_last > '4')
		{
			int p = last_digit;
			int carry = 1;

			/* Propagate the rounding through trailing '9' digits.  */
			do
			{
				int sum = numbuf[p] + carry;
				carry = (sum > '9') ? 1 : 0;
				numbuf[p--] = (char)(sum - carry * 10);
			} while (carry != 0 && p >= 0);

			/* We have 9999999... which needs to be rounded to 100000..  */
			if (carry != 0 && p == 0)
			{
				numbuf[p] = '1';
				decpt += 1;
			}
		}
	}
	
	char[] fcvtbuf(double value, int ndigits, ref int decpt, ref int sign, char[] buf)
	{
		//string INFINITY = "Infinity";
		char _decimal = '.';

		char[] chBuffer = _chBuffer;//new char[100];
		int pos = 0;
		int chLen = ftoa(value, chBuffer);

		sign = ('-' == chBuffer[0]) ? 1 : 0; /* The sign.  */
		
		/* Where's the decimal point?  */
		decpt = strchr(chBuffer, chLen, _decimal);
		decpt--; // 跳过符号位
		
		//
		// /* SunOS docs says if NDIGITS is 8 or more, produce "Infinity"   instead of "Inf".  */
		// if (strncmp(s, "Inf", 3) == 0)
		// {
		// 	memcpy(buf, sINFINITY, ndigits >= 8 ? 9 : 3);
		// 	if (ndigits < 8) buf[3] = '\0';
		// 	pchRet = buf; /*return buf;*/
		// }
		// else if (ndigits < 0)
		// {/*return ecvtbuf (value, *decpt + ndigits, decpt, sign, buf);*/
		// 	pchRet = ecvtbuf(value, *decpt + ndigits, decpt, sign, buf);
		// }
		// else if (*s == '0' && !IS_DOUBLE_ZERO(value)/*value != 0.0*/)
		// {/*return ecvtbuf (value, ndigits, decpt, sign, buf);*/
		// 	pchRet = ecvtbuf(value, ndigits, decpt, sign, buf);
		// }
		// else
		// {
			// 这个代码中的flag，指的是跳过了符号位，计算的时候要跳过
			int flag = 1;
			Array.Copy(chBuffer, flag, buf, 0, decpt);
			if (chBuffer[flag + decpt] == _decimal)
			{
				Array.Copy(chBuffer,flag + decpt + 1,buf, decpt,  ndigits);
				buf[decpt + ndigits] = '\0';
			}
			else
			{
				buf[decpt] = '\0';
			}
			__ecvround(buf, decpt + ndigits - 1, 
				chBuffer[flag + decpt + ndigits + 1], ref decpt);

		// }

		return buf;
	}
	
	void cfltcvt(double value, char[] buffer, char fmt, int precision)
	{
		int decpt = 0;
		int sign = 0;
		char[] cvtbuf = _cvtbuf;//new char[80];
		int capexp = 0;
		int app_i = 0;
		
		// if ('G' == fmt || 'E' == fmt)
		// {
		// 	capexp = 1;
		// 	//fmt += 'a' - 'A';
		// }

		// if (fmt == 'g')
		// {
		// 	char * digits = ecvtbuf(value, precision, &decpt, &sign, cvtbuf);
		// 	int magnitude = decpt - 1;
		// 	if (magnitude < -4 || magnitude > precision - 1)
		// 	{
		// 		fmt = 'e';
		// 		precision -= 1;
		// 	}
		// 	else
		// 	{
		// 		fmt = 'f';
		// 		precision -= decpt;
		// 	}
		// }
		//
		// if ('e' == fmt)
		// {
		// 	char * digits = ecvtbuf(value, precision + 1, &decpt, &sign, cvtbuf);
		// 	int exp = 0;
		// 	if (sign) *buffer++ = '-';
		// 	*buffer++ = *digits;
		// 	if (precision > 0) *buffer++ = '.';
		// 	memcpy(buffer, digits + 1, precision);
		// 	buffer += precision;
		// 	*buffer++ = capexp ? 'E' : 'e';
		//
		// 	if (decpt == 0)
		// 	{
		// 		exp = (IS_DOUBLE_ZERO(value)) ? 0 : -1; /*       if (value == 0.0)*/
		// 	}
		// 	else
		// 	{
		// 		exp = decpt - 1;
		// 	}
		//
		// 	if (exp < 0)
		// 	{
		// 		*buffer++ = '-';
		// 		exp = -exp;
		// 	}
		// 	else
		// 	{
		// 		*buffer++ = '+';
		// 	}
		//
		// 	buffer[2] = (exp % 10) + '0';
		// 	exp /= 10;
		// 	buffer[1] = (exp % 10) + '0';
		// 	exp /= 10;
		// 	buffer[0] = (exp % 10) + '0';
		// 	buffer += 3;
		// }
		// else if ('f' == fmt)
		{
			char[] digits = fcvtbuf(value, precision, ref decpt, ref sign, cvtbuf);
			int digits_i = 0;

			if (sign != 0) buffer[app_i++] = '-';
			if (digits[digits_i] != 0)
			{
				// 小数点位置
				if (decpt <= 0)
				{
					buffer[app_i++] = '0';
					buffer[app_i++] = '.';
					for (int pos = 0; pos < -decpt; pos++)
					{
						buffer[app_i++] = '0';
					}

					while (digits[digits_i] != 0) buffer[app_i++] = (digits[digits_i++]);
				}
				else
				{
					int pos = 0;
					while (digits[digits_i] != 0)
					{
						if (pos++ == decpt) buffer[app_i++] = '.';
						buffer[app_i++] = digits[digits_i++];
					}
				}
			}
			else
			{
				buffer[app_i++] = '0';
				if (precision > 0)
				{
					buffer[app_i++] = '.';
					for (int pos = 0; pos < precision; pos++)
					{
						buffer[app_i++] = '0';
					}
				}
			}
		}

		buffer[app_i] = '\0';
	}

	//以特定的进制格式化输出字符
	int number(long num, int base_i, int size, int precision, int type)
	{
		char c, sign;
		string digits="0123456789abcdefghijklmnopqrstuvwxyz";
		int i;
		char[] tmp = _temp;//new char[66];

		if ((type & LARGE) != 0)//输出大写字符，例如十六进制0XFF112233AA
			digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		if ((type & LEFT) != 0)//如果有'-'，如果出现了左对齐，就取消前面补0
			type &= ~ZEROPAD;
		if (base_i < 2 || base_i > 36)
			return 0;
		c = ((type & ZEROPAD) != 0) ? '0' : ' ';//如果标志符有0则补0，否则补空格；例如%02d
		sign = '\0';//符号
	
		if ((type & SIGN) != 0) //有符号与无符号的转换
		{
			if ((ulong)num < 0) 
			{
				sign = '-';
				num = -num;//取正值
				size--;//字段宽度减1
			} else if ((type & PLUS) != 0) //显示+
			{
				sign = '+';
				size--;
			} else if ((type & SPACE) != 0)//填补空格
			{
				sign = ' ';
				size--;
			}
		}
	
		//处理十六进制字宽问题
		if ((type & SPECIAL) != 0) //十六进制显示
		{
			if (base_i == 16)
				size -= 2;//0x
			else if (base_i == 8)
				size--;//0
		}
	
		i = 0;
		if (num == 0)//如果参数为0，则记录字符0
			tmp[i++]='0'; //tmp中的内容会放到缓冲区中
		else while (num != 0) //循环,num /= base
		{
			tmp[i++] = digits[(int)do_div(ref num, base_i)];//将进制转换,低地址先进tmp？
		}
		//地址长度大于精度，直接按地址长度输出，如果精度大于地址位数，先补空格
		//例如：printf("%18p\n",&a);-->空格空格00000000FAF27284
		if (i > precision)
			precision = i;
		size -= precision;
		if (!(Convert.ToBoolean(type&(ZEROPAD+LEFT))))//没有'-'和补0,直接补空格
			while(size-->0)
				Append(' ');
		if (sign != 0)//如果有符号，输出符号，符号包括：'-','+','',0
			Append(sign);
    
		if ((type & SPECIAL) != 0) //输出8进制或16进制符号0或0x
		{
			if (base_i == 8)
				Append('0');
			else if (base_i == 16)
			{
				Append('0');
				Append(digits[33]); //x或X
			}
		}
    
		if (!(Convert.ToBoolean(type & LEFT)))//没有-
			while (size-- > 0)
				Append(c);//c为0或空格
		while (i < precision--)//i为转换后存在tmp中字符的个数
			Append('0');
		while (i-- > 0)
			Append(tmp[i]);//tmp中存储着转换了的参数
		while (size-- > 0)
			Append(' ');
		
		return 0;
	}

	int float_number(double num, char fmt2, int base_i, int size, int precision, int flags)
	{
		char[] tmp = _temp;//new char[80];
		char c, sign;
		int n, i;

		/* Left align means no zero padding */
		if ((flags & LEFT) != 0) flags &= ~ZEROPAD;

		/* Determine padding and sign char */
		c = ((flags & ZEROPAD) != 0) ? '0' : ' ';
		sign = '\0';
		if ((flags & SIGN) != 0)
		{
			if (num < 0.0)
			{
				sign = '-';
				num = -num;
				size--;
			}
			else if ((flags & PLUS) != 0)
			{
				sign = '+';
				size--;
			}
			else if ((flags & SPACE) != 0)
			{
				sign = ' ';
				size--;
			}
		}

		/* Compute the precision value */
		if (precision < 0)
		{
			precision = 6; /* Default precision: 6 */
		}
		else if (precision == 0 && fmt2 == 'g')
		{
			precision = 1; /* ANSI specified */
		}
		/* Convert floating point number to text */
		cfltcvt(num, tmp, fmt2, precision);

		// /* '#' and precision == 0 means force a decimal point */
		// if ((flags & SPECIAL) && precision == 0) forcdecpt(tmp);
		//
		// /* 'g' format means crop zero unless '#' given */
		// if (fmt == 'g' && !(flags & SPECIAL)) cropzeros(tmp);

		n = strlen(tmp, 0);

		/* Output number with alignment and padding */
		size -= n;
		if (!(Convert.ToBoolean(flags & (ZEROPAD | LEFT))))
		{
			while (size-- > 0) Append(' ');
		}
		if (sign != 0) Append(sign);
		
		if (!(Convert.ToBoolean(flags & LEFT)))
		{
			while (size-- > 0) Append(c);
		}
		for (i = 0; i < n; i++)
		{
			Append(tmp[i]);
		}
		
		while (size-- > 0) Append(' ');
		
		return 0;
	}
	

	public string vsprintf(string fmt)
    {
	    int len;
	    long num;
	    int i, base_i;

        int flags;		/* 用在number()函数的标志 */
        int field_width;	/* 输出字段的宽度 */
	    int precision; //精度；用在浮点数时表示输出小数点后几位；用在字符串时表示输出字符个数

	    // 清除一下缓冲
	    _sb.Clear();
	    cur_arg = 2;
	    Array.Clear(_chBuffer, 0, _chBuffer.Length);
	    Array.Clear(_cvtbuf, 0, _cvtbuf.Length);
	    Array.Clear(_temp, 0, _temp.Length);
	    

	    for (int fmt_i = 0; fmt_i<fmt.Length; ++fmt_i) 
        {
		    if (CH(fmt, fmt_i) != '%') 
            {
                Append(CH(fmt, fmt_i));
			    continue;
		    }
            
		    //遇到%后执行下面代码
		    flags = 0;
		    repeat:
			    ++fmt_i;				//跳过第一个 '%'
			    switch (CH(fmt, fmt_i)) 
                {		
				    case '-': flags |= LEFT; goto repeat;//flags=10000(二进制，下面一样)
				    case '+': flags |= PLUS; goto repeat;//flags=100
				    case ' ': flags |= SPACE; goto repeat;//flags=1000
				    case '#': flags |= SPECIAL; goto repeat;//flags=10 0000
				    case '0': flags |= ZEROPAD; goto repeat;//flags=1
			    }
                
		    //对字段宽度的处理
		    field_width = -1;
		    if ('0' <= CH(fmt, fmt_i) && CH(fmt, fmt_i) <= '9')
			    field_width = skip_atoi(fmt, ref fmt_i);  //得到字段宽度

		    // 获取精度 
		    precision = -1;
		    if (CH(fmt, fmt_i) == '.') 
            {
			    ++fmt_i;
			    if ('0' <= CH(fmt, fmt_i) && CH(fmt, fmt_i) <= '9')
				    precision = skip_atoi(fmt, ref fmt_i);//获得精度

			    if (precision < 0)//精度不能小于0
				    precision = 0;
		    }

		    base_i = 10;//默认十进制
		    //对c、s、p、n、%、o等做处理
		    char ch1 = CH(fmt, fmt_i); 
		    switch (ch1) 
            {
	            case '@':
		            string str1 = va_arg_cache();
		            Append(str1);
		            continue;
	            case '#':
		            string str2 = va_arg_local();
		            Append(str2);
		            continue;
	            
	            //转换格式符为%c
		    case 'c':
	                //如果没有有‘-’，先输出字宽-1个空格再输出字符
			    if (!(Convert.ToBoolean(flags & LEFT)))//如果没有'-'标记符
				    while (--field_width > 0)
					    Append(' ');

	                /*获取字符参数时是先以int类型获取再强转为unsigned char，
	                    为了获取过程中保证精度不丢失。*/
					char cc = va_arg_char();
	                Append(cc);
	                
	            // 如果有'-'，先输出字符再填补空格,注意是先--的，所以实际空格会比输入的字段少1，在加					上参数就刚好够宽度；比如printf("%5d",2);输出：空格空格空格空格2。
	                while (--field_width > 0)
		                Append(' ');
				    //*str++ = ' ';
			    continue;
	    
		    // 这个尽量不要走到，如果频繁走到，就不如去lua中直接格式化字符串再传给C#了。  
		    case 's':
			    string ss = va_arg_string();//char*格式获取参数
			    if (ss == null)                  //如果字符串不存在，则返回(NULL)
				   ss = "<NULL>";
                    
	            /*如果字符串中字符个数大于精度，len为精度；
	            否则len为字符个数,即精度表示了字符串输出字符的个数*/
			    len = strnlen(ss, precision);
	    
	             //处理'-',即printf("%-s","hello");
			    if (!(Convert.ToBoolean(flags & LEFT)))
				    while (len < field_width--)
					    Append(' ');
			    
			    for (i = 0; i < len; ++i)
				    Append(ss[i]);
				    //*str++ = *s++;
			    
			    while (len < field_width--)
				    Append(' ');
			    continue;

		    case '%':
			    Append('%');
			    continue;
	    
		    /* integer number formats - set up the flags and "break" */
		    case 'o':
			    base_i = 8;
			    break;
	    
		    case 'X':
			    flags |= LARGE;//小写转大写
			    base_i = 16;
			    break;
		    case 'x':  //十六进制
			    base_i = 16;
			    break;
	    
		    case 'd':	//十进制
		    case 'i':
			    flags |= SIGN;
			    break;
		    case 'u':	//无符号
			    break;
		    
		    // 浮点数的处理比较复杂，先简单处理一下
		    case 'f':
			    double n = va_arg_double();
			    char fmt2 = CH(fmt, fmt_i);
			    float_number(n, fmt2, base_i, field_width, precision, flags | SIGN);
			    continue;

		    default:	// 这种情况表示%后面是个正常的字符
			    Append('%');
			    if (fmt_i < fmt.Length)
				    Append(CH(fmt, fmt_i));
			    else
				    fmt_i--;
			    continue;
            }
		    
	        num = va_arg_long();
			    // if ((flags & SIGN) != 0)
				   //  num = (int)Convert.ToInt32(n);
				   
		    number(num, base_i, field_width, precision, flags);
	    }

	    string sssss = _sb.ToString();
	    return sssss;
    }
}





