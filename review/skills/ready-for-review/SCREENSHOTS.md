# Screenshots

How to fix a NO SCREENSHOT or NO BEFORE/AFTER item from `review-description` yourself.

## 1. Make the images

Render what the PR changes, once on the base branch and once on the PR's head. A new screen needs only the after.

- A file that renders on its own, such as a generated email: fill its placeholders with example values, then `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --hide-scrollbars --window-size=<w>,<h> --screenshot=<png> file://<html>`.
- A page of a running app: open it in a new tab with Claude in Chrome and save a screenshot with `computer` (`screenshot`, `save_to_disk: true`).

Save the images in the scratchpad. Look at each one before you upload it: it shows the change, with example data only.

## 2. Upload them

GitHub only takes image uploads from a logged-in browser, so `gh` can't. Use Claude in Chrome, in a new tab:

1. Open the PR page.
2. `find` the file input of the new comment box at the bottom, and call `file_upload` on it with the image paths.
3. Wait a few seconds, then read the box's value with `javascript_tool`. It holds one `<img … src="https://github.com/user-attachments/assets/…">` per image.
4. Empty the box with `javascript_tool`: set its value to `''` and fire an `input` event. Post nothing.
5. Close the tab.

## 3. Put them in the description

Add a `## Before and after` section before `## Testing`, outside the TODO markers, with a two-column table: before on the left, after on the right. Each `<img>` gets `width="350"` and an `alt` that names the screen.

## When it stays the user's

Ask the user when the image needs a video, a screen behind a login you don't have, or data you can't reach.
