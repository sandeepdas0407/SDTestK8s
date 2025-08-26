using Microsoft.EntityFrameworkCore;
using WebApplication1.Data;
using WebApplication1.Models;
using WebApplication1.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddDbContext<BlogContext>(options =>
    options.UseInMemoryDatabase("BlogDb"));

builder.Services.AddScoped<IBlogService, BlogService>();

// Add CORS for frontend
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configure Kestrel for Docker
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(8080); // Listen on port 8080 for Docker
});

var app = builder.Build();

// Enable CORS
app.UseCors();

// Serve static files (for our frontend)
app.UseStaticFiles();

// Ensure database is created and seeded
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<BlogContext>();
    await context.Database.EnsureCreatedAsync();
}

// API Endpoints

// Get all blog posts
app.MapGet("/api/posts", async (IBlogService blogService) =>
{
    var posts = await blogService.GetAllPostsAsync();
    return Results.Ok(posts);
});

// Get a specific blog post
app.MapGet("/api/posts/{id:int}", async (int id, IBlogService blogService) =>
{
    var post = await blogService.GetPostByIdAsync(id);
    return post == null ? Results.NotFound() : Results.Ok(post);
});

// Create a new blog post
app.MapPost("/api/posts", async (BlogPost post, IBlogService blogService) =>
{
    var createdPost = await blogService.CreatePostAsync(post);
    return Results.Created($"/api/posts/{createdPost.Id}", createdPost);
});

// Update a blog post
app.MapPut("/api/posts/{id:int}", async (int id, BlogPost post, IBlogService blogService) =>
{
    var updatedPost = await blogService.UpdatePostAsync(id, post);
    return updatedPost == null ? Results.NotFound() : Results.Ok(updatedPost);
});

// Delete a blog post
app.MapDelete("/api/posts/{id:int}", async (int id, IBlogService blogService) =>
{
    var deleted = await blogService.DeletePostAsync(id);
    return deleted ? Results.NoContent() : Results.NotFound();
});

// Serve the main page
app.MapGet("/", () => Results.Redirect("/index.html"));

app.Run();
