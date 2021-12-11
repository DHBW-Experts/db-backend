﻿using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DatabaseAPI.Model;

namespace DatabaseAPI.Controllers {
    [Route("search")]
    [ApiController]
    public class SearchController : ControllerBase {
        private readonly DHBWExpertsdatabaseContext _context;

        //The context is managed by the WEBAPI and used here via Dependency Injection.
        public SearchController(DHBWExpertsdatabaseContext context) {
            _context = context;
        }

        // GET: /Search/Tags/LaTeX
        [HttpGet("tags/{text}", Name = "getTagsByText")]
        public async Task<ActionResult<Object>> getTagsByText(string text) {
            if (!Functions.authenticate(_context, 0, "")) {
                return Unauthorized();
            }
            var query =
               from tags in _context.Tags
               where tags.Tag1.Contains(text)
               select new {
                   tag = tags.Tag1
               };

            var result = await query.Distinct().ToListAsync();

            return result;
        }

        // GET: /Search/Tags/LaTeX
        [HttpGet("users/tags/{text}", Name = "getUsersByTag")]
        public async Task<ActionResult<IEnumerable<Object>>> GetUsersByTag(string text) {
            var query =
                from user in _context.Users
                join tags in _context.Tags on user.UserId equals tags.User
                join loc in _context.Dhbws on user.Dhbw equals loc.Location
                where tags.Tag1.Contains(text)
                select new {
                    userId = user.UserId,
                    firstName = user.Firstname,
                    lastname = user.Lastname,
                    dhbw = user.Dhbw,
                    course = user.Course,
                    courseAbr = user.CourseAbr,
                    specialization = user.Specialization,
                    email = user.EmailPrefix + "@" + loc.EmailDomain,
                    city = user.City,
                    biographie = user.Bio,
                    isVerified = user.IsVerified,
                    tmsCreated = user.TmsCreated
                };

            var result = await query.Distinct().Take(25).ToListAsync();

            return result;
        }

    }
}