using Microsoft.EntityFrameworkCore;
using WebApplication1.Models;

namespace WebApplication1.Data
{
    public class BlogContext : DbContext
    {
        public BlogContext(DbContextOptions<BlogContext> options) : base(options)
        {
        }

        public DbSet<BlogPost> BlogPosts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure BlogPost entity
            modelBuilder.Entity<BlogPost>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Content).IsRequired();
                entity.Property(e => e.Author).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Summary).HasMaxLength(500);
            });

            // Seed some initial data
            modelBuilder.Entity<BlogPost>().HasData(
                new BlogPost
                {
                    Id = 1,
                    Title = "Welcome to Our Blog",
                    Content = "This is our first blog post. Welcome to our amazing blog platform where you can create, edit, and share your thoughts with the world!",
                    Author = "Admin",
                    Summary = "Welcome post introducing our blog platform",
                    CreatedDate = DateTime.UtcNow,
                    IsPublished = true
                },
                new BlogPost
                {
                    Id = 2,
                    Title = "Getting Started with ASP.NET Core",
                    Content = "ASP.NET Core is a cross-platform, high-performance framework for building modern, cloud-based, Internet-connected applications. In this post, we'll explore the basics of building web applications with ASP.NET Core.",
                    Author = "Developer",
                    Summary = "Introduction to ASP.NET Core development",
                    CreatedDate = DateTime.UtcNow.AddDays(-1),
                    IsPublished = true
                }
            );
        }
    }
}
