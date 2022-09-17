# Meeting Minutes - 9/14/22

### General Topics
---
The purpose of this meeting was to clarify some of the ambiguitities the teams had when it came to the initial development of the product prototypes.  We met with the client briefly to hammer out what preferences she had when it came to functionalities within the app.

### Discussion
---
What do we want the app to do? What can users do and see when they open the app?
 - Users should be able to view the most recent/upcoming conference.
 - Users should be able to see individual events within these conferences
 - Conference events have details, descriptions, and the users can individually see each speaker
 - Users should be aware of, or able to track, when events recieve changes to their location/times

Should users be able to sign up to events?
 - Users should be able to track events (to see when they change)
 - Users, ideally, should be able to mark a sort of RSVP so that conference managers can see expected attendance
 - Anonmyous users, aka guests, should be able to mark attendance
    - This means we should track device ID and prevent duplicate sign ups from a singular device or account
 - Push notifications are the current response to event changes (if the events are tracked/starred)

Are there multiple speakers in an event?
 - Yes, there are potentially multiple Keynote speakers as well as Breakout Speakers
    - Breakout sessions are separate events that are also linked to the initial keynote in some way
 - We should differentiate between the type of speaker when displaying them

Do we handle payment with our application?
 - No the University will continue to handle payment on its own
 - That means our app does not communicate with the payment app (likely doesn't at least)
    - How would we even confirm payment securely? Probably not at the current juncture

What are accomodations and do we handle them?
 - We do not handle acommodations such as housing/snacks/meals/etc
 - We can provide information in a separate page as to where users can find accomodations in Maryville though
 - We will have more of a "help" or "info" section that users can view

Do we handle reviews for the users?
 - Yes and no. We do not process our own reviews
 - We link the users to a separate system that will **Survey** them appropriately
 - I do not think survey links will be able to auto generate on our end
    - This means we will provide managers/admins with a place to link their survey for each event.

Database Housing - What do we do?
 - Neither we nor the client fully understand what we should do yet.
 - We have reached out to IT sources on NWMSU to learn more about our options
 - We have also been recommended to check out Firebase as an option by some of the faculty
    - This hosting option is the best we've seen in its free tier
    - We may not need to pay for the hosting unless concurrent users exceed 100
    - Scaling payment looks relatively affordable as well

Notifications? Yes/No
 - Yes we should push notifications when updates to tracked events occur.
 - Even guests should be able to track events

Permission Levels
 - There are multiple requested permission levels
 - Guests: Can view the app without registering. Only view permissions of event details
 - Users: Similar to guests. Registration required. Can answer surveys and have a different RSVP stat
 - Steering Commitee: More of a "manager" role. Can only edit current events. No create/delete
 - Admin: Can create/update/read/delete, etc. Full permissions on all types of things

Schedule Display
 - We discussed ways to display the main/home/scheduling page for the current conference
 - We think a drawer navigation for the app in general is probably good
 - Settings wheel/options/etc in top right corner
 - We want a description and name of the event at the top
 - Sponsers for the event should be listed (likely with the description)
 - Multiple options for viewing the events should be listed (list view, card view, etc)
 - The current event is the primary portion of the page
 - The option to see previous/future conferences should be under the main event
 - Displayed events have names, times, locations, and an option to follow/star/rsvp

Additional details
 - Statistics page for review by admins/managers in their module
    - Different statistics on guests & registered users to help anticipate attendance
 - Info page with accomodation stuff, map to event, general info, contact info,
    - Maybe a predefined googles map link with the event location as a destination already put in
 - Sponsors tab to read more about the current event sponsors, past sponsors
 - Conferences and potentially events should have a property to flag as "public" or "private"
    - That way changes can be made without them being publicly visable

Estimated Pages (for initial app/user view only)
 - Login
 - Register
 - Conference/Schedule/Main
 - Event
 - Speaker
 - Reviews
 - About/Info
 - Settings
