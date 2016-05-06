using System.Collections.Generic;
using Tenant.Mvc.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IFindSeatsRepository
    {
        FindSeatsViewModel GetFindSeatsData(int concertId);
        List<SeatSectionLayoutViewModel> GetSeatSectionLayout(int concertId, int ticketLevelId);
    }

    public class SeatSectionLayoutViewModel
    {
        public int RowNumber { get; set; }
        public int SkipCount { get; set; }
        public int StartNumber { get; set; }
        public int EndNumber { get; set; }
        public List<int> SelectedSeats { get; set; }
    }
}