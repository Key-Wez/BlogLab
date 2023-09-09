using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BlogLab.Models.Account
{
    public class ApplicationUserLogin
    {
        [Required(ErrorMessage ="User name is required")]
        [MinLength(5, ErrorMessage = "Must be 05-50 characters")]
        [MaxLength(50, ErrorMessage = "Must be 05-50 characters")]
        public string Username { get; set; }

        [Required(ErrorMessage ="Password is required")]
        [MinLength(300, ErrorMessage = "Must be 300-3000 characters")]
        [MaxLength(3000, ErrorMessage = "Must be 300-3000 characters")]
        public string Password { get; set; }
    }
}
