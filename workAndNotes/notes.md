# Build A Blog Using AspNet Core, Angular 14 And SQL Server

- Identify Standalone Components
- Identify All Endpoints
- Identify Database Actions

## - Identify Standalone Components
- Home Component
- Navbar
- Register Component
- Famous Component
- Blog card component
- Login Component
- Blog Component (page)
- Blog text
- Comment Box System
- Comments systems Component
- Dashboard
- Photo Album Component
- Edit Component
- Not Found

## Endpoints
Action that going to perform when the URL resolve into it. (http action/verbs)

### Account Endpoint
[Post] api/account/register - create new user
[Post] api/account/login - let existing user login

### Blog Endpoint
[Post] api/blog - create new blog (Needs authorization) (upsert create / edit)
[Get] api/blog - gets all of the blogs page by page
[Get] api/blog/famous - gets top 6 most talked about blogs
[Get] api/blog/{blogId} - get the given blog
<!-- [get] api/blog/user/{ApplicationUserId}/{blogId} - get the given blog -->
[Get] api/blog/user/{ApplicationUserId} - get all user created blogs
[Delete] api/blog/{blogId} - delete existing blog (Needs authorization)

### Blog Comments Endpoint
[Post] api/blogComment - create new blog comment (Needs authorization)
[Delete] api/blogComment/{blogCommentId} - delete given blog Comment (Needs authorization)
[Get] api/blogComment/{blogId} - load all blog for a given blog

### Photo Endpoint
[Post] api/Photo - upload a photo (Needs authorization)
[Delete] api/Photo/{PhotoId} - delete a photo (Needs authorization)
[Get] api/Photo - get all user's photos (Needs authorization)
[Get] api/Photo/{PhotoId} -  get a specific photo

---
## Database Actions
### Tables
- ApplicationUser
- Blog
- BlogComment
- Photo
### Schema
- aggregate
### Views
- Blog
- BlogComment
### Types
- AccountType
- BlogCommentType
- BlogType
- PhotoType
### Stored Procedures
- Account_GetByUserName
- Account_Insert
- Blog_Get
- Blog_GetAll
- Blog_GetAllFamous
- Blog_GetByUserId
- Blog_Upsert
- BlogComment_Delete
- BlogComment_GetAll
- BlogComment_Upsert
- Photo_Delete
- Photo_Get
- Photo_GetByUserId
- Photo_Insert

---
- https://jwt.io/
- https://cloudinary.com/

## Cloudinary
[Get Started](https://cloudinary.com/documentation/cloudinary_get_started)
[Live Training / Videos](https://training.cloudinary.com/courses/cloudinary-jumpstart-for-new-developer-users-40-minute-course)
[Console](https://console.cloudinary.com/console/c-4bf3cac031de8dc9af7c1c72f91dc2/getting-started)

**Read on IOptions `using Microsoft.Extensions.Options;` What does it do?**



https://stackoverflow.com/questions/70952271/startup-cs-class-is-missing-in-net-6


## ANGULAR (Section6 - build the forntend...)

`ng g pipe pipes/summary` this is to create pipes from Angular CLI 'g' is for generate

On summary.pipe.ts It seems like I have a problem but it did compile... I shall look at it if anything...

`This syntax requires an imported helper but module 'tslib' cannot be found.ts(2354)`

- https://stackoverflow.com/questions/61206439/typescript-error-ts2354-this-syntax-requires-an-imported-helper-but-module-ts

- https://github.com/microsoft/TypeScript/issues/37991

### generate componants
example : `ng g component components/blog-components/blog`
- `ng g component components/blog-components/`+ 
- `blog`
- `blog-card`
- `blog-edit`
- `blogs`
- `famous-blogs`
---
- `ng g component components/comment-components/`+ 
- `comment-box`
- `comment-system`
- `comments`
ng g component components/dashboard
ng g component components/home
ng g component components/login
ng g component components/navbar
ng g component components/not-found
ng g component components/photo-album
ng g component components/register
