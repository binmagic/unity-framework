// ReSharper disable IdentifierTypo
// ReSharper disable CommentTypo

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace RTLTMPro
{
    public class UGUITextLines
    {
        public int startIndex { set; get; }
        public int endIndex { set; get; }
        
    }
    public static class RTLSupport
    {
        public const int DefaultBufferSize = 2048;

        private static FastStringBuilder inputBuilder;
        private static FastStringBuilder glyphFixerOutput;

        static RTLSupport()
        {
            inputBuilder = new FastStringBuilder(DefaultBufferSize);
            glyphFixerOutput = new FastStringBuilder(DefaultBufferSize);
        }

        /// <summary>
        ///     Fixes the provided string
        /// </summary>
        /// <param name="input">Text to fix</param>
        /// <param name="output">Fixed text</param>
        /// <param name="fixTextTags"></param>
        /// <param name="preserveNumbers"></param>
        /// <param name="farsi"></param>
        /// <returns>Fixed text</returns>
        public static void FixRTL(
            string input,
            FastStringBuilder output,
            bool farsi = true,
            bool fixTextTags = true,
            bool preserveNumbers = false)
        {
            inputBuilder.SetValue(input);
            TashkeelFixer.RemoveTashkeel(inputBuilder);
            // The shape of the letters in shapeFixedLetters is fixed according to their position in word. But the flow of the text is not fixed.
            GlyphFixer.Fix(inputBuilder, glyphFixerOutput, preserveNumbers, farsi, fixTextTags); //处理阿拉伯文本中的特殊字符和格式，包括字符的转换、特殊字符的处理、数字的处理
            //Restore tashkeel to their places.
            TashkeelFixer.RestoreTashkeel(glyphFixerOutput);
            
            TashkeelFixer.FixShaddaCombinations(glyphFixerOutput);
            // Fix flow of the text and put the result in FinalLetters field
            LigatureFixer.Fix(glyphFixerOutput, output, farsi, fixTextTags, preserveNumbers);
            if (fixTextTags)
            {
                RichTextFixer.Fix(output);
            }
            inputBuilder.Clear();
        }

        public static string InsertEoLToUguiText(string input, UGUITextLines[] linesInfo)
        {
            var lineStringList = new List<string>();
            var linesCount = linesInfo.Length;

            var infoIndex = 0;
            var curlineCharNum = 0;
            var singleLineLength = linesInfo[infoIndex].endIndex - linesInfo[infoIndex].startIndex + 1;
            var isNewLine = false;
            for (int i = input.Length-1; i >= 0 ; i--)
            {
                curlineCharNum++;
                if (curlineCharNum >= singleLineLength)
                {
                    //outputBuilder.Append(string);
                    lineStringList.Add( input.Substring(i,curlineCharNum));
                    isNewLine = true;
                }
            

                if (isNewLine)
                {
                    curlineCharNum = 0;
                    infoIndex++;
                    if (infoIndex >= linesCount)
                    {
                        //outputBuilder.Append(input.Substring(0,i-1));
                        break;
                    }
                    singleLineLength = linesInfo[infoIndex].endIndex - linesInfo[infoIndex].startIndex + 1;
                    isNewLine = false;
                }
            }
            lineStringList.Add( input.Substring(0,curlineCharNum));

            var ret = lineStringList[0];
            //for (int i = lineStringList.Count; i >= 0; i--)
            for (int i = 1; i < lineStringList.Count; i++)
            {
                ret += ("\n" + lineStringList[i]);
            }
            return ret;
        }

    }
}





