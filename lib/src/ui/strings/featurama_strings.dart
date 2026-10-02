class FeaturamaStrings {
  const FeaturamaStrings({
    this.title = 'Feature Requests',
    this.filterNew = 'New',
    this.filterPlanned = 'Planned',
    this.filterInProgress = 'In Progress',
    this.filterDone = 'Done',
    this.titlePlaceholder = 'Feature title',
    this.descriptionPlaceholder = 'Describe the feature...',
    this.submit = 'Submit',
    this.cancel = 'Cancel',
    this.empty = 'No feature requests yet',
    this.emptyHint = 'Be the first to suggest a feature!',
    this.error = 'Something went wrong',
    this.retry = 'Retry',
    this.badgePlanned = 'Planned',
    this.badgePending = 'Pending approval',
    this.addRequest = 'Add feature request',
    this.close = 'Close',
    this.refresh = 'Refresh',
    this.loadMore = 'Load more',
    this.loading = 'Loading...',
    this.submitError = 'Could not submit your request. Please try again.',
    this.voteError = 'Could not update your vote. Please try again.',
    this.configError = 'Could not load submission settings. Please retry.',
    this.requiredFields = 'Title and description are required.',
    this.emailOptional = 'Email (optional)',
    this.emailRequired = 'Email (required)',
    this.invalidEmail = 'Enter a valid email address.',
    this.vote = 'Vote',
    this.removeVote = 'Remove vote',
    this.viewDetails = 'View details',
    this.comments = 'Comments',
    this.back = 'Back',
    this.editRequest = 'Edit request',
    this.saveChanges = 'Save changes',
    this.editError =
        'Could not save your changes. Your draft is kept. Please retry.',
    this.commentPlaceholder = 'Write a comment...',
    this.addComment = 'Add comment',
    this.commentRequired = 'Write a comment before sending.',
    this.commentTooLong = 'Comments must be 2000 characters or fewer.',
    this.requestTooLong =
        'Use at most 200 characters for the title and 5000 for the description.',
    this.commentError =
        'Could not send your comment. Your draft is kept. Refresh before retrying if the connection was interrupted.',
    this.commentsError = 'Could not load comments. Please retry.',
    this.noComments = 'No comments yet.',
    this.toggleCommentVote = 'Toggle comment vote',
    this.pendingDiscussion =
        'Only the submitter can comment while approval is pending. Voting is available after approval.',
    this.anonymousAuthor = 'App user',
    this.teamAuthor = 'Team',
    this.authError =
        'Authentication failed. Check that the project key and API origin belong to the same backend. Current hosting uses https://newapi.featurama.app. Legacy keys need their explicit legacy origin.',
    this.commentSent = 'Comment added.',
  });

  final String title;
  final String filterNew;
  final String filterPlanned;
  final String filterInProgress;
  final String filterDone;
  final String titlePlaceholder;
  final String descriptionPlaceholder;
  final String submit;
  final String cancel;
  final String empty;
  final String emptyHint;
  final String error;
  final String retry;
  final String badgePlanned;
  final String badgePending;
  final String addRequest;
  final String close;
  final String refresh;
  final String loadMore;
  final String loading;
  final String submitError;
  final String voteError;
  final String configError;
  final String requiredFields;
  final String emailOptional;
  final String emailRequired;
  final String invalidEmail;
  final String vote;
  final String removeVote;
  final String viewDetails;
  final String comments;
  final String back;
  final String editRequest;
  final String saveChanges;
  final String editError;
  final String commentPlaceholder;
  final String addComment;
  final String commentRequired;
  final String commentTooLong;
  final String requestTooLong;
  final String commentError;
  final String commentsError;
  final String noComments;
  final String toggleCommentVote;
  final String pendingDiscussion;
  final String anonymousAuthor;
  final String teamAuthor;
  final String authError;
  final String commentSent;
}
