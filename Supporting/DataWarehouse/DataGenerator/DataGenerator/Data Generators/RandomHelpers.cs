using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography;

namespace DataCleaner
{
    public static class RandomHelpers
    {
        #region - Fields -

        private static readonly CryptoRandom _random = new CryptoRandom();

        #endregion

        #region - Extension Methods -

        public static T GetRandomElement<T>(this IEnumerable<T> collection)
        {
            var random = _random.Next(collection.Count());

            var item = collection.ElementAt(random);

            return item;
        }

        public static KeyValuePair<string, int> GetRandomElement(this Dictionary<string, int> collection)
        {
            var maxWeight = collection.Max(c => c.Value);
            var rndWeight = 0;

            do
            {
                rndWeight = _random.Next(100);
            }
            while (rndWeight > maxWeight);

            var weightGroup = collection.Where(v => v.Value >= rndWeight).OrderBy(v => v.Value).First().Value;
            var items = collection.Where(v => v.Value == weightGroup);

            var rndIndex = _random.Next(items.Count());
            var item = items.ElementAt(rndIndex);

            return item;
        }

        #endregion
    }
}

