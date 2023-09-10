export class BlogCommentViewModel {
    constructor(
        public ParentBlogCommentId: number,
        public BlogCommentId: number,
        public BlogId: number,
        public content: string,
        public username: string,
        public applicationUserId: number,
        public publishDate: Date,
        public updateDate: Date,
        public isEditable: boolean = false,
        public deleteConfirm: boolean = false,
        public isReplying: boolean = false,
        public comments: BlogCommentViewModel[]
    ) { }
}