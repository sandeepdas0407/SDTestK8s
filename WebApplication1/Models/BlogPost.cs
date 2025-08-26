using System.ComponentModel.DataAnnotations;

namespace WebApplication1.Models
{
    public class BlogPost
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;
        
        [Required]
        public string Content { get; set; } = string.Empty;
        
        [Required]
        [StringLength(100)]
        public string Author { get; set; } = string.Empty;
        
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        
        public DateTime? UpdatedDate { get; set; }
        
        [StringLength(500)]
        public string? Summary { get; set; }
        
        public bool IsPublished { get; set; } = true;
    }
}
