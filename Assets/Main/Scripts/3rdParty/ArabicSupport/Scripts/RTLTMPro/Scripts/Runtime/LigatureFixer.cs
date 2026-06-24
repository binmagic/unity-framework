using System.Collections.Generic;
using UnityEngine;

namespace RTLTMPro
{
    public static class LigatureFixer
    {
        // private static readonly List<int> LtrTextHolder = new List<int>(512);
        // private static readonly List<int> TagTextHolder = new List<int>(512);
        private static readonly Dictionary<char, char> MirroredCharsMap = new Dictionary<char, char>()
        {
            ['('] = ')',
            [')'] = '(',            
            ['['] = ']',
            [']'] = '[',             
            ['<'] = '>',
            ['>'] = '<', 
            // ['{'] = '}',
            // ['}'] = '{',
            // ['»'] = '«',
            // ['«'] = '»',
        };
        private static readonly HashSet<char> MirroredCharsSet = new HashSet<char>(MirroredCharsMap.Keys);
        private static void FlushBufferToOutput(List<int> buffer, FastStringBuilder output)
        {
            for (int j = 0; j < buffer.Count; j++)
            {
                output.Append(buffer[buffer.Count - 1 - j]);
            }

            buffer.Clear();
        }

        /// <summary>
        ///     Fixes the flow of the text.
        /// </summary>
        public static void Fix(FastStringBuilder input, FastStringBuilder output, bool farsi, bool fixTextTags, bool preserveNumbers)
        {
            // Some texts like tags, English words and numbers need to be displayed in their original order.
            // This list keeps the characters that their order should be reserved and streams reserved texts into final letters.
            List<int> LtrTextHolder = new List<int>(512);
            List<int> TagTextHolder = new List<int>(512);
            LtrTextHolder.Clear(); // 非阿语辅助栈
            TagTextHolder.Clear(); // 富文本组件
            
            if (Application.isEditor) // debug用
            {
                var charList = new char[input.Length];
                for (int i = input.Length - 1; i >= 0; i--)
                {
                    charList[i] = (char) input.Get(i);
                }

                var test = 0;
            }
            var lastIndex = input.Length - 1;
            for (int i = input.Length - 1; i >= 0; i--)
            {
                bool isInMiddle = i > 0 && i < input.Length - 1;
                bool isAtBeginning = i == 0;
                bool isAtEnd = i == input.Length - 1;

                int characterAtThisIndex = input.Get(i);
                char x = (char)characterAtThisIndex;

                int nextCharacter = default;
                if (!isAtEnd)
                    nextCharacter = input.Get(i + 1);

                int previousCharacter = default;
                if (!isAtBeginning)
                    previousCharacter = input.Get(i - 1);

                if (fixTextTags) // 富文本
                {
                    if (characterAtThisIndex == '>' && previousCharacter != '-') // 不要把两个tag内的箭头(->)包含在内
                    {
                        // We need to check if it is actually the beginning of a tag.
                        bool isValidTag = false;
                        bool isValidFirstTag = false;
                        int nextI = i;
                        TagTextHolder.Add(characterAtThisIndex);

                        for (int j = i - 1; j >= 0; j--)
                        {
                            var jChar = input.Get(j);
                            
                            TagTextHolder.Add(jChar);

                            if (jChar == '<')
                            {
                                var jPlus1Char = input.Get(j + 1);
                                // Tags do not start with space
                                if (jPlus1Char == ' ')
                                {
                                    break;
                                }                                
                                
                                if (jPlus1Char == '/')
                                {
                                    isValidFirstTag = true;
                                }
                                isValidTag = true;
                                nextI = j;
                                break;
                            }
                        }

                        if (isValidTag)
                        {
                            if (i == input.Length - 1)
                            {
                                lastIndex = nextI-1;
                            }
                            //FlushBufferToOutput(LtrTextHolder, output);
                            FlushBufferToOutput(TagTextHolder, output);
                            i = nextI;
                            if (isValidFirstTag)
                            {
                                i--;
                                FastStringBuilder input2 = new FastStringBuilder(RTLSupport.DefaultBufferSize);
                                FastStringBuilder output2 = new FastStringBuilder(RTLSupport.DefaultBufferSize);
                                var endFlag = false;
                                var nestCount = 0;
                                while (i >=0)
                                {
                                    if (input.Get(i) == '>') // 判断是否到真正对应的另一个tag
                                    {
                                        var j = i;
                                        while (j >= 0)
                                        {
                                            if (input.Get(j) == '<')
                                            {
                                                if (input.Get(j+1) != '/' && input.Get(j+1) != ' ')
                                                {
                                                    if (nestCount > 0)
                                                    {
                                                        nestCount--;
                                                    }
                                                    else
                                                    {
                                                        endFlag = true;
                                                    }
                                                }
                                                else //嵌套
                                                {
                                                    nestCount++;
                                                }
                                                break;
                                            }
                                            j--;
                                        }

                                        if (endFlag)
                                        {
                                            break;
                                        }
                                    }
                                    input2.Append(input.Get(i));
                                    i--;
                                }

                                input2.Reverse();
                                Fix(input2, output2, farsi, fixTextTags, preserveNumbers);
                                for(int j =0; j < output2.Length; ++j)
                                {
                                    output.Append(output2.Get(j));
                                }

                                i++;
                            }
                            continue;
                        } else
                        {
                            TagTextHolder.Clear();
                        }
                    }
                }
                char cur = (char)characterAtThisIndex;
                char pre = (char)previousCharacter;
                char next = (char)nextCharacter;
                //是否是标点符号
                if (Char32Utils.IsPunctuation(characterAtThisIndex) || Char32Utils.IsSymbol(characterAtThisIndex)) //标点和符号
                {
                    bool isMirror = MirroredCharsSet.Contains((char) characterAtThisIndex);
                    if (isMirror)
                    {
                        characterAtThisIndex = MirroredCharsMap[(char)characterAtThisIndex];
                    }
                    ///前面的字符是否是需要从右向左书写的文本
                    bool isAfterRTLCharacter = Char32Utils.IsRTLCharacter(previousCharacter);
                    //后面的字符是否是需要从右向左书写的文本
                    bool isBeforeRTLCharacter = Char32Utils.IsRTLCharacter(nextCharacter);
                    //前面的字符是否是数字
                    bool isAfterNum = Char32Utils.IsNumber(previousCharacter, preserveNumbers, farsi);
                    //后面的字符是否是数字
                    bool isBeforeNum = Char32Utils.IsNumber(nextCharacter, preserveNumbers, farsi);
                    //后面的字符是否是空格
                    bool isBeforeWhiteSpace = Char32Utils.IsWhiteSpace(nextCharacter);
                    //前面的字符是否是空格
                    bool isAfterWhiteSpace = Char32Utils.IsWhiteSpace(previousCharacter);
                    //当前是否是下划线
                    bool isUnderline = characterAtThisIndex == '_';
                    //特殊符号
                    bool isSpecialPunctuation = characterAtThisIndex == '.' ||
                                                characterAtThisIndex == '،' ||
                                                characterAtThisIndex == ':' ||
                                                characterAtThisIndex == '-';
                    //小数点
                    bool isRankNumberDot = characterAtThisIndex == '.' && isAfterNum;

                    bool isSpecialPunctuationDontInLtr = characterAtThisIndex == '"' ||
                                                         characterAtThisIndex == '%' ||
                                                         characterAtThisIndex == '،' ||
                                                         characterAtThisIndex == '؛' ||
                                                         characterAtThisIndex == '!' ;
                    //是否是计算符号
                    bool isCalculatePunctuation = characterAtThisIndex == '+' ||
                                                  characterAtThisIndex == '-' ||
                                                  characterAtThisIndex == '*' ||
                                                  characterAtThisIndex == '×' ||
                                                  characterAtThisIndex == '/';
                    //是否是右箭头
                    bool isTargetSymbolRight = characterAtThisIndex == '>' && previousCharacter == '-';
                    //是否是左箭头
                    bool isTargetSymbolLeft = characterAtThisIndex == '-' && previousCharacter == '<';
                    
                    if (isInMiddle) // 不在首尾位置
                    {
                        if (isBeforeNum && isAfterNum && Char32Utils.IsPunctuation(characterAtThisIndex) && !isMirror) // 价格
                        {
                            LtrTextHolder.Add(characterAtThisIndex);
                        }
                        else if (isTargetSymbolRight) // <-
                        {
                            i--;
                            output.Append('<');
                            output.Append('-');
                        }                        
                        else if (isTargetSymbolLeft) // ->
                        {
                            i--;
                            output.Append('-');
                            output.Append('>');
                        }
                        else if (isBeforeRTLCharacter && isAfterRTLCharacter ||
                                 isSpecialPunctuation ||
                                 isSpecialPunctuationDontInLtr ||
                                 isBeforeWhiteSpace && isAfterRTLCharacter ||
                                 isBeforeRTLCharacter && isAfterWhiteSpace ||
                                 (isBeforeRTLCharacter || isAfterRTLCharacter) && isUnderline ||
                                 isRankNumberDot ||
                                 isCalculatePunctuation 
                                 )
                        {
                            FlushBufferToOutput(LtrTextHolder, output);
                            output.Append(characterAtThisIndex);
                        } 
                        else if(!isMirror)
                        {
                            LtrTextHolder.Add(characterAtThisIndex);
                        }
                        else
                        {
                            FlushBufferToOutput(LtrTextHolder, output);
                            output.Append(characterAtThisIndex);
                        }
                    } 
                    else if (isAtEnd)
                    {
                        bool isSpecialEndPunctuation = characterAtThisIndex == '!' || 
                                                       characterAtThisIndex == '؛' ||
                                                       characterAtThisIndex == '%' ||
                                                       characterAtThisIndex == '.' ||
                                                       characterAtThisIndex == '"';
                        if (isMirror || isSpecialEndPunctuation)
                        {
                            FlushBufferToOutput(LtrTextHolder, output);
                            output.Append(characterAtThisIndex);
                        }
                        else
                        {
                            LtrTextHolder.Add(characterAtThisIndex);
                        }
                    } 
                    else if (isAtBeginning)
                    {
                        FlushBufferToOutput(LtrTextHolder, output);
                        output.Append(characterAtThisIndex);
                    }

                    continue;
                }

                if (isInMiddle) // 空格特判
                {
                    bool isAfterEnglishChar = Char32Utils.IsEnglishLetter(previousCharacter);
                    bool isBeforeEnglishChar = Char32Utils.IsEnglishLetter(nextCharacter);
                    bool isAfterNumber = Char32Utils.IsNumber(previousCharacter, preserveNumbers, farsi);
                    bool isBeforeNumber = Char32Utils.IsNumber(nextCharacter, preserveNumbers, farsi);
                    bool isAfterSymbol = Char32Utils.IsSymbol(previousCharacter);
                    bool isBeforeSymbol = Char32Utils.IsSymbol(nextCharacter);
                    bool isAfterPunctuation = Char32Utils.IsPunctuation(previousCharacter);
                    bool isBeforePunctuation = Char32Utils.IsPunctuation(nextCharacter);
                    bool isAfterWhiteSpace = previousCharacter == ' ';
                    bool isBeforeWhiteSpace = nextCharacter == ' ';
                    bool isAfterColon = previousCharacter == ':';
                    bool isSelfWhiteSpace = characterAtThisIndex == ' ' || characterAtThisIndex == 0x00A0; // 普通空格 与 不断行空格

                    // For cases where english words and farsi/arabic are mixed. This allows for using farsi/arabic, english and numbers in one sentence.
                    // If the space is between numbers,symbols or English words, keep the order
                    if (isSelfWhiteSpace && isAfterColon && !isBeforeWhiteSpace) // 冒号后面的空格不跟LTR
                    {
                        FlushBufferToOutput(LtrTextHolder, output);
                        output.Append(characterAtThisIndex);
                    }
                    else if (isSelfWhiteSpace && 
                        (isBeforeEnglishChar || isBeforeNumber || isBeforeSymbol || isBeforePunctuation || isBeforeWhiteSpace) &&
                        (isAfterEnglishChar || isAfterNumber || isAfterSymbol || isAfterPunctuation || isAfterWhiteSpace))
                    {
                        LtrTextHolder.Add(characterAtThisIndex);
                        continue;
                    }
                } 
                //如果是字母同时不是从右往左的字符,或者是数字
                if (Char32Utils.IsLetter(characterAtThisIndex) && !Char32Utils.IsRTLCharacter(characterAtThisIndex)||
                    Char32Utils.IsNumber(characterAtThisIndex, preserveNumbers, farsi)) // 数字和英文字符
                {
                    LtrTextHolder.Add(characterAtThisIndex);
                    continue;
                }

                // handle surrogates
                if (characterAtThisIndex >= (char)0xD800 &&
                    characterAtThisIndex <= (char)0xDBFF ||
                    characterAtThisIndex >= (char)0xDC00 && characterAtThisIndex <= (char)0xDFFF)
                {
                    LtrTextHolder.Add(characterAtThisIndex);
                    continue;
                }

                FlushBufferToOutput(LtrTextHolder, output); // 出栈

                if (characterAtThisIndex != 0xFFFF &&
                    characterAtThisIndex != (int)SpecialCharacters.ZeroWidthNoJoiner)
                {
                    output.Append(characterAtThisIndex); //阿语
                }
                for (int k = 0; k < output.Length; ++k)
                {
                    char x1 = (char)output.Get(k);
                    int xx = 1;
                }
            }

            FlushBufferToOutput(LtrTextHolder, output);
        }
    }
}





