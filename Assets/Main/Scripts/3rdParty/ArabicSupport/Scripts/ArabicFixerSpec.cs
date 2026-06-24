using System.Collections.Generic;
using System.Text;

namespace ArabicSupport
{
    public class ArabicFixerSpec
    {
        private static readonly HashSet<char> sTashkeelSet = new HashSet<char>()
        {
            (char) 0x064B,
            (char) 0x064C,
            (char) 0x064D,
            (char) 0x064E,
            (char) 0x064F,
            (char) 0x0650,
            (char) 0x0651,
            (char) 0x0652,
            (char) 0x0653,
            (char) 0xFC60,
            (char) 0xFC61,
            (char) 0xFC62,
        };

        public static bool IsCharTaskkeel(char ch)
        {
            return sTashkeelSet.Contains(ch);
        }

        /// <summary>
        /// Arabic Contextual forms General - Unicode
        /// </summary>
        internal enum IsolatedArabicLetters
        {
            Hamza = 0xFE80,
            Alef = 0xFE8D,
            AlefHamza = 0xFE83,
            WawHamza = 0xFE85,
            AlefMaksoor = 0xFE87,
            AlefMaksora = 0xFBFC,
            HamzaNabera = 0xFE89,
            Ba = 0xFE8F,
            Ta = 0xFE95,
            Tha2 = 0xFE99,
            Jeem = 0xFE9D,
            H7aa = 0xFEA1,
            Khaa2 = 0xFEA5,
            Dal = 0xFEA9,
            Thal = 0xFEAB,
            Ra2 = 0xFEAD,
            Zeen = 0xFEAF,
            Seen = 0xFEB1,
            Sheen = 0xFEB5,
            S9a = 0xFEB9,
            Dha = 0xFEBD,
            T6a = 0xFEC1,
            T6ha = 0xFEC5,
            Ain = 0xFEC9,
            Gain = 0xFECD,
            Fa = 0xFED1,
            Gaf = 0xFED5,
            Kaf = 0xFED9,
            Lam = 0xFEDD,
            Meem = 0xFEE1,
            Noon = 0xFEE5,
            Ha = 0xFEE9,
            Waw = 0xFEED,
            Ya = 0xFEF1,
            AlefMad = 0xFE81,
            TaMarboota = 0xFE93,
            PersianPe = 0xFB56, // Persian Letters;
            PersianChe = 0xFB7A,
            PersianZe = 0xFB8A,
            PersianGaf = 0xFB92,
            PersianGaf2 = 0xFB8E,
            PersianYeh = 0xFBFC,
        }

        /// <summary>
        /// Arabic Contextual forms - Isolated
        /// </summary>
        internal enum GeneralArabicLetters
        {
            Hamza = 0x0621,
            Alef = 0x0627,
            AlefHamza = 0x0623,
            WawHamza = 0x0624,
            AlefMaksoor = 0x0625,
            AlefMagsora = 0x0649,
            HamzaNabera = 0x0626,
            Ba = 0x0628,
            Ta = 0x062A,
            Tha2 = 0x062B,
            Jeem = 0x062C,
            H7aa = 0x062D,
            Khaa2 = 0x062E,
            Dal = 0x062F,
            Thal = 0x0630,
            Ra2 = 0x0631,
            Zeen = 0x0632,
            Seen = 0x0633,
            Sheen = 0x0634,
            S9a = 0x0635,
            Dha = 0x0636,
            T6a = 0x0637,
            T6ha = 0x0638,
            Ain = 0x0639,
            Gain = 0x063A,
            Fa = 0x0641,
            Gaf = 0x0642,
            Kaf = 0x0643,
            Lam = 0x0644,
            Meem = 0x0645,
            Noon = 0x0646,
            Ha = 0x0647,
            Waw = 0x0648,
            Ya = 0x064A,
            AlefMad = 0x0622,
            TaMarboota = 0x0629,
            PersianPe = 0x067E, // Persian Letters;
            PersianChe = 0x0686,
            PersianZe = 0x0698,
            PersianGaf = 0x06AF,
            PersianGaf2 = 0x06A9,
            PersianYeh = 0x06CC,
        }


        private static Dictionary<char, char> sGeneralArabicLetters2IsolatedArabicLettersMapping =
            new Dictionary<char, char>()
            {
                {(char) GeneralArabicLetters.Hamza, (char) IsolatedArabicLetters.Hamza},
                {(char) GeneralArabicLetters.Alef, (char) IsolatedArabicLetters.Alef},
                {(char) GeneralArabicLetters.AlefHamza, (char) IsolatedArabicLetters.AlefHamza},
                {(char) GeneralArabicLetters.WawHamza, (char) IsolatedArabicLetters.WawHamza},
                {(char) GeneralArabicLetters.AlefMaksoor, (char) IsolatedArabicLetters.AlefMaksoor},
                {(char) GeneralArabicLetters.AlefMagsora, (char) IsolatedArabicLetters.AlefMaksora},
                {(char) GeneralArabicLetters.HamzaNabera, (char) IsolatedArabicLetters.HamzaNabera},
                {(char) GeneralArabicLetters.Ba, (char) IsolatedArabicLetters.Ba},
                {(char) GeneralArabicLetters.Ta, (char) IsolatedArabicLetters.Ta},
                {(char) GeneralArabicLetters.Tha2, (char) IsolatedArabicLetters.Tha2},
                {(char) GeneralArabicLetters.Jeem, (char) IsolatedArabicLetters.Jeem},
                {(char) GeneralArabicLetters.H7aa, (char) IsolatedArabicLetters.H7aa},
                {(char) GeneralArabicLetters.Khaa2, (char) IsolatedArabicLetters.Khaa2},
                {(char) GeneralArabicLetters.Dal, (char) IsolatedArabicLetters.Dal},
                {(char) GeneralArabicLetters.Thal, (char) IsolatedArabicLetters.Thal},
                {(char) GeneralArabicLetters.Ra2, (char) IsolatedArabicLetters.Ra2},
                {(char) GeneralArabicLetters.Zeen, (char) IsolatedArabicLetters.Zeen},
                {(char) GeneralArabicLetters.Seen, (char) IsolatedArabicLetters.Seen},
                {(char) GeneralArabicLetters.Sheen, (char) IsolatedArabicLetters.Sheen},
                {(char) GeneralArabicLetters.S9a, (char) IsolatedArabicLetters.S9a},
                {(char) GeneralArabicLetters.Dha, (char) IsolatedArabicLetters.Dha},
                {(char) GeneralArabicLetters.T6a, (char) IsolatedArabicLetters.T6a},
                {(char) GeneralArabicLetters.T6ha, (char) IsolatedArabicLetters.T6ha},
                {(char) GeneralArabicLetters.Ain, (char) IsolatedArabicLetters.Ain},
                {(char) GeneralArabicLetters.Gain, (char) IsolatedArabicLetters.Gain},
                {(char) GeneralArabicLetters.Fa, (char) IsolatedArabicLetters.Fa},
                {(char) GeneralArabicLetters.Gaf, (char) IsolatedArabicLetters.Gaf},
                {(char) GeneralArabicLetters.Kaf, (char) IsolatedArabicLetters.Kaf},
                {(char) GeneralArabicLetters.Lam, (char) IsolatedArabicLetters.Lam},
                {(char) GeneralArabicLetters.Meem, (char) IsolatedArabicLetters.Meem},
                {(char) GeneralArabicLetters.Noon, (char) IsolatedArabicLetters.Noon},
                {(char) GeneralArabicLetters.Ha, (char) IsolatedArabicLetters.Ha},
                {(char) GeneralArabicLetters.Waw, (char) IsolatedArabicLetters.Waw},
                {(char) GeneralArabicLetters.Ya, (char) IsolatedArabicLetters.Ya},
                {(char) GeneralArabicLetters.AlefMad, (char) IsolatedArabicLetters.AlefMad},
                {(char) GeneralArabicLetters.TaMarboota, (char) IsolatedArabicLetters.TaMarboota},
                {(char) GeneralArabicLetters.PersianPe, (char) IsolatedArabicLetters.PersianPe},
                {(char) GeneralArabicLetters.PersianChe, (char) IsolatedArabicLetters.PersianChe},
                {(char) GeneralArabicLetters.PersianZe, (char) IsolatedArabicLetters.PersianZe},
                {(char) GeneralArabicLetters.PersianGaf, (char) IsolatedArabicLetters.PersianGaf},
                {(char) GeneralArabicLetters.PersianGaf2, (char) IsolatedArabicLetters.PersianGaf2},
                {(char) GeneralArabicLetters.PersianYeh, (char) IsolatedArabicLetters.PersianYeh},
            };

        public static char GeneralArabicLetter2IsolatedArabicLetter(char generalArabicLetter)
        {
            char ret = generalArabicLetter;
            if (sGeneralArabicLetters2IsolatedArabicLettersMapping.TryGetValue(generalArabicLetter, out ret))
            {
                return ret;
            }

            return generalArabicLetter;
        }

        public static bool IsIgnoredCharacter(char ch)
        {
            bool isPunctuation = char.IsPunctuation(ch);
            bool isNumber = char.IsNumber(ch);
            bool isLower = char.IsLower(ch);
            bool isUpper = char.IsUpper(ch);
            bool isSymbol = char.IsSymbol(ch);
            bool isPersianCharacter = ch == (char) 0xFB56 || ch == (char) 0xFB7A || ch == (char) 0xFB8A ||
                                      ch == (char) 0xFB92 || ch == (char) 0xFB8E;
            bool isPresentationFormB = (ch <= (char) 0xFEFF && ch >= (char) 0xFE70);
            bool isAcceptableCharacter = isPresentationFormB || isPersianCharacter || ch == (char) 0xFBFC;


            return isPunctuation ||
                   isNumber ||
                   isLower ||
                   isUpper ||
                   isSymbol ||
                   !isAcceptableCharacter ||
                   ch == 'a' || ch == '>' || ch == '<' || ch == (char) 0x061B;
        }

        /// <summary>
        /// Checks if the letter at index value is a leading character in Arabic or not.
        /// </summary>
        /// <param name="letters">The whole word that contains the character to be checked</param>
        /// <param name="index">The index of the character to be checked</param>
        /// <returns>True if the character at index is a leading character, else, returns false</returns>
        public static bool IsLeadingLetter(StringBuilder letters, int index)
        {
            bool lettersThatCannotBeBeforeALeadingLetter = index == 0
                                                           || letters[index - 1] == ' '
                                                           || letters[index - 1] == '*' // ??? Remove?
                                                           || letters[index - 1] == 'A' // ??? Remove?
                                                           || char.IsPunctuation(letters[index - 1])
                                                           || letters[index - 1] == '>'
                                                           || letters[index - 1] == '<'
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.Alef
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.Dal
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.Thal
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.Ra2
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.Zeen
                                                           || letters[index - 1] ==
                                                           (int) IsolatedArabicLetters.PersianZe
                                                           //|| letters[index - 1] == (int)IsolatedArabicLetters.AlefMaksora 
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.Waw
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.AlefMad
                                                           || letters[index - 1] ==
                                                           (int) IsolatedArabicLetters.AlefHamza
                                                           || letters[index - 1] == (int) IsolatedArabicLetters.Hamza
                                                           || letters[index - 1] ==
                                                           (int) IsolatedArabicLetters.AlefMaksoor
                                                           || letters[index - 1] ==
                                                           (int) IsolatedArabicLetters.WawHamza;

            bool lettersThatCannotBeALeadingLetter = letters[index] != ' '
                                                     && letters[index] != (int) IsolatedArabicLetters.Dal
                                                     && letters[index] != (int) IsolatedArabicLetters.Thal
                                                     && letters[index] != (int) IsolatedArabicLetters.Ra2
                                                     && letters[index] != (int) IsolatedArabicLetters.Zeen
                                                     && letters[index] != (int) IsolatedArabicLetters.PersianZe
                                                     && letters[index] != (int) IsolatedArabicLetters.Alef
                                                     && letters[index] != (int) IsolatedArabicLetters.AlefHamza
                                                     && letters[index] != (int) IsolatedArabicLetters.AlefMaksoor
                                                     && letters[index] != (int) IsolatedArabicLetters.AlefMad
                                                     && letters[index] != (int) IsolatedArabicLetters.WawHamza
                                                     && letters[index] != (int) IsolatedArabicLetters.Waw
                                                     && letters[index] != (int) IsolatedArabicLetters.Hamza;

            bool lettersThatCannotBeAfterLeadingLetter = index < letters.Length - 1
                                                         && letters[index + 1] != ' '
                                                         && !char.IsPunctuation(letters[index + 1])
                                                         && !char.IsNumber(letters[index + 1])
                                                         && !char.IsSymbol(letters[index + 1])
                                                         && !char.IsLower(letters[index + 1])
                                                         && !char.IsUpper(letters[index + 1])
                                                         && letters[index + 1] != (int) IsolatedArabicLetters.Hamza;

            if (lettersThatCannotBeBeforeALeadingLetter && lettersThatCannotBeALeadingLetter &&
                lettersThatCannotBeAfterLeadingLetter)

//		if ((index == 0 || letters[index - 1] == ' ' || letters[index - 1] == '*' || letters[index - 1] == 'A' || char.IsPunctuation(letters[index - 1])
//		     || letters[index - 1] == '>' || letters[index - 1] == '<' 
//		     || letters[index - 1] == (int)IsolatedArabicLetters.Alef
//		     || letters[index - 1] == (int)IsolatedArabicLetters.Dal || letters[index - 1] == (int)IsolatedArabicLetters.Thal
//		     || letters[index - 1] == (int)IsolatedArabicLetters.Ra2 
//		     || letters[index - 1] == (int)IsolatedArabicLetters.Zeen || letters[index - 1] == (int)IsolatedArabicLetters.PersianZe
//		     || letters[index - 1] == (int)IsolatedArabicLetters.AlefMaksora || letters[index - 1] == (int)IsolatedArabicLetters.Waw
//		     || letters[index - 1] == (int)IsolatedArabicLetters.AlefMad || letters[index - 1] == (int)IsolatedArabicLetters.AlefHamza
//		     || letters[index - 1] == (int)IsolatedArabicLetters.AlefMaksoor || letters[index - 1] == (int)IsolatedArabicLetters.WawHamza) 
//		    && letters[index] != ' ' && letters[index] != (int)IsolatedArabicLetters.Dal
//		    && letters[index] != (int)IsolatedArabicLetters.Thal
//		    && letters[index] != (int)IsolatedArabicLetters.Ra2 
//		    && letters[index] != (int)IsolatedArabicLetters.Zeen && letters[index] != (int)IsolatedArabicLetters.PersianZe
//		    && letters[index] != (int)IsolatedArabicLetters.Alef && letters[index] != (int)IsolatedArabicLetters.AlefHamza
//		    && letters[index] != (int)IsolatedArabicLetters.AlefMaksoor
//		    && letters[index] != (int)IsolatedArabicLetters.AlefMad
//		    && letters[index] != (int)IsolatedArabicLetters.WawHamza
//		    && letters[index] != (int)IsolatedArabicLetters.Waw
//		    && letters[index] != (int)IsolatedArabicLetters.Hamza
//		    && index < letters.Length - 1 && letters[index + 1] != ' ' && !char.IsPunctuation(letters[index + 1] ) && !char.IsNumber(letters[index + 1])
//		    && letters[index + 1] != (int)IsolatedArabicLetters.Hamza )
            {
                return true;
            }
            else
                return false;
        }

        /// <summary>
        /// Checks if the letter at index value is a finishing character in Arabic or not.
        /// </summary>
        /// <param name="letters">The whole word that contains the character to be checked</param>
        /// <param name="index">The index of the character to be checked</param>
        /// <returns>True if the character at index is a finishing character, else, returns false</returns>
        public static bool IsFinishingLetter(StringBuilder letters, int index)
        {
            bool indexZero = index != 0;
            bool lettersThatCannotBeBeforeAFinishingLetter = (index == 0)
                ? false
                : letters[index - 1] != ' '
//				&& char.IsDigit(letters[index-1])
//				&& char.IsLower(letters[index-1])
//				&& char.IsUpper(letters[index-1])
//				&& char.IsNumber(letters[index-1])
//				&& char.IsWhiteSpace(letters[index-1])
//				&& char.IsPunctuation(letters[index-1])
//				&& char.IsSymbol(letters[index-1])
                  && letters[index - 1] != (int) IsolatedArabicLetters.Dal
                  && letters[index - 1] != (int) IsolatedArabicLetters.Thal
                  && letters[index - 1] != (int) IsolatedArabicLetters.Ra2
                  && letters[index - 1] != (int) IsolatedArabicLetters.Zeen
                  && letters[index - 1] != (int) IsolatedArabicLetters.PersianZe
                  //&& letters[index - 1] != (int)IsolatedArabicLetters.AlefMaksora 
                  && letters[index - 1] != (int) IsolatedArabicLetters.Waw
                  && letters[index - 1] != (int) IsolatedArabicLetters.Alef
                  && letters[index - 1] != (int) IsolatedArabicLetters.AlefMad
                  && letters[index - 1] != (int) IsolatedArabicLetters.AlefHamza
                  && letters[index - 1] != (int) IsolatedArabicLetters.AlefMaksoor
                  && letters[index - 1] != (int) IsolatedArabicLetters.WawHamza
                  && letters[index - 1] != (int) IsolatedArabicLetters.Hamza
                  && !char.IsPunctuation(letters[index - 1])
                  && !char.IsSymbol(letters[index - 1])
                  && letters[index - 1] != '>'
                  && letters[index - 1] != '<';


            bool lettersThatCannotBeFinishingLetters =
                letters[index] != ' ' && letters[index] != (int) IsolatedArabicLetters.Hamza;


            if (lettersThatCannotBeBeforeAFinishingLetter && lettersThatCannotBeFinishingLetters)

//		if (index != 0 && letters[index - 1] != ' ' && letters[index - 1] != '*' && letters[index - 1] != 'A'
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Dal && letters[index - 1] != (int)IsolatedArabicLetters.Thal
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Ra2 
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Zeen && letters[index - 1] != (int)IsolatedArabicLetters.PersianZe
//		    && letters[index - 1] != (int)IsolatedArabicLetters.AlefMaksora && letters[index - 1] != (int)IsolatedArabicLetters.Waw
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Alef && letters[index - 1] != (int)IsolatedArabicLetters.AlefMad
//		    && letters[index - 1] != (int)IsolatedArabicLetters.AlefHamza && letters[index - 1] != (int)IsolatedArabicLetters.AlefMaksoor
//		    && letters[index - 1] != (int)IsolatedArabicLetters.WawHamza && letters[index - 1] != (int)IsolatedArabicLetters.Hamza 
//		    && !char.IsPunctuation(letters[index - 1]) && letters[index - 1] != '>' && letters[index - 1] != '<' 
//		    && letters[index] != ' ' && index < letters.Length
//		    && letters[index] != (int)IsolatedArabicLetters.Hamza)
            {
                //try
                //{
                //    if (char.IsPunctuation(letters[index + 1]))
                //        return true;
                //    else
                //        return false;
                //}
                //catch (Exception e)
                //{
                //    return false;
                //}

                return true;
            }
            //return true;
            else
                return false;
        }

        /// <summary>
        /// Checks if the letter at index value is a middle character in Arabic or not.
        /// </summary>
        /// <param name="letters">The whole word that contains the character to be checked</param>
        /// <param name="index">The index of the character to be checked</param>
        /// <returns>True if the character at index is a middle character, else, returns false</returns>
        public static bool IsMiddleLetter(StringBuilder letters, int index)
        {
            bool lettersThatCannotBeMiddleLetters = (index == 0)
                ? false
                : letters[index] != (int) IsolatedArabicLetters.Alef
                  && letters[index] != (int) IsolatedArabicLetters.Dal
                  && letters[index] != (int) IsolatedArabicLetters.Thal
                  && letters[index] != (int) IsolatedArabicLetters.Ra2
                  && letters[index] != (int) IsolatedArabicLetters.Zeen
                  && letters[index] != (int) IsolatedArabicLetters.PersianZe
                  //&& letters[index] != (int)IsolatedArabicLetters.AlefMaksora
                  && letters[index] != (int) IsolatedArabicLetters.Waw
                  && letters[index] != (int) IsolatedArabicLetters.AlefMad
                  && letters[index] != (int) IsolatedArabicLetters.AlefHamza
                  && letters[index] != (int) IsolatedArabicLetters.AlefMaksoor
                  && letters[index] != (int) IsolatedArabicLetters.WawHamza
                  && letters[index] != (int) IsolatedArabicLetters.Hamza;

            bool lettersThatCannotBeBeforeMiddleCharacters = (index == 0)
                ? false
                : letters[index - 1] != (int) IsolatedArabicLetters.Alef
                  && letters[index - 1] != (int) IsolatedArabicLetters.Dal
                  && letters[index - 1] != (int) IsolatedArabicLetters.Thal
                  && letters[index - 1] != (int) IsolatedArabicLetters.Ra2
                  && letters[index - 1] != (int) IsolatedArabicLetters.Zeen
                  && letters[index - 1] != (int) IsolatedArabicLetters.PersianZe
                  //&& letters[index - 1] != (int)IsolatedArabicLetters.AlefMaksora
                  && letters[index - 1] != (int) IsolatedArabicLetters.Waw
                  && letters[index - 1] != (int) IsolatedArabicLetters.AlefMad
                  && letters[index - 1] != (int) IsolatedArabicLetters.AlefHamza
                  && letters[index - 1] != (int) IsolatedArabicLetters.AlefMaksoor
                  && letters[index - 1] != (int) IsolatedArabicLetters.WawHamza
                  && letters[index - 1] != (int) IsolatedArabicLetters.Hamza
                  && !char.IsPunctuation(letters[index - 1])
                  && letters[index - 1] != '>'
                  && letters[index - 1] != '<'
                  && letters[index - 1] != ' '
                  && letters[index - 1] != '*';

            bool lettersThatCannotBeAfterMiddleCharacters = (index >= letters.Length - 1)
                ? false
                : letters[index + 1] != ' '
                  && letters[index + 1] != '\r'
                  && letters[index + 1] != (int) IsolatedArabicLetters.Hamza
                  && !char.IsNumber(letters[index + 1])
                  && !char.IsSymbol(letters[index + 1])
                  && !char.IsPunctuation(letters[index + 1]);
            if (lettersThatCannotBeAfterMiddleCharacters && lettersThatCannotBeBeforeMiddleCharacters &&
                lettersThatCannotBeMiddleLetters)

//		if (index != 0 && letters[index] != ' '
//		    && letters[index] != (int)IsolatedArabicLetters.Alef && letters[index] != (int)IsolatedArabicLetters.Dal
//		    && letters[index] != (int)IsolatedArabicLetters.Thal && letters[index] != (int)IsolatedArabicLetters.Ra2
//		    && letters[index] != (int)IsolatedArabicLetters.Zeen && letters[index] != (int)IsolatedArabicLetters.PersianZe 
//		    && letters[index] != (int)IsolatedArabicLetters.AlefMaksora
//		    && letters[index] != (int)IsolatedArabicLetters.Waw && letters[index] != (int)IsolatedArabicLetters.AlefMad
//		    && letters[index] != (int)IsolatedArabicLetters.AlefHamza && letters[index] != (int)IsolatedArabicLetters.AlefMaksoor
//		    && letters[index] != (int)IsolatedArabicLetters.WawHamza && letters[index] != (int)IsolatedArabicLetters.Hamza
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Alef && letters[index - 1] != (int)IsolatedArabicLetters.Dal
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Thal && letters[index - 1] != (int)IsolatedArabicLetters.Ra2
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Zeen && letters[index - 1] != (int)IsolatedArabicLetters.PersianZe 
//		    && letters[index - 1] != (int)IsolatedArabicLetters.AlefMaksora
//		    && letters[index - 1] != (int)IsolatedArabicLetters.Waw && letters[index - 1] != (int)IsolatedArabicLetters.AlefMad
//		    && letters[index - 1] != (int)IsolatedArabicLetters.AlefHamza && letters[index - 1] != (int)IsolatedArabicLetters.AlefMaksoor
//		    && letters[index - 1] != (int)IsolatedArabicLetters.WawHamza && letters[index - 1] != (int)IsolatedArabicLetters.Hamza 
//		    && letters[index - 1] != '>' && letters[index - 1] != '<' 
//		    && letters[index - 1] != ' ' && letters[index - 1] != '*' && !char.IsPunctuation(letters[index - 1])
//		    && index < letters.Length - 1 && letters[index + 1] != ' ' && letters[index + 1] != '\r' && letters[index + 1] != 'A' 
//		    && letters[index + 1] != '>' && letters[index + 1] != '>' && letters[index + 1] != (int)IsolatedArabicLetters.Hamza
//		    )
            {
                try
                {
                    if (char.IsPunctuation(letters[index + 1]))
                        return false;
                    else
                        return true;
                }
                catch
                {
                    return false;
                }

                //return true;
            }
            else
                return false;
        }
        
        public static char ConvertNumberToHindu(char numberChar)
        {
            switch(numberChar)
            {
                case (char)0x0030: return (char)0x0660;
                case (char)0x0031: return (char)0x0661;
                case (char)0x0032: return (char)0x0662;
                case (char)0x0033: return (char)0x0663;
                case (char)0x0034: return (char)0x0664;
                case (char)0x0035: return (char)0x0665;
                case (char)0x0036: return (char)0x0666;
                case (char)0x0037: return (char)0x0667;
                case (char)0x0038: return (char)0x0668;
                case (char)0x0039: return (char)0x0669;
                default:
                    return numberChar;
            }
        }

        private static readonly Dictionary<char, char> sForceBreakSymbols = new Dictionary<char, char>()
        {
            {'(', ')'},
            {'[', ']'},

            {')', '('},
            {']', '['},


        };

        public static bool NeedForceBreak(char input, out char output)
        {
            if (sForceBreakSymbols.TryGetValue(input, out output))
            {
                return true;
            }

            return false;
        }
    }
    
    
}





