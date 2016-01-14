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
            int num = 0;
            int repeat = 0;

            int bot, top;
            var vs = _random.Next(_random.Next(6), 5);
                
            switch (vs)
            {
                case 1:
                    bot = _random.Next(collection.Count());
                    top = collection.Count();

                    num = _random.Next(bot, top);
                    break;
                case 2:
                    bot = 0;
                    top = _random.Next(collection.Count());

                    num = _random.Next(bot, top);
                    break;
                case 3:
                    bot = _random.Next(collection.Count());
                    top = _random.Next(bot, collection.Count());

                    num = _random.Next(bot, top);
                    break;
                case 4:
                    top = _random.Next(collection.Count());
                    bot = _random.Next(top);

                    num = _random.Next(bot, top);
                    break;
            }

            var item = collection.ElementAt(num);

            return item;
        }

        #endregion
    }
}

