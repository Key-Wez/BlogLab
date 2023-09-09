using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BlogLab.Models.Account
{
    public class ApplicationUserCreate : ApplicationUserLogin
    {
        [MinLength(06, ErrorMessage = "Must be at least 06-30 characters")]
        [MaxLength(30, ErrorMessage = "Must be at least 06-30 characters")]
        public string FullName { get; set; }

        [Required(ErrorMessage = "Email is required")]
        [MaxLength(30, ErrorMessage = "Can be at most 30 characters")]
        [EmailAddress(ErrorMessage ="Invalid email format")]
        public string Email { get; set; }
    }
}
