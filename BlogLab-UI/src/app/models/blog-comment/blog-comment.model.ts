export class BlogComment {
    constructor(
        public BlogCommentId: number,
        public BlogId: number,
        public content: string,
        public username: string,
        public applicationUserId: number,
        public publishDate: Date,
        public updateDate: Date,
        // public deleteConfirm: boolean = false,
        public ParentBlogCommentId?: number,
    ) { }
}