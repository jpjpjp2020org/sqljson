/*
UPDATE THIS WHEN INVERTED: Drafts buttons state - by default disabled, because UI in frontend will not assume anything before DB defines what is allowed by "teleporting" the DB constraints to frotend, and node backend checks the same blueprint when frotnend triggers an API endpoint (even if button state is bypassed in frontend).

This sort of means backend doesn’t “trust” frontend. If a button action is triggered, the backend re-validates it against the same DB constraints.
*/

window.updateButtonStates = async function () {

    try {

        const response = await fetch("/api/drafts/buttonstate");
        if (!response.ok) throw new Error(`Failed to fetch button state - Status: ${response.status}`);

        const state = await response.json();

        // button availability based on db-driven state
        document.getElementById("add-post").disabled = !state.enable_add_post;
        document.getElementById("save-post").disabled = !state.enable_save;
        document.getElementById("edit-post").disabled = !state.enable_edit_latest;
        document.getElementById("publish-post").disabled = !state.enable_publish;
        document.getElementById("add-timestamp").disabled = !state.enable_add_timestamp;
        document.getElementById("delete-posts").disabled = !state.enable_delete_all;

    } catch (error) {

        console.error("Error updating button states:", error);

    }

};

// Access admin dashboard logic:
// Same thinking can be applied to all sorts of permission tracking and giving - permission is defined as DB state

