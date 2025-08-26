using Microsoft.EntityFrameworkCore;
using WebApplication1.Data;
using WebApplication1.Models;

namespace WebApplication1.Services
{
    public interface IBlogService
    {
        Task<IEnumerable<BlogPost>> GetAllPostsAsync();
        Task<BlogPost?> GetPostByIdAsync(int id);
        Task<BlogPost> CreatePostAsync(BlogPost post);
        Task<BlogPost?> UpdatePostAsync(int id, BlogPost post);
        Task<bool> DeletePostAsync(int id);
    }

    public class BlogService : IBlogService
    {
        private readonly BlogContext _context;

        public BlogService(BlogContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<BlogPost>> GetAllPostsAsync()
        {
            return await _context.BlogPosts
                .Where(p => p.IsPublished)
                .OrderByDescending(p => p.CreatedDate)
                .ToListAsync();
        }

        public async Task<BlogPost?> GetPostByIdAsync(int id)
        {
            return await _context.BlogPosts
                .FirstOrDefaultAsync(p => p.Id == id && p.IsPublished);
        }

        public async Task<BlogPost> CreatePostAsync(BlogPost post)
        {
            post.CreatedDate = DateTime.UtcNow;
            _context.BlogPosts.Add(post);
            await _context.SaveChangesAsync();
            return post;
        }

        public async Task<BlogPost?> UpdatePostAsync(int id, BlogPost post)
        {
            var existingPost = await _context.BlogPosts.FindAsync(id);
            if (existingPost == null)
                return null;

            existingPost.Title = post.Title;
            existingPost.Content = post.Content;
            existingPost.Author = post.Author;
            existingPost.Summary = post.Summary;
            existingPost.IsPublished = post.IsPublished;
            existingPost.UpdatedDate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return existingPost;
        }

        public async Task<bool> DeletePostAsync(int id)
        {
            var post = await _context.BlogPosts.FindAsync(id);
            if (post == null)
                return false;

            _context.BlogPosts.Remove(post);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
