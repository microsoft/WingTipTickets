using System;
using System.Collections.Generic;
using System.Linq;

namespace DataCleaner
{
    public static class RandomHelpers
    {
        #region - Fields -

        private static uint _mod = 0x0;
        private static uint _seed = 0;

        #endregion

        #region - Extension Methods -

        public static T GetRandomElement<T>(this IEnumerable<T> collection)
        {
            var rand = new Random((int)(_seed++));
            var num = rand.Next(collection.Count());
            var item = collection.ElementAt(num);

            return item;
        }

        #endregion
    }
}

