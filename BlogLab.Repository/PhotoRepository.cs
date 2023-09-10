using BlogLab.Models.Account;
using BlogLab.Models.Photo;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using Microsoft.AspNetCore.Identity;

namespace BlogLab.Repository
{
    internal class PhotoRepository : IPhotoRepository
    {
        private readonly IConfiguration _config;
        public PhotoRepository(IConfiguration config)
        {
            _config= config;
        }

        public async Task<int> DeleteAsync(int photoId)
        {
            int affectedRows = 0;
            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();
                affectedRows = await connection.ExecuteAsync(
                    "Photo_Delete",
                    new { PhotoId = photoId },
                    commandType: CommandType.StoredProcedure);
            }

            return affectedRows;
        }

        // this is to test to see if this method would work or if I need the IEnumerable

        //public async Task<List<Photo>> GetAllByUserIdAsync(int applicationUserId)
        //{
        //    List<Photo> photos;
        //    using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
        //    {
        //        await connection.OpenAsync();
        //        photos = await connection.ExecuteScalarAsync<List<Photo>>(
        //            "Photo_GetByUserId",
        //            new { ApplicationUserId = applicationUserId },
        //            commandType: CommandType.StoredProcedure);
        //    }
        //    return photos;
        //}
        public async Task<List<Photo>> GetAllByUserIdAsync(int applicationUserId)
        {
            IEnumerable<Photo> photos;
            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();
                photos = await connection.QueryAsync<Photo>(
                    "Photo_GetByUserId",
                    new { ApplicationUserId = applicationUserId },
                    commandType: CommandType.StoredProcedure);
            }
            return photos.ToList();
        }

        public async Task<Photo> GetAsync(int photoId)
        {
            Photo photo;
            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();

                photo = await connection.QueryFirstOrDefaultAsync<Photo>(
                    "Photo_Get",
                    new { PhotoId = photoId },
                    commandType: CommandType.StoredProcedure);
            }
            return photo;
        }

        public async Task<Photo> InsertAsync(PhotoCreate photoCreate, int applicationUserId)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("PublicId", typeof(int));
            dataTable.Columns.Add("ImageUrl", typeof(string));
            dataTable.Columns.Add("Description", typeof(string));

            dataTable.Rows.Add(
                photoCreate.PublicId,
                photoCreate.ImageUrl,
                photoCreate.Description
                );
            int newPhotoId;

            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();

                newPhotoId = await connection.ExecuteScalarAsync<int>(
                    "Photo_Insert",
                    new { Photo = dataTable.AsTableValuedParameter("dbo.PhotoType"),
                        ApplicationUserId = applicationUserId   //here there might be a mistake... Avetis did not used this yet, but I beleive tha we need this in the proc
                    },
                    commandType: CommandType.StoredProcedure);
            }
            Photo photo = await GetAsync(newPhotoId);

            return photo;
        }
    }
}
