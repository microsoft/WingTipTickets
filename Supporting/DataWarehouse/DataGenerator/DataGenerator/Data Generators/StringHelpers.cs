namespace DataCleaner
{
    public static class StringHelpers
    {
        #region - Extension Methods -

        public static string PadWithZeros(this long value, int paddingLength)
        {
            string strVal = value.ToString();
            int length = strVal.Length;

            for (int x = 0; x < paddingLength - length; x++)
            {
                strVal = strVal.Insert(0, "0");
            }

            return strVal;
        }

        #endregion
    }
}
