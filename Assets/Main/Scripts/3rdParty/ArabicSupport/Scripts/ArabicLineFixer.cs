using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace ArabicSupport
{
    public class ArabicLineFixer
    {
        private readonly StringBuilder mOriginalContent = new StringBuilder();
        private readonly StringBuilder mPreFixedContent = new StringBuilder();
        private readonly StringBuilder mFixedContent = new StringBuilder();
        private readonly StringBuilder mTempNumberContent = new StringBuilder();
        private readonly StringBuilder mStringReverseBuilder = new StringBuilder();

        private readonly List<string> mRichTokens = new List<string>();

        private readonly Dictionary<string, string> mEndRichToken2StarRichTokenMapping =
            new Dictionary<string, string>();

        private readonly Regex mRichTokenMatcher = new Regex(@"</?[A-z=#0-9]+>");

        private readonly Regex mReverseRichTokenMatcher = new Regex(@"^>[A-z=#0-9]+/?<");


        private int mReverseRichTokenCounter = 0;
        private void Reset()
        {
            mOriginalContent.Clear();
            mPreFixedContent.Clear();
            mRichTokens.Clear();
            mEndRichToken2StarRichTokenMapping.Clear();
            mFixedContent.Clear();
            mReverseRichTokenCounter = 0;

        }

        private void PreFix(string line)
        {
            foreach (char ch in line)
            {
                if (ArabicFixerSpec.IsCharTaskkeel(ch))
                {
                    continue;
                }

                char converted = ArabicFixerSpec.GeneralArabicLetter2IsolatedArabicLetter(ch);
                mOriginalContent.Append(converted);
            }

            for (int i = 0; i < mOriginalContent.Length; ++i)
            {
                bool lamJump = false;
                char curChar = mOriginalContent[i];
                if (curChar == (char) ArabicFixerSpec.IsolatedArabicLetters.Lam && i < mOriginalContent.Length - 1)
                {
                    char nextChar = mOriginalContent[i + 1];


                    switch (nextChar)
                    {
                        case (char) ArabicFixerSpec.IsolatedArabicLetters.AlefMaksoor:
                            curChar = (char) 0xFEF7;
                            lamJump = true;
                            break;
                        case (char) ArabicFixerSpec.IsolatedArabicLetters.Alef:
                            curChar = (char) 0xFEF9;
                            lamJump = true;
                            break;
                        case (char) ArabicFixerSpec.IsolatedArabicLetters.AlefHamza:
                            curChar = (char) 0xFEF5;
                            lamJump = true;
                            break;
                        case (char) ArabicFixerSpec.IsolatedArabicLetters.AlefMad:
                            curChar = (char) 0xFEF3;
                            lamJump = true;
                            break;
                    }
                }

                if (!ArabicFixerSpec.IsIgnoredCharacter(curChar))
                {
                    if (ArabicFixerSpec.IsMiddleLetter(mOriginalContent, i))
                    {
                        mPreFixedContent.Append((char) (curChar + 3));
                    }
                    else if (ArabicFixerSpec.IsFinishingLetter(mOriginalContent, i))
                    {
                        mPreFixedContent.Append((char) (curChar + 1));
                    }
                    else if (ArabicFixerSpec.IsLeadingLetter(mOriginalContent, i))
                    {
                        mPreFixedContent.Append((char) (curChar + 2));
                    }
                    else
                    {
                        mPreFixedContent.Append((char) curChar);
                    }
                }
                else
                {
                    mPreFixedContent.Append((char) curChar);
                }

                if (lamJump)
                {
                    mPreFixedContent.Append((char) 0xFFFF);
                    i++;
                }
            }
        }

        private string ReverseString(string str)
        {
            mStringReverseBuilder.Clear();
            for (int i = str.Length - 1; i >= 0; i--)
            {
                mStringReverseBuilder.Append(str[i]);
            }

            return mStringReverseBuilder.ToString();
        }

        private void ParseRichTokens()
        {
            var matches = mRichTokenMatcher.Matches(mPreFixedContent.ToString());
            if (matches.Count > 0)
            {
                for (int i = 0; i < matches.Count; ++i)
                {
                    var match = matches[i];

                    string token = match.Value;
                    
//                    MeshFileStreamLogger.Instance.LogLine(MeshFileStreamLogger.LoggerCategory.Combine,
//                        $"    Token:{token}");
                    
                    
                    mRichTokens.Add(ReverseString(match.Value));
                }
            }
        }

        private void ProcessTempNumber()
        {
            if (mTempNumberContent.Length > 0)
            {
                string numberContent = mTempNumberContent.ToString();
                
               
                if (mReverseRichTokenMatcher.IsMatch(numberContent) && mReverseRichTokenCounter < mRichTokens.Count )
                {
                    string temp = mRichTokens[mReverseRichTokenCounter];
                    
//                    MeshFileStreamLogger.Instance.LogLine(MeshFileStreamLogger.LoggerCategory.Combine,
//                        $"    Replace:{numberContent} -> {temp}");
                    numberContent = temp;
                    
                    for (int i = 0; i < numberContent.Length; i++)
                    {
                        mFixedContent.Append(numberContent[numberContent.Length - 1 - i]);
                    }
                    mReverseRichTokenCounter++;
                }
                else
                {
                    for (int i = 0; i < numberContent.Length; i++)
                    {
                        char ch = numberContent[numberContent.Length - 1 - i];
                        
#if USE_ARABIC_NUMBER
                        mFixedContent.Append(ArabicFixerSpec.ConvertNumberToHindu(ch));
#else
                        mFixedContent.Append(ch);
#endif
                    }

//                    MeshFileStreamLogger.Instance.LogLine(MeshFileStreamLogger.LoggerCategory.Combine,
//                        $"    no replace:{numberContent}");
                }
                
                

                mTempNumberContent.Clear();
            }
        }

        private string Fix()
        {
            for (int i = mPreFixedContent.Length - 1; i >= 0; i--)
            {
                // 去掉，影响[]的标签
                /*if (char.IsPunctuation(mPreFixedContent[i]) && i > 0 && i < mPreFixedContent.Length - 1 &&
                    (char.IsPunctuation(mPreFixedContent[i - 1]) || char.IsPunctuation(mPreFixedContent[i + 1])))
                {
                    if (mPreFixedContent[i] == '(')
                        mFixedContent.Append(')');
                    else if (mPreFixedContent[i] == ')')
                        mFixedContent.Append('(');
                    else if (mPreFixedContent[i] == '<')
                        mFixedContent.Append('>');
                    else if (mPreFixedContent[i] == '>')
                        mFixedContent.Append('<');
                    else if (mPreFixedContent[i] == '[')
                        mFixedContent.Append(']');
                    else if (mPreFixedContent[i] == ']')
                        mFixedContent.Append('[');
                    else if (mPreFixedContent[i] != 0xFFFF)
                        mFixedContent.Append(mPreFixedContent[i]);
                    
                    ProcessTempNumber();
                }
                else*/ 
                if (char.IsNumber(mPreFixedContent[i]) || char.IsLower(mPreFixedContent[i]) ||
                         char.IsUpper(mPreFixedContent[i]) || char.IsSymbol(mPreFixedContent[i]) ||
                         char.IsPunctuation(mPreFixedContent[i]) ) // || lettersFinal[i] == '^') //)
                {
                    char forceBreakChar = mPreFixedContent[i];
                    if (ArabicFixerSpec.NeedForceBreak(mPreFixedContent[i], out forceBreakChar))
                    {
                        ProcessTempNumber();
                        mFixedContent.Append(forceBreakChar);
                    }
                    else
                    {
                        mTempNumberContent.Append(mPreFixedContent[i]);
                        if (mPreFixedContent[i] == '<' 
                            || (i > 0 && mPreFixedContent[i-1] == '>') )
                        {
                            ProcessTempNumber();
                        } 
                    }
                }
                // For cases where english words and arabic are mixed. This allows for using arabic, english and numbers in one sentence.
                else if (mPreFixedContent[i] == ' ' && i > 0 && i < mPreFixedContent.Length - 1 &&
                         (char.IsLower(mPreFixedContent[i - 1]) || char.IsUpper(mPreFixedContent[i - 1]) ||
                          char.IsNumber(mPreFixedContent[i - 1])) &&
                         (char.IsLower(mPreFixedContent[i + 1]) || char.IsUpper(mPreFixedContent[i + 1]) ||
                          char.IsNumber(mPreFixedContent[i + 1])))

                {
                    mTempNumberContent.Append(mPreFixedContent[i]);
                }
                else if ((mPreFixedContent[i] >= (char) 0xD800 && mPreFixedContent[i] <= (char) 0xDBFF) ||
                         (mPreFixedContent[i] >= (char) 0xDC00 && mPreFixedContent[i] <= (char) 0xDFFF))
                {
                    mTempNumberContent.Append(mPreFixedContent[i]);
                }
                else
                {
                    ProcessTempNumber();

                    if (mPreFixedContent[i] != 0xFFFF)
                    {
                        mFixedContent.Append(mPreFixedContent[i]);
                    }
                }
            }

            ProcessTempNumber();

            return mFixedContent.ToString();
        }

        public string FixLine(string line)
        {
            Reset();
            PreFix(line);
            ParseRichTokens();

            return Fix();
        }

        public static void Test()
        {
//            ArabicLineFixer fixer = new ArabicLineFixer();
//
//            string line =
//                "لا إشعار بين <color=#3EB2FFFF>00:00</color> و <color=#3EB2FFFF>08:00</color>(إضغط عليها لتغيير الوقت)";
//
//
//            MeshFileStreamLogger.Instance.LogLine(MeshFileStreamLogger.LoggerCategory.Combine, $"Test1:{line}");
//            string fixedLine = fixer.FixLine(line);
//
//            MeshFileStreamLogger.Instance.LogLine(MeshFileStreamLogger.LoggerCategory.Combine, $"Test2:{fixedLine}");
        }
    }
}





