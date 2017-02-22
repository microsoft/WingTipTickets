using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Contexts
{
    public class SeatSectionContext
    {
        #region - Get Methods -

        public SeatSectionModel GetSeatSection(int venueId, string description)
        {
            var seatSections = new List<SeatSectionModel>();

            var query =
                $@"SELECT S.SeatSectionId, S.SeatCount, S.Description, S.VenueId, TL.TicketLevelId, TL.TicketPrice, TL.Description AS  TicketLevelDescription FROM SeatSection S JOIN TicketLevels TL ON S.SeatSectionId = TL.SeatSectionId WHERE S.VenueId = {
                    venueId} AND S.Description = '{description}'";

            using (var cmd = new SqlCommand(query, WingtipTicketApp.CreateTenantConnectionDatabase1()))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    var dsUser = new DataSet();
                    sdAdapter.Fill(dsUser);

                    if (dsUser.Tables.Count > 0)
                    {
                        seatSections.AddRange(from DataRow row in dsUser.Tables[0].Rows
                            select new SeatSectionModel()
                            {
                                SeatSectionId = Convert.ToInt32(row["SeatSectionId"]), TicketPrice = Convert.ToDecimal(row["TicketPrice"]), VenueId = Convert.ToInt32(row["VenueId"]), Description = row["Description"].ToString(), SeatCount = Convert.ToInt32(row["SeatCount"]), TicketLevelDescription = row["TicketLevelDescription"].ToString(), TicketLevelId = Convert.ToInt32(row["TicketLevelId"])
                            });
                    }
                }
            }

            return seatSections.FirstOrDefault();
        }


        public SeatSectionModel GetSeatSectionDetails(int seatSectionId)
        {
            var seatSections = new List<SeatSectionModel>();

            var query =
                $@"SELECT * FROM SeatSection WHERE SeatSectionId = {seatSectionId}";

            using (var cmd = new SqlCommand(query, WingtipTicketApp.CreateTenantConnectionDatabase1()))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    var dsUser = new DataSet();
                    sdAdapter.Fill(dsUser);

                    if (dsUser.Tables.Count > 0)
                    {
                        seatSections.AddRange(from DataRow row in dsUser.Tables[0].Rows
                                              select new SeatSectionModel()
                                              {
                                                  SeatSectionId = Convert.ToInt32(row["SeatSectionId"]),
                                                  VenueId = Convert.ToInt32(row["VenueId"]),
                                                  Description = row["Description"].ToString(),
                                                  SeatCount = Convert.ToInt32(row["SeatCount"])
                                              });
                    }
                }
            }

            return seatSections.FirstOrDefault();
        }

        #endregion

    }
}