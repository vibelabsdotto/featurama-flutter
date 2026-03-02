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
}
