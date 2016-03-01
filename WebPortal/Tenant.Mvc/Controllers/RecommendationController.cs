using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading;
using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Recommendations;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Core.Telemetry;

namespace Tenant.Mvc.Controllers
{
    public class RecommendationController : BaseController
    {
        #region - Fields -

        private readonly ICustomerRepository _customerRepository;
        private readonly IProductsRepository _productsRepository;
        private readonly IPromotionsRepository _promotionsRepository;
        private readonly ITelemetryRepository _telemetryRepository;

        #endregion

        #region - Constructors -

        public RecommendationController(ICustomerRepository customerRepository, IProductsRepository productsRepository, IPromotionsRepository promotionsRepository, ITelemetryRepository telemetryRepository)
        {
            // Setup Fields
            _customerRepository = customerRepository;
            _productsRepository = productsRepository;
            _promotionsRepository = promotionsRepository;
            _telemetryRepository = telemetryRepository;
        }

        #endregion

        #region - Index View -

        public ActionResult Index()
        {
            var catalogItems = new List<CatalogItem>();
            var products = _productsRepository.GetProducts();
            var username = Request.QueryString["user"];

            IEnumerable<Promotion> promotions = null;
            IEnumerable<Product> recommendedProducts = new List<Product>();

            CustomerRec customer = null;
            if (User.Identity.IsAuthenticated)
            {
                customer = _customerRepository.GetCustomerByName(User.Identity.Name);

                if (customer != null)
                {
                    promotions = _promotionsRepository.GetPromotions(customer.CustomerId);
                    recommendedProducts = _productsRepository.GetRecommendedProducts(customer.CustomerId);
                }
            }
            else if (!String.IsNullOrEmpty(username))
            {
                customer = _customerRepository.GetCustomerByName(username);
                promotions = _promotionsRepository.GetPromotions(customer.CustomerId);
                recommendedProducts = _productsRepository.GetRecommendedProducts(customer.CustomerId);
            }

            var recommendedCatalogItems = recommendedProducts
                .OrderBy(p => p.Name)
                .Select(recommendedProduct => ProductToCatalogItem(promotions, customer, recommendedProduct))
                .ToList();

            foreach (var product in products.OrderBy(p => p.Name))
            {
                if (User.Identity.IsAuthenticated && customer != null)
                {
                    var playCount = _productsRepository.GetSongPlayCount(product.Id, customer.CustomerId);

                    product.PlayCount = playCount;
                }

                catalogItems.Add(ProductToCatalogItem(promotions, customer, product));
            }

            var catalogModel = new CatalogModel(catalogItems, recommendedCatalogItems);

            return View(catalogModel);
        }

        #endregion

        #region - Page Helpers -

        public ActionResult Buy(int id)
        {
            var customer = _customerRepository.GetCustomerByName(User.Identity.Name);
            var product = _productsRepository.GetProduct(id);
            var promotion = _promotionsRepository.GetPromotion(customer.CustomerId, product.Id);

            var purchaseEvent = new PurchaseEvent
            {
                CustomerId = customer.CustomerId,
                ProductId = id,
                Price = promotion != null ? promotion.NewPrice : product.Price,
                PurchaseTime = DateTime.Now,
                OrderId = Guid.NewGuid()
            };

            _telemetryRepository.SendPurchase(purchaseEvent);

            Thread.Sleep(TimeSpan.FromSeconds(5));

            return new HttpStatusCodeResult(HttpStatusCode.OK);
        }

        public ActionResult Details(int id)
        {
            var product = _productsRepository.GetProduct(id);

            if (product == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.NotFound);
            }

            IEnumerable<Promotion> promotions = null;
            CustomerRec customer = null;

            var relatedProducts = _productsRepository.GetRelatedProducts(product.Id);

            var clickEvent = new ClickEvent
            {
                ClickTime = DateTime.Now,
                ProductId = product.Id
            };

            _telemetryRepository.SendClick(clickEvent);

            if (User.Identity.IsAuthenticated)
            {
                customer = _customerRepository.GetCustomerByName(User.Identity.Name);
                promotions = _promotionsRepository.GetPromotions(customer.CustomerId);
            }

            var relatedCatalogItems = relatedProducts
                .OrderBy(p => p.Name)
                .Select(relatedProduct => ProductToCatalogItem(promotions, customer, relatedProduct))
                .ToList();

            return View(new CatalogItemDetailsModel(ProductToCatalogItem(promotions, customer, product), relatedCatalogItems));
        }

        #endregion

        #region - Private Methods -

        private static CatalogItem ProductToCatalogItem(IEnumerable<Promotion> promotions, CustomerRec customer, Product relatedProduct)
        {
            var catalogItem = new CatalogItem
            {
                Id = relatedProduct.Id,
                Name = relatedProduct.Name,
                Description = relatedProduct.Description,
                Title1 = relatedProduct.Title1,
                Title2 = relatedProduct.Title2,
                TitlesCount = relatedProduct.TitlesCount,
                OriginalPrice = relatedProduct.Price,
                PlayCount = relatedProduct.PlayCount
            };

            var promotion = promotions != null && customer != null 
                ? promotions.FirstOrDefault(p => p.CustomerId == customer.CustomerId && p.ProductId == relatedProduct.Id) 
                : null;

            if (promotion != null)
            {
                catalogItem.CurrentPrice = promotion.NewPrice;
                catalogItem.PromotionDiscount = promotion.PromotionDiscount;
            }

            return catalogItem;
        }

        #endregion
    }
}