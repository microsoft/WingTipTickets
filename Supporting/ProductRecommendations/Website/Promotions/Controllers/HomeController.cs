using System.Net;
using Promotions.Events;
using Promotions.Models;
using Promotions.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Promotions.Controllers
{
    public class HomeController : Controller
    {
        ICustomerRepository _customerRepository;
        IProductsRepository _productsRepository;
        IPromotionsRepository _promotionsRepository;
        private ITelemetryRepository _telemetryRepository;

        public HomeController(
            ICustomerRepository customerRepository,
            IProductsRepository productsRepository,
            IPromotionsRepository promotionsRepository,
            ITelemetryRepository telemetryRepository)
        {
            _customerRepository = customerRepository;
            _productsRepository = productsRepository;
            _promotionsRepository = promotionsRepository;
            _telemetryRepository = telemetryRepository;
        }

        public ActionResult Buy(Int64 id)
        {
            var customer = _customerRepository.GetCustomerByName(User.Identity.Name);
            var product = _productsRepository.GetProduct(id);
            var promotion = _promotionsRepository.GetPromotion(customer.Id, product.Id);

            var purchaseEvent = new PurchaseEvent
            {
                customerId = customer.Id,
                productId = id,
                price = promotion != null ? promotion.NewPrice : product.Price,
                purchaseTime = DateTime.Now,
                orderId = Guid.NewGuid()
            };

            _telemetryRepository.SendPurchase(purchaseEvent);

            System.Threading.Thread.Sleep(TimeSpan.FromSeconds(5));

            return new HttpStatusCodeResult(System.Net.HttpStatusCode.OK);
        }

        public ActionResult Details(Int64 id)
        {
            var product = _productsRepository.GetProduct(id);

            if (product == null)
            {
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.NotFound);
            }

            var relatedCatalogItems = new List<CatalogItem>();
            IEnumerable<Product> relatedProducts = new List<Product>();


            IEnumerable<Promotion> promotions = null;
            Customer customer = null;

            relatedProducts = _productsRepository.GetRelatedProducts(product.Id);

            var clickEvent = new ClickEvent
            {
                clickTime = DateTime.Now,
                productId = product.Id
            };

            _telemetryRepository.SendClick(clickEvent);

            if (User.Identity.IsAuthenticated)
            {
                customer = _customerRepository.GetCustomerByName(User.Identity.Name);
                promotions = _promotionsRepository.GetPromotions(customer.Id);
            }

            foreach (var relatedProduct in relatedProducts.OrderBy(p => p.Name))
            {
                relatedCatalogItems.Add(ProductToCatalogItem(promotions, customer, relatedProduct));
            }

            return View(new CatalogItemDetailsModel(ProductToCatalogItem(promotions, customer, product), relatedCatalogItems));
        }

        private static CatalogItem ProductToCatalogItem(IEnumerable<Promotion> promotions, Customer customer, Product relatedProduct)
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

            var promotion = promotions != null && customer != null ? promotions.FirstOrDefault(p => p.CustomerId == customer.Id && p.ProductId == relatedProduct.Id) : null;
            if (promotion != null)
            {
                catalogItem.CurrentPrice = promotion.NewPrice;
                catalogItem.PromotionDiscount = promotion.PromotionDiscount;
            }
            return catalogItem;
        }

        public ActionResult Index(string UserName, int? BandId)
        {
            if (!String.IsNullOrEmpty(UserName))
            {
                return RedirectToAction("LoginAuto", "Account", new
                {
                    userName = UserName,
                    bandId = BandId
                });
            }
            else if (User.Identity.IsAuthenticated && String.IsNullOrEmpty(UserName))
            {
                HttpContext.GetOwinContext().Authentication.SignOut();
            }


            if (BandId.HasValue)
            {
                return RedirectToAction("Details", "Home", new
                {
                    id = Convert.ToInt64(BandId.Value)
                });
            }

            var catalogItems = new List<CatalogItem>();
            var recommendedCatalogItems = new List<CatalogItem>();
            var products = _productsRepository.GetProducts();

            IEnumerable<Promotion> promotions = null;
            IEnumerable<Product> recommendedProducts = new List<Product>();
            Customer customer = null;
            var username = Request.QueryString["user"];

            if (User.Identity.IsAuthenticated)
            {
                customer = _customerRepository.GetCustomerByName(User.Identity.Name);
                promotions = _promotionsRepository.GetPromotions(customer.Id);
                recommendedProducts = _productsRepository.GetRecommendedProducts(customer.Id);
            }
            else if (!String.IsNullOrEmpty(username))
            {
                customer = _customerRepository.GetCustomerByName(username);
                promotions = _promotionsRepository.GetPromotions(customer.Id);
                recommendedProducts = _productsRepository.GetRecommendedProducts(customer.Id);
            }

            foreach (var recommendedProduct in recommendedProducts.OrderBy(p => p.Name))
            {
                recommendedCatalogItems.Add(ProductToCatalogItem(promotions, customer, recommendedProduct));
            }

            foreach (var product in products.OrderBy(p => p.Name))
            {
                if (User.Identity.IsAuthenticated)
                {
                    var playCount = _productsRepository.GetSongPlayCount(product.Id, customer.Id);
                    product.PlayCount = playCount;
                }
                catalogItems.Add(ProductToCatalogItem(promotions, customer, product));
            }

            var catalogModel = new CatalogModel(catalogItems, recommendedCatalogItems);

            return View(catalogModel);
        }
    }
}