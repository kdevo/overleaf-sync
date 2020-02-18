# Overleaf Synchronizer

This is extremely minimalistic one-hour PoC bash script that fetches your project's ZIP from Overleaf and pushes it to your GitHub repository.

## *The *Why* and the *How*

I wanted to learn something about *replaying logins* and *CSRF* in the real world, so I checked if and how my favorite LaTeX IDE Overleaf is using it (properly).
And yes, it is. During the login process itself, a `_csrf` field is submitted in the JSON request payload.

For other actions, a valid session cookie is required.
We can replay this cookie (as long as it's session is active) and utilize this to fetch the ZIP without requiring Overleaf to offer a public API for it. I do not think that this is reliable, but wanted to share my result anyway.

## Instructions

Currently, this project only supports the (more difficult to set-up and maintain) private projects.

### Private Project

#### 1. Retrieve valid session cookie

1. Open up Chrome (or similar Chromium-based browser such as Brave)
2. Login and go to the Overleaf project that you want to synchronize
3. Copy URL and append a `/download/zip` to your project URL, e.g. `https://www.overleaf.com/project/1234567890abcdefdeadb33f/download/zip`
4. Open a new tab, press F12 and go to "Network" dev tools tab
5. Enter URL constructed in step #3
6. Under "Network" dev tools tab and then "Copy as cURL (bash)" as shown in the screenshot below

![.github/copy-curl.png](.github/copy-curl.png)

#### 2. Configure this project

1. Clone this project
2. Put your copied cURL from the step before inside `your-copied-curl.sh`
3. Edit `sync.sh` and configure your `GIT_URL` at the top of the script
4. Call `./sync.sh`
5. Optional: Set-up cron job or similar that calls this script regularly (e.g. hourly)

### Public Project

Maybe coming soon, maybe not.
