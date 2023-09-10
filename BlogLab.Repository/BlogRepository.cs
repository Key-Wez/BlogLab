﻿using BlogLab.Models.Blog;
using BlogLab.Models.Photo;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Dapper;
using BlogLab.Models.Account;

namespace BlogLab.Repository
{
    internal class BlogRepository : IBlogRepository
    {
        private readonly IConfiguration _config;
        public BlogRepository(IConfiguration config)
        {
            _config = config;
        }

        public async Task<int> DeleteAsync(int blogId)
        {
            int affectedRows = 0;
            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();
                affectedRows = await connection.ExecuteAsync(
                    "Blog_Delete",
                    new { BlogId = blogId },
                    commandType: CommandType.StoredProcedure);
            }

            return affectedRows;
        }

        public async Task<PageResults<Blog>> GetAllAsync(BlogPaging blogPaging)
        {
            var results = new PageResults<Blog>();

            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();

                using (var multi = await connection.QueryMultipleAsync("Blog_GetAll",
                    new {
                        Offset = (blogPaging.Page - 1) * blogPaging.PageSize,
                        PageSize = blogPaging.PageSize
                    }, 
                    commandType: CommandType.StoredProcedure))
                {
                    results.Items = multi.Read<Blog>();
                    results.TotalCount = multi.ReadFirst<int>();
                }
            }
            
            return results;
        }

        public async Task<List<Blog>> GetAllByUserIdAsync(int applicationUserId)
        {
            IEnumerable<Blog> blogs;
            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();
                blogs = await connection.QueryAsync<Blog>(
                    "Blog_GetByUserId",
                    new { ApplicationUserId = applicationUserId },
                    commandType: CommandType.StoredProcedure);
            }
            return blogs.ToList();
        }

        public async Task<List<Blog>> GetAllFamousAsync()
        {
            IEnumerable<Blog> famousBlogs;
            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();
                famousBlogs = await connection.QueryAsync<Blog>(
                "Blog_GetAllFamous",
                new { }, // if I eliminate would it work?? TODO:
                commandType: CommandType.StoredProcedure);
            }
            return famousBlogs.ToList();
        }

        public async Task<Blog> GetAsync(int blogId)
        {
            Blog blog;
            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();

                blog = await connection.QueryFirstOrDefaultAsync<Blog>(
                    "Blog_Get",
                    new { BlogId = blogId },
                    commandType: CommandType.StoredProcedure);
            }
            return blog;
        }

        public async Task<Blog> UpsertAsync(BlogCreate blogCreate, int applicationUserId)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("BlogId", typeof(int));
            dataTable.Columns.Add("Title", typeof(string));
            dataTable.Columns.Add("Content", typeof(string));
            dataTable.Columns.Add("PhotoId", typeof(int));

            dataTable.Rows.Add(
                blogCreate.BlogId,
                blogCreate.Title,
                blogCreate.Content,
                blogCreate.PhotoId
                );
            int? newBlogId;

            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();

                newBlogId = await connection.ExecuteScalarAsync<int>(
                    "Blog_Upsert",
                    new
                    {
                        Blog = dataTable.AsTableValuedParameter("dbo.BlogType"),
                        ApplicationUserId = applicationUserId
                    },
                    commandType: CommandType.StoredProcedure);
            }
            newBlogId = newBlogId ?? blogCreate.BlogId;

            Blog blog = await GetAsync(newBlogId.Value);

            return blog;
        }
    }
}