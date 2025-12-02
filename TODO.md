# TODO

## Completed
- [x] Fix reschedule button by properly handling notification IDs
  - Use reminder ID as notification ID
  - Cancel old notification before scheduling new one for updates
  - For new reminders, get the inserted ID and use it for notification
- [x] Add pet_id to Reminder model toJson() method
- [x] Handle ID parsing in notification scheduling
- [x] Add error handling to reschedule button onPressed

## Pending
- [ ] Test the reschedule functionality
- [ ] Consider adding notification cancellation when marking reminders as completed or missed
