using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DatabaseAPI.Model;
using Microsoft.AspNetCore.Authorization;

namespace DatabaseAPI.Controllers {
    [Route("register")]
    [ApiController]
    public class RegistrationController : ControllerBase {
        private readonly DHBWExpertsdatabaseContext _context;

        //The context is managed by the WEBAPI and used here via Dependency Injection.
        public RegistrationController(DHBWExpertsdatabaseContext context) {
            _context = context;
        }

        [HttpPost("{userId}", Name = "registerUser")]
        [Authorize("write:profile")]
        public async Task<IActionResult> registerUser(string userId, VwUsers registeredUser) {
            
            var user = _context.VwUsers.FirstOrDefault(u => u.UserId == registeredUser.UserId);
            var userData = new UserData();

            var isBadRequest =
                userId != registeredUser.UserId ||
                registeredUser.Firstname == null ||
                registeredUser.Lastname == null ||
                registeredUser.Course == null ||
                registeredUser.CourseAbbr == null;

            if (user.Registered == true) {
                return Conflict("User is already registered");
            }
            
            if (isBadRequest) {
                return BadRequest();
            }

            userData.User = registeredUser.UserId;
            userData.Firstname = registeredUser.Firstname;
            userData.Lastname = registeredUser.Lastname;
            userData.Course = registeredUser.Course;
            userData.CourseAbbr = registeredUser.CourseAbbr;
            userData.Specialization = registeredUser.Specialization;
            userData.City = registeredUser.City;
            userData.Biography = registeredUser.Biography;
            userData.RfidId = null;

            _context.UserData.Add(userData);
            
            try {
                await _context.SaveChangesAsync();
            } catch (DbUpdateException)
            {
                return BadRequest();
            }

            var result = _context.VwUsers.FirstOrDefault(u => u.UserId == registeredUser.UserId);
            
            return CreatedAtRoute("getUserById", new {userId = user.UserId}, result);
        }
    }
}
